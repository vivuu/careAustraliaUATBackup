/**
* Name			:		LWC_DonateLenderBalanceInactiveLender
* Date			:		07/09/2023
* Author		:		Sayan Baral
* Description	:		Find Inacitve Lenders and create donations against their Lender Balances
*/
global class LWC_DonateLenderBalanceInactiveLender Implements Database.Batchable<sObject>, Schedulable{
    global void execute(SchedulableContext sc)
    {
        LWC_DonateLenderBalanceInactiveLender b = new LWC_DonateLenderBalanceInactiveLender();
        database.executebatch(b, 20);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        String query='SELECT Id, FirstName,Lender_Balance__c,';
        query+='(SELECT Id, Loan__r.Stage__c,Loan__r.Repaid_Date__c FROM Transactions__r  WHERE Type__c=\'Loan\' AND Status__c=\'Completed\' AND Loan__r.Stage__c=\'Active\') ';
        query+='FROM Contact WHERE ';
        if(!(Test.isRunningTest()))
        {
            query+='Id IN (SELECT ContactId FROM User WHERE IsActive = TRUE AND LastLoginDate != Last_N_Days: '+Integer.valueOf(lwcGlobalSettings.Inactive_Lender_Limit_Days__c)+' AND Profile.Name=\'Lender\') AND ';
        }
        query+='RecordType.Name=\'Supporter\'';
        return Database.getQueryLocator(query);       
    }
    global void execute(Database.BatchableContext BC, List<Contact> contactWithTransactions)
    {
        SavePoint sp = Database.setSavepoint();
        try
        {
            LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
            map<String, Contact> contactsMap = new map<String, Contact>(LWCUtility.getAllActiveLenders());
            List<Transaction__c> listTransact=new List<Transaction__c>();
            List<String> loanIds=new List<String>();
            Map<Contact,Set<String>> cont_Loan=new Map<Contact,Set<String>>();
            for(Contact c: contactWithTransactions) 
            {	
                if((c.Transactions__r.size()>0)&&(c.Lender_Balance__c>0))
                {
                    
                    for(Transaction__c t: c.Transactions__r)
                    {
                        loanIds.add(t.Loan__c);
                        Set<String> result = cont_Loan.get(c);
                        if(result==null)
                        {
                            result = new Set<String>();
                        }
                        result.add(t.Loan__c);
                        cont_Loan.put(c, result);
                    }
                }
            }
            List<Loan__c> loanWithRS=new List<Loan__c>();
            if(loanIds.size()>0)
            {
                loanWithRS=[SELECT Id,(SELECT Id FROM Repayment_Schedules__r WHERE Repayment_Date__c=NULL AND Status__c=NULL) FROM Loan__c WHERE Id IN :loanIds];
                
            }
            Map<String,boolean> isLoanRepayments=new Map<String,boolean>();
            if(loanWithRS.size()>0)
            {
                for(Loan__c l:loanWithRS)
                {
                    if(l.Repayment_Schedules__r.size()==0)
                        isLoanRepayments.put(l.Id,true);
                    else
                        isLoanRepayments.put(l.Id,false);
                }
            }
            
            for(Contact c: cont_Loan.keySet())
            {
                boolean isDonation=true;
                System.debug(cont_Loan.get(c)+'From class donateinactive');
                if(cont_Loan.get(c).size()>0)
                {
                    for(String loanId: cont_Loan.get(c))
                    {
                        if(isLoanRepayments.get(loanId)==false)
                        {
                            isDonation=false;
                            break;
                        }     
                    }
                    if(isDonation==true)
                    {
                        Transaction__c newDonate=new Transaction__c();
                        newDonate.Type__c='Donation';
                        newDonate.Amount__c=c.Lender_Balance__c;
                        newDonate.Lender__c=c.Id;
                        newDonate.Status__c='Completed';
                        newDonate.Transaction_Date__c=System.now();//additional values status->completed transaction date->today
                        listTransact.add(newDonate);
                    }
                }
            }
            if(listTransact.size()>0)
            {
                System.debug('List inserted--->'+listTransact);
                insert listTransact;
                
                String stdPriceBookId='';
                if(Test.isRunningTest()) {
                    stdPriceBookId = Test.getStandardPricebookId();
                } else {
                    stdPriceBookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
                }
                
                map<String, Transaction__c> oppTransactionMap = new map<String, Transaction__c>();
                list<Opportunity> oppList = new list<Opportunity>();
                String oppDonationRTId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                Campaign donationCampaign = [SELECT Id FROM Campaign WHERE Campaign_Code__c =: lwcGlobalSettings.Campaign_BalanceDonation__c LIMIT 1];
                for(Transaction__c trans: listTransact){
                    system.debug('### trans: '+trans.Loan__c+' - '+trans.Type__c+' - '+contactsMap.get(trans.Lender__c).Name+' - '+trans.Amount__c);
                    if(trans.Type__c=='Donation'){
                        Contact lenderContact = contactsMap.get(trans.Lender__c);
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
        }
        catch(Exception ex)
        {
            system.debug('### ex: '+ex+' - '+ex.getStackTraceString());
            Database.rollback(sp);
            System.debug('error--> '+ex.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWCLenderRepaymentScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=ex.getStackTraceString());
            insert err;
        }
    }
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
}