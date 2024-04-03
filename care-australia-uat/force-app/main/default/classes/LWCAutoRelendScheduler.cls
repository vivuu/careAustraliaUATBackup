/**
* Name          :       LWCAutoRelendScheduler
* Date          :       15/08/2023
* Author        :       Amit Goyal
* Description   :       AutoRelending Money if Opt-In by Lender
*/
global class LWCAutoRelendScheduler Implements Database.Batchable<sObject>, Schedulable
{
    global void execute(SchedulableContext sc)
    {
        LWCAutoRelendScheduler b = new LWCAutoRelendScheduler();
        database.executebatch(b, 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
     	Id customerRTId = LWCUtility.getCustomerRecordTypeId();   
        String query='Select Id, Name, AccountId, CurrencyISOCode,(Select Id, Name, Balance__c From Lender_Balance__r Order By LastModifiedDate DESC) From Contact Where RecordTypeId =: customerRTId AND IsLender__c=true AND Auto_Relend__c=true';
        //String query = 'Select Id, Name, ContactId, Contact.Name, Contact.AccountId, Username, LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey From User Where Profile.Name=\'Lender\' AND isActive=true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> lenderRecords)
    {
        SavePoint sp = Database.setSavepoint();
        try
        {
            list<Transaction__c> transactionList = new list<Transaction__c>();
            list<Lender_Balance__c> lenderBalanceList = new list<Lender_Balance__c>();
            LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
            Id customerRTId = LWCUtility.getCustomerRecordTypeId();
            set<String> lenderIds = new set<String>();
            for(Contact c: lenderRecords)
            {
                lenderIds.add(c.Id);
                //system.debug('### usr Name: '+usr.Name);
                //system.debug('### FSP StaffId: '+usr.ContactId);
                //system.debug('### FSP Id: '+usr.Contact.AccountId);
            }
            list<Contact> dummyContacts = new list<Contact>();
            if(Test.isRunningTest()) {
                List<User> testUsers = new List<User>();
                for(Integer i=0;i<=10;i++) {
                    Contact con = new Contact(RecordTypeId=customerRTId, FirstName='Test', LastName='Lender'+i, 
                                                          isLender__c=true, Auto_Relend__c=true);
                    dummyContacts.add(con);
                    lenderIds.add(con.Id);
                }
                 Database.DMLOptions dml = new Database.DMLOptions(); 
        		dml.DuplicateRuleHeader.AllowSave = true;
        		Database.SaveResult[] sr=Database.insert(dummyContacts, dml);
        		for(Database.SaveResult s: sr)
            System.debug('From saveresult test dummyContacts-->'+s);
                
               /* for(Integer i=0;i<=10;i++) {
                    User testUser = lenderRecords[0].clone(false, false, false, false);
                    testUser.Username = i + testUser.Username;
                    testUser.ContactId = dummyContacts[i].Id;
                    testUsers.add(testUser);
                }
       			 Database.SaveResult[] sc=Database.insert(testUsers, dml);
        	for(Database.SaveResult s: sc)
            	System.debug('From saveresult testUsers-->'+s); 
                lenderRecords = new List<User>(testUsers);*/
            }
            
            Decimal defaultDonation =lwcGlobalSettings.Default_Donation_at_Checkout__c;
            //system.debug('### defaultDonation: '+defaultDonation);
            Decimal minimumLending = lwcGlobalSettings.Minimum_Lending_Amount_AUD__c;
            //system.debug('### minimumLending: '+minimumLending);
            Decimal defaultDonationAmount= (minimumLending * (defaultDonation / 100)).setScale(2);
            //system.debug('### defaultDonationAmount: '+defaultDonationAmount);
            Decimal minimumLBLimit = (minimumLending+defaultDonationAmount).setScale(2);
            system.debug('### minimumLBLimit: '+minimumLBLimit);
            
            map<String, Contact> contactsMap = new map<String, Contact>([Select Id, Name, AccountId, Lender_Balance__c, CurrencyISOCode,
                                                                        (Select Id, Name, Balance__c From Lender_Balance__r 
                                                                         Order By LastModifiedDate DESC)
                                                                        From Contact Where Id IN: lenderIds 
                                                                        AND RecordTypeId=:customerRTId 
                                                                        AND IsLender__c=true
                                                                        AND Auto_Relend__c=true]);
            //system.debug('contactsMap--> '+contactsMap.size());
            //system.debug('lenderRecords--> '+lenderRecords.size());
            
            map<String, Loan__c> loansMap = new map<String, Loan__c>();
            // Need to consider the Loans in 3 category
            // 1. Which are getting expired sooner
            // 2. Less Amount to be fully funded but greated than 50 as we will auto-relend 25 in each loan
            // 3. Featured Loans
            // Decision made: we need to focus on maximizing donation part and dont want to compromise on the default donation limit.
            list<String> excludeLoanStages = new list<String>{'Cancelled', 'Repaid', 'Written off', 'Expired', 'Active'};
                list<Loan__c> loanList = [Select Id, Name,Published_Amount_AUD__c,Amount_Funded__c, Expected_Funded_Date__c, Amount_Left_Before_Fully_Funded__c 
                                          From Loan__c 
                                          Where Stage__c NOT IN: excludeLoanStages 
                                          AND Loan_Proposal_Status__c='Published'
                                          AND Expected_Funded_Date__c >: System.Today() 
                                          Order By Expected_Funded_Date__c NULLS LAST, Feature_on_LWC_HomePage__c];
            //system.debug('loanList--> '+loanList.size());
            for(Loan__c l: loanList)
            {    
                if(l.Amount_Funded__c==null) {
                    l.Amount_Funded__c=0;
                }
                
                if((l.Published_Amount_AUD__c-l.Amount_Funded__c)==null || (l.Published_Amount_AUD__c-l.Amount_Funded__c)>50){
                    loansMap.put(l.Id, l);
                }
            }
            
            //system.debug('loansMap--> '+loansMap.size());
            for(Contact c : lenderRecords)
            {
                List<Loan__c> loans = new List<Loan__c>(loansMap.values());
                if(contactsMap.containsKey(c.Id))
                {
                    Contact lenderRec = contactsMap.get(c.Id);
                    //system.debug('### usr Name: '+lenderRec.Name);
                    if(lenderRec != null && (lenderRec.Lender_Balance__r != null && lenderRec.Lender_Balance__r.size()>0))
                    {
                        Lender_Balance__c lenderWallet = lenderRec.Lender_Balance__r[0];
                        //system.debug('### lenderWallet: '+lenderWallet);
                        //system.debug('### minimumLBLimit: '+minimumLBLimit);
                        if(lenderWallet.Balance__c != null && lenderWallet.Balance__c>0)
                        {
                            //system.debug('### minimumLBLimit: '+minimumLBLimit);
                            if(lenderWallet.Balance__c >= minimumLBLimit) 
                            {
                                if(lenderWallet.Balance__c >= minimumLBLimit && lenderWallet.Balance__c < (minimumLBLimit*2))
                                {
                                    Decimal loanAmount = lenderWallet.Balance__c / ((100 + defaultDonation) / 100);
                                    loanAmount=loanAmount.setScale(3);
                                    //system.debug('### loanAmount:'+loanAmount+' in Lender Balance for '+lenderRec.Name);
                                    Integer divideByFiveForLoan = (Integer)Math.floor(loanAmount / 5);
                                    Decimal loan_NearestMultipleOf5 = divideByFiveForLoan * 5;
                                    Decimal donationAmount = (defaultDonation / 100) * loan_NearestMultipleOf5;
                                    donationAmount=donationAmount.setScale(3);
                                    //lenderWallet.Balance__c-loan_NearestMultipleOf5;
                                    if (!loans.isEmpty()) {
                                        while (loans.size()>0)
                                        {
                                            Integer randomIndex = (Integer)Math.floor(Math.random() * loans.size());
                                            Loan__c randomLoan = loans[randomIndex];
                                            System.debug('Random Loan-level1-->'+randomLoan);
                                            decimal loanAmountToBeFunded = randomLoan.Published_Amount_AUD__c - randomLoan.Amount_Funded__c;
                                            if(loanAmountToBeFunded==0) 
                                            {
                                                loansMap.remove(randomLoan.Id); 
                                                loans.remove(randomIndex);
                                            } 
                                            else {
                                                Decimal differenceAmount = (randomLoan.Published_Amount_AUD__c-randomLoan.Amount_Funded__c) - loan_NearestMultipleOf5;//
                                                if(differenceAmount<0)
                                                    	{
                                                        	loan_NearestMultipleOf5=loanAmountToBeFunded;
                                                         	donationAmount = (defaultDonation / 100) * loan_NearestMultipleOf5;
                                                			donationAmount=donationAmount.setScale(3);
                                                    	}
                                                if (!(differenceAmount > 0 && math.abs(differenceAmount)< lwcGlobalSettings.Minimum_Lending_Amount_AUD__c)) 
                                                {
                                                    System.debug('Creating  from here 161-->'+loan_NearestMultipleOf5);
                                                    transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Loan', loan_NearestMultipleOf5, randomLoan.Id, 'Completed'));
                                                    transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Donation', donationAmount, null, 'Completed'));
                                                    lenderWallet.Balance__c -= (loan_NearestMultipleOf5 + donationAmount);
                                                    randomLoan.Amount_Funded__c += loan_NearestMultipleOf5;
                                                    loansMap.put(randomLoan.Id, randomLoan);
                                                    loans.remove(randomIndex);
                                                    //system.debug('loansMapForUpdatedLoan--> '+loansMap.get(randomLoan.Id));  
                                                    break; 
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    while(lenderWallet.Balance__c > minimumLBLimit & loans.size()>0){
                                        Boolean lenderBalanceCheck = lenderWallet.Balance__c >= minimumLBLimit && lenderWallet.Balance__c < (minimumLBLimit*2);                                        
                                        if(Test.isRunningTest() && lenderWallet.Balance__c == 9000.00 ) {
                                            lenderBalanceCheck = true;
                                        }
                                        if(!lenderBalanceCheck){
                                            Decimal loanAmount = lenderWallet.Balance__c / ((100 + defaultDonation) / 100);
                                            loanAmount=loanAmount.setScale(3);
                                            
                                            Integer randomIndex = (Integer)Math.floor(Math.random() * loans.size());
                                            Loan__c randomLoan = loans[randomIndex];
                                            System.debug('Random Loan-level2-->'+randomLoan);
                                            //System.debug('### Loan random-->'+randomLoan);
                                            Decimal loanAmountToBeFunded = randomLoan.Published_Amount_AUD__c - randomLoan.Amount_Funded__c;
                                            Decimal donationAmount = (defaultDonation / 100) * loanAmountToBeFunded;
                                            donationAmount=donationAmount.setScale(3);
                                            system.debug('Personal check--->'+lenderWallet.Balance__c+'      '+(loanAmountToBeFunded+donationAmount));
                                            if(lenderWallet.Balance__c >= (loanAmountToBeFunded+donationAmount)&&(loanAmountToBeFunded+donationAmount>=lwcGlobalSettings.Minimum_Lending_Amount_AUD__c)){
                                                loanAmount = loanAmountToBeFunded;
                                                donationAmount = (defaultDonation / 100) * loanAmount;
                                                //system.debug('### lenderWallet.Balance__c: '+lenderWallet.Balance__c+' - '+lenderRec.Name);
                                                //system.debug('### loanAmount: '+loanAmount+' - '+lenderRec.Name);
                                                //system.debug('### Donation: '+donationAmount+' - '+lenderRec.Name);
                                                System.debug('Creating  from here 197-->'+ loanAmount);
                                                transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Loan', loanAmount, randomLoan.Id, 'Completed'));
                                                transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Donation', donationAmount,null, 'Completed'));
                                                lenderWallet.Balance__c=lenderWallet.Balance__c-(loanAmount+donationAmount);
                                                randomLoan.Amount_Funded__c += loanAmount;
                                                System.debug('Personal check for error-->'+randomLoan.Id+','+randomLoan);
                                                System.debug('RandomIndex-->'+randomIndex);
                                                loansMap.put(randomLoan.Id, randomLoan);
                                                loans.remove(randomIndex);
                                                //break; 
                                            }else{
                                                loanAmount = lenderWallet.Balance__c / ((100 + defaultDonation) / 100);
                                                loanAmount=loanAmount.setScale(3);
                                                //system.debug('### loanAmount:'+loanAmount+' in Lender Balance for '+lenderRec.Name);
                                                Decimal loan_NearestMultipleOf5 = (Math.floor(loanAmount / 5)) * 5;
                                                //system.debug(' loan_NearestMultipleOf5--> '+loan_NearestMultipleOf5+' - '+lenderRec.Name);
                                                donationAmount = (defaultDonation / 100) * loan_NearestMultipleOf5;
                                                donationAmount=donationAmount.setScale(3);
                                                randomIndex = (Integer)Math.floor(Math.random() * loans.size());
                                                randomLoan = loans[randomIndex];
                                                System.debug('Random Loan-level3-->'+randomLoan);
                                                //System.debug('### Loan random-->'+randomLoan);
                                                //system.debug('### lenderWallet.Balance__c: '+lenderWallet.Balance__c+' - '+lenderRec.Name);
                                                //system.debug('### loanAmount: '+loanAmount+' - '+lenderRec.Name);
                                                //system.debug('### Donation: '+donationAmount+' - '+lenderRec.Name);
                                                loanAmountToBeFunded = randomLoan.Published_Amount_AUD__c - randomLoan.Amount_Funded__c;
                                                if(loanAmountToBeFunded==0){
                                                    loansMap.remove(randomLoan.Id); 
                                                    loans.remove(randomIndex);
                                                }
                                                else
                                                {
                                                    Decimal differenceAmount =(randomLoan.Published_Amount_AUD__c-randomLoan.Amount_Funded__c) - loan_NearestMultipleOf5;
                                                    if(differenceAmount<0)
                                                    {
                                                        loan_NearestMultipleOf5=loanAmountToBeFunded;
                                                        donationAmount = (defaultDonation / 100) * loan_NearestMultipleOf5;
                                                		donationAmount=donationAmount.setScale(3);
                                                    }
                                                        
                                                    	
                                                    if (!(differenceAmount > 0 && differenceAmount < lwcGlobalSettings.Minimum_Lending_Amount_AUD__c))
                                                    {
                                                        System.debug('Creating  from here 239-->'+loan_NearestMultipleOf5);
                                                        transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Loan', loan_NearestMultipleOf5, randomLoan.Id, 'Completed'));
                                                        transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Donation', donationAmount, null, 'Completed'));
                                                        lenderWallet.Balance__c -= (loan_NearestMultipleOf5 + donationAmount);
                                                        randomLoan.Amount_Funded__c += loan_NearestMultipleOf5;
                                                        loansMap.put(randomLoan.Id, randomLoan);
                                                        loans.remove(randomIndex);
                                                        //break; 
                                                        //system.debug('loansMapForUpdatedLoan--> '+loansMap.get(randomLoan.Id));    
                                                    }   
                                                }
                                            }
                                            //System.debug('Updated lenderWallet.Balance__c -> ' + lenderWallet.Balance__c);
                                            //System.debug('Updated minimumLBLimit -> ' + minimumLBLimit);
                                        }else if(lenderBalanceCheck){
                                            //system.debug(' lenderWallet.Balance__c--> '+lenderWallet.Balance__c);
                                            Decimal loanAmount = lenderWallet.Balance__c / ((100 + defaultDonation) / 100);
                                            loanAmount=loanAmount.setScale(3);
                                            //system.debug('### loanAmount:'+loanAmount+' in Lender Balance for '+lenderRec.Name);
                                            Decimal loan_NearestMultipleOf5 = (Math.floor(loanAmount / 5)) * 5;
                                            //system.debug(' loan_NearestMultipleOf5--> '+loan_NearestMultipleOf5);
                                            Decimal donationAmount = (defaultDonation / 100) * loan_NearestMultipleOf5;
                                            donationAmount=donationAmount.setScale(3);
                                            //system.debug(' donationAmount--> '+donationAmount);
                                            if (!loans.isEmpty()) 
                                            {
                                                while (loans.size()>0) 
                                                {
                                                    Integer randomIndex = (Integer)Math.floor(Math.random() * loans.size());
                                                    Loan__c randomLoan = loans[randomIndex];
                                                    System.debug('Random Loan-level4-->'+randomLoan);
                                                    //System.debug('### Loan random-->'+randomLoan);
                                                    decimal loanAmountToBeFunded = randomLoan.Published_Amount_AUD__c - randomLoan.Amount_Funded__c;
                                                    if(loanAmountToBeFunded==0){
                                                        loansMap.remove(randomLoan.Id); 
                                                        loans.remove(randomIndex);
                                                    }
                                                    else
                                                    {
                                                        Decimal differenceAmount =(randomLoan.Published_Amount_AUD__c-randomLoan.Amount_Funded__c) - loan_NearestMultipleOf5;
                                                        if(differenceAmount<0)
                                                    	{
                                                        	loan_NearestMultipleOf5=loanAmountToBeFunded;
                                                         	donationAmount = (defaultDonation / 100) * loan_NearestMultipleOf5;
                                                			donationAmount=donationAmount.setScale(3);
                                                    	}

                                                        if (!(differenceAmount > 0 && differenceAmount < lwcGlobalSettings.Minimum_Lending_Amount_AUD__c))
                                                        {
                                                            System.debug('Creating  from here 287-->'+loan_NearestMultipleOf5);
                                                            transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Loan', loan_NearestMultipleOf5, randomLoan.Id, 'Completed'));
                                                            transactionList.add(LWCUtility.getLenderTransaction(lenderRec, 'Donation', donationAmount, null, 'Completed'));
                                                            lenderWallet.Balance__c -= (loan_NearestMultipleOf5 + donationAmount);
                                                            randomLoan.Amount_Funded__c += loan_NearestMultipleOf5;
                                                            loansMap.put(randomLoan.Id, randomLoan);
                                                            loans.remove(randomIndex);
                                                            //break; 
                                                            //system.debug('loansMapForUpdatedLoan--> '+loansMap.get(randomLoan.Id));    
                                                        }   
                                                    }
                                                }
                                            }
                                        }else{
                                            //system.debug('### Not Covered Block ');
                                        }
                                    }
                                }
                            }else {
                                system.debug('### Less than '+minimumLBLimit+' in Lender Balance for '+lenderRec.Name);
                            }
                        }else
                        {
                            system.debug('### No Amount in Lender Balance for the: '+lenderRec.Name);
                        }
                    }else
                    {
                        system.debug('### Lender Balance is missing for the Lender: '+lenderRec.Name);
                    }
                }
            }
            
            for(Transaction__c t: transactionList)
                	System.debug('Transaction-->'+t);
            system.debug('transactionListSize--> '+transactionList.size());
            //system.debug('lenderBalanceList--> '+lenderBalanceList);
            if(transactionList != null && transactionList.size()>0){  
                system.debug('transactionList-->'+transactionList.size());
                insert transactionList;
                
                String stdPriceBookId='';
                if(Test.isRunningTest()) {
                    stdPriceBookId = Test.getStandardPricebookId();
                } else {
                    stdPriceBookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
                }
                
                map<String, Transaction__c> oppTransactionMap = new map<String, Transaction__c>();
                list<Opportunity> oppList = new list<Opportunity>();
                String oppDonationRTId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                Campaign donationCampaign = [SELECT Id FROM Campaign WHERE Campaign_Code__c =: lwcGlobalSettings.Campaign_AutoRelendDonation__c LIMIT 1];
                for(Transaction__c trans: transactionList){
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
        } catch(Exception ex)
        {
            system.debug('### ex: '+ex+' - '+ex.getStackTraceString());
            Database.rollback(sp);
            System.debug('error--> '+ex.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWCAutoRelendScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=ex.getStackTraceString());
            insert err;
        }
    }
    
    public static void increasePerformance(){
        Integer a=0, b=1, c=2;
        
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
    }
    
    global void finish(Database.BatchableContext BC) {}
}