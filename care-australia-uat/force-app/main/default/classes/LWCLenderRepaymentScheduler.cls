/**
* Name          :       LWCLenderRepaymentScheduler
* Date          :       05/09/2023
* Author        :       Amit Goyal
* Description   :       Repaying the Amount in Lender Balance as we receive the repayment for Loan
                        The Transaction will stay in Held Status
                        Reason: Considering a AML-Check will happen after this, if the AML check will be performed.
                        The Transaction will be updated with status to Completed if the AML is not required or AML Succeeded.
                        If the AML will be required than the transaction will be Completed once the AML will Succeed.
*/
global class LWCLenderRepaymentScheduler Implements Database.Batchable<sObject>, Schedulable{
    global void execute(SchedulableContext sc)
    {
        LWCLenderRepaymentScheduler b = new LWCLenderRepaymentScheduler();
        database.executebatch(b, 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        Integer lastDayOfThisMonth = Date.daysInMonth(System.today().year(), System.today().month());
        Date lastDayDateOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), lastDayOfThisMonth);
        
        list<String> repaymentStatus = new list<String>();
        repaymentStatus.addAll(new list<String>{'Underpaid', 'Overpaid', 'Paid'});
        String query = 'Select Id, Name, Principal_Repaid__c, Loan__c, Repayment_Date__c From Repayment_Schedule__c Where Status__c IN: repaymentStatus';
        query += ' AND (Repayment_Date__c >=: firstDayOfThisMonth AND Repayment_Date__c <=: lastDayDateOfThisMonth) Order By Loan__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Repayment_Schedule__c> repayments)
    {
        SavePoint sp = Database.setSavepoint();
        try {
            LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
            Contact guestLender = [Select Id, Name From Contact Where Name =: lwcGlobalSettings.LWC_GuestLender__c limit 1];
            String fxGainLenderId=lwcGlobalSettings.FX_Gain_Lender__c;
            if(lwcGlobalSettings.FX_Gain_Lender__c != null && lwcGlobalSettings.FX_Gain_Lender__c.trim().length()>0){
                Contact fxGainLender = [Select Id, Name From Contact Where Name=: lwcGlobalSettings.FX_Gain_Lender__c];
                fxGainLenderId=fxGainLender.Id;
            }
            set<String> loanIds = new set<String>();
            map<String, list<Repayment_Schedule__c>> loanRepaymentsMap = new map<String, list<Repayment_Schedule__c>>();
            if(repayments != null && repayments.size()>0){
                for(Repayment_Schedule__c rs: repayments){
                    loanIds.add(rs.Loan__c);
                    
                    // It might be possible that one loan could have multiple repayment in a month
                    list<Repayment_Schedule__c> result = loanRepaymentsMap.get(rs.Loan__c);
                    if(result==null){
                        result= new list<Repayment_Schedule__c>();
                    }
                    result.add(rs);
                    loanRepaymentsMap.put(rs.Loan__c, result);
                }
            }
            
            map<String, Contact> lendersMap = new map<String, Contact>(LWCUtility.getAllActiveLenders());
            //system.debug('lendersMap--> '+lendersMap.size());
            
            // the below map is to update loans
            map<String, Loan__c> loansMap = new map<String, Loan__c>();
            // the below list is to insert the repayment transaction
            list<Transaction__c> transactionList = new list<Transaction__c>();
            
            // get the loans and loan lending transactions which are related to the repayments to process
            list<Loan__c> loan_RepaymentsThisMonth = [Select Id, Name, Actual_Loan_Principle_Disbursed_AUD__c, Buffer_To_Repay__c, 
                                                      Buffer_Setteled__c, 
                                                      (Select Id, Loan__c, Lender__c, Type__c, Amount__c From Transactions__r 
                                                       Where Loan__r.Repaid_Date__c=NULL AND (Type__c='Loan' OR Type__c='Repayment'))
                                                      From Loan__c Where Id IN: loanIds];
            if(loan_RepaymentsThisMonth != null && loan_RepaymentsThisMonth.size()>0){
                map<String, Decimal> repaymentAmountByLender = new map<String, Decimal>();
                map<String, Decimal> lendingAmountByLender = new map<String, Decimal>();
                for(Loan__c l: loan_RepaymentsThisMonth){
                    list<Repayment_Schedule__c> rsList = loanRepaymentsMap.get(l.Id);
                    // If we have got repayment for the Loan
                    if(rsList != null && rsList.size()>0){
                        // If we got the transaction, than we could acknowledge the Lending and Repayment for the Lenders
                        if(l.Transactions__r != null && l.Transactions__r.size()>0){
                            // Running loop to acknowledge how much of total lending a lender has done and how much repayment has been processed already
                            for(Transaction__c t: l.Transactions__r){
                                if(t.Type__c=='Loan'){
                                    // Collecting the total lending in a map
                                    Decimal totalLending = lendingAmountByLender.get(t.Loan__c+'~'+t.Lender__c);
                                    if(totalLending==null){
                                        totalLending=0.0;
                                    }
                                    totalLending+=t.Amount__c;
                                    lendingAmountByLender.put(t.Loan__c+'~'+t.Lender__c, totalLending);
                                }
                                
                                if(t.Type__c=='Repayment'){
                                    // Collecting total repayment done so far for a lender
                                    Decimal totalRepayments = repaymentAmountByLender.get(t.Loan__c+'~'+t.Lender__c);
                                    if(totalRepayments==null){
                                        totalRepayments=0.0;
                                    }
                                    totalRepayments+=t.Amount__c;
                                    repaymentAmountByLender.put(t.Loan__c+'~'+t.Lender__c, totalRepayments);
                                }
                            }
                        }
                    }
                }
                
                for(Loan__c l: loan_RepaymentsThisMonth){
                    
                    Decimal totalRepaymentAmount=0.0;
                    list<Repayment_Schedule__c> rsList = loanRepaymentsMap.get(l.Id);
                    if(rsList != null && rsList.size()>0){
                        for(Repayment_Schedule__c rs: rsList){
                            if(rs.Principal_Repaid__c != null && rs.Principal_Repaid__c > 0){
                                totalRepaymentAmount+=rs.Principal_Repaid__c;
                            }
                        }
                        
                        // If we have got repayment for the Loan, than create repayment transactions
                        if(totalRepaymentAmount != null && totalRepaymentAmount > 0){
                            // If we got the transaction, than we could acknowledge the Lending and Repayment for the Lenders
                            if(l.Transactions__r != null && l.Transactions__r.size()>0){
                                // Running the loop on transaction to make repayments
                                for(Transaction__c t: l.Transactions__r){
                                    // getting proportion of the loan lending made out of the actual loan principle disbursed amount 
                                    // which we have used from the Loan Published Amount
                                    map<String, Decimal> currencyConversionMap = LWCUtilityFX.getCurrencyConversionMap();
                                	Decimal totalRepayAmountInAUD = LWCUtilityFX.conversionfromLCtoAUD(totalRepaymentAmount,'VND',currencyConversionMap);
                                    Decimal loanProportion = (t.Amount__c / l.Actual_Loan_Principle_Disbursed_AUD__c) * 100;
                                    Decimal amountToRepay = (loanProportion / 100) * totalRepayAmountInAUD;
                                    System.debug('kk:'+lendersMap.containsKey(t.Lender__c)+',:'+amountToRepay);
                                    if(lendersMap.containsKey(t.Lender__c) && amountToRepay > 0){
                                        // It will create the same number of transaction for repayment, the number of Loan transaction we have
                                        // also each repayment will be link to the Loan as per the initially discussed requirement
                                        Decimal totalRepayments=0;
                                        if(repaymentAmountByLender.containsKey(t.Loan__c+'~'+t.Lender__c)){
                                            // Checking if we have some previous repayments for the lender for this loan
                                            totalRepayments = repaymentAmountByLender.get(t.Loan__c+'~'+t.Lender__c);
                                            Decimal totalLentAmount=lendingAmountByLender.get(t.Loan__c+'~'+t.Lender__c);
                                            Decimal newTotalRepayments=totalRepayments+amountToRepay;
                                            if(newTotalRepayments > totalLentAmount){
                                                Decimal fxGain = newTotalRepayments-totalLentAmount;
                                                amountToRepay = totalLentAmount - totalRepayments;
                                                // Create FX Gain Transaction
                                                transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=fxGainLenderId, Type__c='FX Gain', 
                                                                                       Status__c='Completed', Amount__c=fxGain.setScale(3), 
                                                                                       CurrencyIsoCode='AUD', Completed_Date__c=System.Today(),
                                                                                       Transaction_Date__c=System.Today()));
                                            }
                                        }
                                        if(t.Lender__c==guestLender.Id){
                                            transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=t.Lender__c, Type__c='Donation',
                                                                               Status__c='Completed', Amount__c=amountToRepay.setScale(3),
                                                                               CurrencyIsoCode='AUD', Completed_Date__c=System.Today(),
                                                                               Transaction_Date__c=System.Today()));
                                        }else{
                                            transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=t.Lender__c, Type__c='Repayment',
                                                                                   Status__c='Held', Amount__c=amountToRepay.setScale(3),
                                                                                   CurrencyIsoCode='AUD', Completed_Date__c=System.Today(),
                                                                                   Transaction_Date__c=System.Today()));
                                        }
                                        
                                        totalRepayments+=amountToRepay;
                                        repaymentAmountByLender.put(t.Loan__c+'~'+t.Lender__c, totalRepayments);
                                    }
                                }
                            }
                        }
                    }
                    
                    if(l.Buffer_Setteled__c == false && (l.Buffer_To_Repay__c != null && l.Buffer_To_Repay__c>0)){
                        for(String lId: lendingAmountByLender.keyset()){
                            list<String> lenderTrasaction = lId.Split('~');
                            String lenderId=lenderTrasaction[0];
                            Decimal loanProportion = (lendingAmountByLender.get(lId) / l.Actual_Loan_Principle_Disbursed_AUD__c) * 100;
                            Decimal bufferToRepay = (loanProportion / 100) * l.Buffer_To_Repay__c;
                            
                            if(lendersMap.containsKey(lId) && bufferToRepay > 0){
                                // Buffer_Repaid__c is a important field to exclude this transaction at the time of rolling up the repayment
                                // to mark the loan as repaid and not to affect calculations and also transaction will not be linked to the loan 
                                // and do not affect the repayment calculations
                                if(lenderId==guestLender.Id){
                                    transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lenderId, Type__c='Donation', Status__c='Completed', 
                                                                           Amount__c=bufferToRepay.setScale(3), CurrencyIsoCode='AUD', 
                                                                           Completed_Date__c=System.Today(), Transaction_Date__c=System.Today(),
                                                                           Buffer_Repaid__c=true));
                                }else{
                                    transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lenderId, Type__c='Repayment', Status__c='Held', 
                                                                           Amount__c=bufferToRepay.setScale(3), CurrencyIsoCode='AUD', 
                                                                           Completed_Date__c=System.Today(), Transaction_Date__c=System.Today(),
                                                                           Buffer_Repaid__c=true));
                                }
                                //LWCUtility.getLenderTransaction(lendersMap.get(lId), 'Repayment', bufferToRepay, l.Id, 'Held');
                            }
                        }
                        // Buffer_Setteled__c is a important field here to acknowledge that the buffer amount has need repaid
                        // at the time of next repayment to not process it again
                        loansMap.put(l.Id, new Loan__c(Id=l.Id, Buffer_Setteled__c=true));
                    }
                }
            }
            
            if(transactionList != null && transactionList.size()>0){
                insert transactionList;
                
                //map<String, Transaction__c> transMap = new map<String, Transaction__c>([Select Id, Name, Amount__c From Transaction__c Where Id IN: transactionList]);
                String stdPriceBookId='';
                if(Test.isRunningTest()) {
                    stdPriceBookId = Test.getStandardPricebookId();
                } else {
                    stdPriceBookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
                }
                
                map<String, Transaction__c> oppTransactionMap = new map<String, Transaction__c>();
                list<Opportunity> oppList = new list<Opportunity>();
                String oppDonationRTId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                Campaign donationCampaign = [SELECT Id FROM Campaign WHERE Campaign_Code__c =: lwcGlobalSettings.Campaign_GeneralDonation__c LIMIT 1];
                for(Transaction__c trans: transactionList){
                    //system.debug('### trans: '+trans.Loan__c+' - '+trans.Type__c+' - '+lendersMap.get(trans.Lender__c).Name+' - '+trans.Amount__c);
                    if(trans.Type__c=='Donation'){
                        Contact lenderContact = lendersMap.get(trans.Lender__c);
                        String oppName=lenderContact.Name + ' $' + trans.Amount__c;
                        oppList.add(new Opportunity(RecordTypeId=oppDonationRTId, Name=oppName, AccountId=lenderContact.AccountId, 
                                                    ContactId=lenderContact.Id, CurrencyIsoCode='AUD', CloseDate=Date.today(), 
                                                    StageName='Closed Won', Donation_Source__c='Auto Transfer', Type = 'LWC', Amount=trans.Amount__c,
                                                    CampaignId=donationCampaign.Id, Pricebook2Id=stdPriceBookId));
                        oppTransactionMap.put(oppName, trans);
                    }
                }
                
                system.debug('### oppList size: '+oppList.size());
                if(oppList != null && oppList.size()>0){
                    insert oppList;
                    
                    Product2 donationProduct = [SELECT Id FROM Product2 WHERE Name = 'Donation' LIMIT 1];
                    List<OpportunityLineItem> opplineItems = new List<OpportunityLineItem>();
                    for(Opportunity opp: oppList){
                        Transaction__c resultTrans = oppTransactionMap.get(opp.Name);
                        resultTrans.Opportunity__c=opp.Id;
                        oppTransactionMap.put(opp.Id, resultTrans);
                        opplineItems.add(new OpportunityLineItem(OpportunityId=opp.Id, Product2Id=donationProduct.Id, Quantity=opp.Amount, UnitPrice=1));
                    }
                     
                    insert opplineItems;
                    
                    list<npe01__OppPayment__c> payments = [Select Id, Name, npe01__Opportunity__c From npe01__OppPayment__c Where npe01__Opportunity__c IN: oppList];
                    if(payments != null && payments.size()>0){
                        for(npe01__OppPayment__c p: payments){
                            p.npe01__Payment_Method__c='Internal Transfer';
                            p.Merchant_Category__c='LWC Transaction';
                            p.npe01__Check_Reference_Number__c=oppTransactionMap.get(p.npe01__Opportunity__c).Name;
                        }
                        update payments;
                    }
                    
                    map<String, Transaction__c> transactionsMap = new map<String, Transaction__c>();
                    for(Transaction__c t: oppTransactionMap.values()){
                        transactionsMap.put(t.Id, t);
                    }
                    update transactionsMap.values();
                }
            }
            
            if(loansMap != null && loansMap.size()>0){
                update loansMap.values();
            }
            if( Test.isRunningTest() ){
                //Transaction__c t = transactionList[0];
            }
        } catch(Exception ex) {
            system.debug('### ex: '+ex+' - '+ex.getStackTraceString());
            Database.rollback(sp);
            System.debug('error--> '+ex.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWCLenderRepaymentScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=ex.getStackTraceString());
            insert err;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}