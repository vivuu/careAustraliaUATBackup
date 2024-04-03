public class LWCTestUtility {
    public static void getCurrencyTypeList(){
        /*list<CurrencyType> currencies= new list<CurrencyType>();
        currencies.add(new CurrencyType(ConversionRate=1, IsoCode='AUD', IsActive=true, IsCorporate=true));
        currencies.add(new CurrencyType(ConversionRate=0.64, IsoCode='USD', IsActive=true, IsCorporate=false));
        currencies.add(new CurrencyType(ConversionRate=9848.82, IsoCode='IDR', IsActive=true, IsCorporate=false));
        currencies.add(new CurrencyType(ConversionRate=36.41, IsoCode='PHP', IsActive=true, IsCorporate=false));
        currencies.add(new CurrencyType(ConversionRate=15487.35, IsoCode='VND', IsActive=true, IsCorporate=false));
        insert currencies;*/
    }
    public static list<CollaborationGroup> createCollaborationGroups(Boolean isInsert) {
        List<String> grpNames = new List<String> {'LWC Admin1','Finance Team1'};
            Map<String, CollaborationGroup> grpMap = new Map<String, CollaborationGroup>();
        for (CollaborationGroup cg : [SELECT Name FROM CollaborationGroup WHERE Name IN :grpNames]) {
            grpMap.put(cg.Name, cg);
        }
        //Create Public Chatter groups
        List<CollaborationGroup> grps = new List<CollaborationGroup>();
        for (String grpName:grpNames) {
            //Confirm group does not already exist
            if (!grpMap.containsKey(grpName)) {
                CollaborationGroup g = new CollaborationGroup(Name=grpName,CollaborationType = 'Private', Description = 'LWC Admin Chatter group', CanHaveGuests = false, IsArchived = false, IsAutoArchiveDisabled = true);
                grps.add(g);
            }
        }
        System.debug( 'ccc:'+grps );
        if(isInsert){
            insert grps;
        }
        return grps;
        /*list<CollaborationGroup> cgList = new list<CollaborationGroup>();
        cgList.add(new CollaborationGroup(Name = 'LWC Admin1', CollaborationType = 'Private', Description = 'LWC Admin Chatter group', CanHaveGuests = false, IsArchived = false, IsAutoArchiveDisabled = true));
        cgList.add(new CollaborationGroup(Name = 'Finance Team1', CollaborationType = 'Private', Description = 'LWC Admin Chatter group', CanHaveGuests = false, IsArchived = false, IsAutoArchiveDisabled = true));
        
        if(isInsert){
            insert cgList;
        }
        return cgList;*/
    }
    
    public static list<Account> getFSPAccounts(){
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        return [Select Id, Name, CurrencyISOCode, Acronym__c From Account Where RecordTypeId=: fspRTId];
    }
    
    
    public static list<User> getFSPStaffUsers(){
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        Id fspBRTId=LWCUtility.getFSPBorrowerRecordTypeId();
        Id fspStaffRTId = LWCUtility.getFSPStaffRecordTypeId();
       
        list<User> fspStaffUsers = [SELECT Id, Name, ContactId,ProfileId,Country,CurrencyIsoCode FROM User WHERE IsActive=TRUE AND Profile.Name = 'FSP Staff' AND ContactId != null];
        List<String> fspContactIds = new List<String>();
        for(User usr: fspStaffUsers){
            fspContactIds.add(usr.ContactId);
        }
        
        
        Map<String,String> acCOnt=new Map<String,String>();
        list<Account> fspAccounts = new list<Account>();
        for(Integer i=0; i<fspContactIds.size(); i++){
            if(i<=9){ fspAccounts.add(new Account(RecordTypeId=fspRTId, Name='TestFSP'+i, CurrencyISOCode='VND', Acronym__c='FI'+i)); }
        }
        insert fspAccounts;
        for(Integer i=0; i<fspAccounts.size(); i++){
            acCont.put(fspAccounts[i].Id,fspContactIds[i]);
        }
        list<Account> fspBorrowerAccounts = new list<Account>();
        for(Account a: fspAccounts){
                
              fspBorrowerAccounts.add(new Account(RecordTypeId=fspBRTId, Name= a.Name, ParentId=a.Id));
        }
        insert fspBorrowerAccounts;
    
        list<Contact> fspContacts = new list<Contact>();
        for(Account acc: fspAccounts){
            fspContacts.add(new Contact(RecordTypeId=fspStaffRTId, FirstName=acc.Name, LastName = 'Staff', Street__c='Test', Ward__c='Test', Id=acCont.get(acc.Id),
                                        District__c='Test', City__c='Test', Country__c='Vietnam', Email=acc.Name+'@example.com', AccountId = acc.Id));
        }
        /****Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult[] sr=Database.update(fspContacts, dml);
        for(Database.SaveResult s: sr)
            System.debug('From saveresult'+s);
        Map<String,String> accCont=new Map<String,String>();
        for(Contact c: fspContacts){
            accCont.put(c.Id,c.AccountId);
            
        }****/
        /*for(User usr: fspStaffUsers){
            conts.add( new Contact(RecordTypeId=fspStaffRTId, FirstName='Test1', LastName = 'Staff', Street__c='Test', Ward__c='Test', 
                                    District__c='Test', City__c='Test', Country__c='Vietnam', Email='test@example.com', Id = usr.ContactId
                                  ));
            usr.ContactId=fspContacts[k].Id;
        }
        Database.update(conts, dml);*/
      

       return fspStaffUsers;
    }
    
    public static list<Contact> getBorrowerRecords(list<User> fspStaffUsers){
        Id borrowerRTId = LWCUtility.getBorrowerRecordTypeId();
        list<Contact> borrowerContacts = new list<Contact>();
        Integer i=1;
        for(User usr: fspStaffUsers){
            borrowerContacts.add(new Contact(RecordTypeId=borrowerRTId, FSP_Name__c=usr.ContactId, Published_Name__c='TB'+i, 
                                             FSP_Client_ID__c='FSP-0000'+i, FirstName=usr.ContactId, LastName='Borrower'+i, City__c='Test'+i, 
                                             Country__c='Vietnam', Gender__c='Female', Disability__c='No', Borrower_Type__c='Individual'));
            i++;
        }
        insert borrowerContacts;
        
        return [Select Id, Name, Care_Borrower_Id__c, FSP_Name__c, FSP_Client_ID__c From Contact Where RecordTypeId=:borrowerRTId];
    }
    
    public static list<Loan__c> getBorrowerLoans(list<Contact> borrowers){
        list<Loan__c> loans = new list<Loan__c>();
        for(Contact con: borrowers){
            loans.add(new Loan__c(Published_Amount_AUD__c=20000000,Borrower__c=con.Id, FSP_Name__c=con.FSP_Name__c, FSP_Loan_ID__c='L-'+con.FSP_Client_ID__c, 
                                  Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-29), 
                                  Actual_Loan_Principle_Disbursed_AUD__c=24000000,
                                  Loan_Principal_Disbursed__c=24000000, Loan_Schedule__c='Monthly', CurrencyISOCode='VND', 
                                  Consent_Provided__c=true, Number_of_Employees__c=1, Jobs_Created__c=1, Female_Employees_Count__c=1,
                                  Loan_Purpose__c='Farming', CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                  Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                  Loan_Proposal_Status__c='Draft', Stage__c='New'));
        }
        insert loans;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    
     public static list<Loan__c> getActiveLoans(Integer lenders){
        list<Loan__c> loans = new list<Loan__c>();
        for(Integer i=0;i<=lenders;i++){
            loans.add(new Loan__c(Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-29), 
                                  Loan_Principal_Disbursed__c=24000000, Loan_Schedule__c='Monthly', CurrencyISOCode='VND',
                                  Consent_Provided__c=true, Number_of_Employees__c=1, 
                                  Jobs_Created__c=1, Female_Employees_Count__c=1,Loan_Purpose__c='Farming', 
                                  CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                  Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                  Stage__c='Active'));
        }
        insert loans;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    
    public static Repayment_Schedule__c getRepaymentRecord(Id loanId, Decimal amount, Date dt){
        return new Repayment_Schedule__c(Loan__c=loanId, Amount_Due__c=amount, Due_Date__c=dt);
    }
    
    public static list<Loan__c> submitLoanforReview(list<Loan__c> loanList){
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Under Review';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    public static list<Loan__c> getLoansSystemRejected(list<Loan__c> loanList){
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='System Rejected';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    public static list<Loan__c> getLoansContentApproved(list<Loan__c> loanList){
        for(Loan__c l: loanList){
            l.Published_Date__c=System.Today().addDays(-60);
            l.Loan_Proposal_Status__c='Content Approved';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    public static list<Loan__c> getLoansReadyToPublish(list<Loan__c> loanList){
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Ready To Publish';
            l.Stage__c='Scheduled';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    public static list<Loan__c> updateLoansToPublish(list<Loan__c> loanList){
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Published';
            l.Stage__c='Fundraising';
            l.Expected_Funded_Date__c=System.Today().addDays(60);
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    public static list<Loan__c> updateLoansToActive(list<Loan__c> loanList){
        for(Loan__c l: loanList){
            l.Stage__c='Active';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        return [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, Loan_Principal_Disbursed_USD__c,
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
    }
    
    public static list<User> getLenderUsers(){
        return [SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null];
    }
    
    public static list<String> getLenderUsersIds(){
        list<User> lenderUsers = getLenderUsers();
        map<String, User> lendersMap = new map<String, User>();
        for(User usr: lenderUsers){
            lendersMap.put(usr.ContactId, usr);
        }
        list<String> lenderIds = new list<String>();
        lenderIds.addAll(lendersMap.keyset());
        return lenderIds;
    }
    
    public static list<Transaction__c> getLoanTransactionList(list<Loan__c> loanList, list<String> lenderIds){
        list<Transaction__c> transactionList = new list<Transaction__c>();
        for(Loan__c l: loanList){
            system.debug('### Published_Amount_AUD__c: '+l.Published_Amount_AUD__c+' - '+lenderIds.size());
            Decimal amount = l.Published_Amount_AUD__c/lenderIds.size();
            amount=amount.setScale(3);
            for(Integer a=0; a<lenderIds.size(); a++){
                transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lenderIds[a], Type__c='Loan', Amount__c=amount, Status__c='Completed',Transaction_Date__c=Date.today()));
                //a++;
            }
            l.Stage__c='Active';
        }
        insert transactionList;
        update loanList;
        return transactionList;
    }
    
    public static list<Transaction__c> getRepaymentTransactionList(list<Loan__c> loanList, list<String> lenderIds){
        list<Transaction__c> transactionList = new list<Transaction__c>();
        for(Loan__c l: loanList){
            system.debug('### Published_Amount_AUD__c: '+l.Published_Amount_AUD__c+' - '+lenderIds.size());
            Decimal amount = l.Published_Amount_AUD__c/lenderIds.size();
            amount=amount.setScale(3);
            for(Integer a=0; a<lenderIds.size(); a++){
                transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lenderIds[a], Type__c='Repayment', Amount__c=4999, Status__c='Held',Transaction_Date__c=Date.today()));
                //a++;
            }
            l.Stage__c='Active';
        }
        insert transactionList;
        update loanList;
        return transactionList;
    }
    
    
    
    public static list<Repayment_Schedule__c> getLastMonthsRepayments(){
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        
        // Get the first day of the month
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        // Get the last day of the month
        Integer lastDayOfMonth = Date.daysInMonth(year, month);
        Date lastDayDate = Date.newInstance(year, month, lastDayOfMonth);
        
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c
                                                       From Repayment_Schedule__c 
                                                       Where Due_Date__c >=: firstDayOfMonth AND Due_Date__c <=: lastDayDate];
        system.debug('### rsToSetPayments Size: '+rsToSetPayments.size());
        return rsToSetPayments;
    }
    
    public static list<Contact> getLenderContacts(){
        Id customerRTId = LWCUtility.getCustomerRecordTypeId();
        User LenderUser = [SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null LIMIT 1];       
        List<Contact> lenderContacts=new List<Contact>();
        lenderContacts.add(new Contact(RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true, 
                                         Email='testLender@example.com'));
        lenderContacts.add(new Contact(RecordTypeId=customerRTId, FirstName='Test2', LastName = 'Staff',IsLender__c=true,Active__c=true,
                                         Email='testLender@example.com'));
        insert lenderContacts;
        List<Lender_Balance__c> LBList = new List<Lender_Balance__c>();
        for(Contact con:lenderContacts){
            Lender_Balance__c leanderB = new Lender_Balance__c();
            leanderB.Balance__c= 1000;
            leanderB.Lender__c = con.Id;
            leanderB.CurrencyIsoCode = 'AUD';
            LBList.add(leanderB);
            
        }
        insert LBList;
           
        //Database.update(lCont, dml);
        //lenderContacts.add(new Contact(RecordTypeId=customerRTId, isLender__c=true, FirstName='Test', LastName='Lender', 
        //                               Email='testlender@test.com'));
        //update lenderContacts;
        return lenderContacts;
    }
    
    public static map<String, Lender_Balance__c> getLenderBalances(list<Contact> lenderContacts){
        map<String, Lender_Balance__c> lenderBalanceMap = new map<String, Lender_Balance__c>();
        for(Contact l: lenderContacts){
            System.debug('l recordtype '+l.RecordTypeId);
            lenderBalanceMap.put(l.Id, new Lender_Balance__c(Lender__c=l.Id, Balance__c=100));
        }
        system.debug('lenderBalanceMap.values() '+ lenderBalanceMap.values());
        try{
            upsert lenderBalanceMap.values();
        }
        catch(Exception e){
            system.debug('error '+ e);
        }
        
        system.debug('lenderBalanceMap.values() 281 '+ lenderBalanceMap.values());
        return lenderBalanceMap;
    }
    
    public static Account getFSPAccountRecord(){
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        Account fspAccount = new Account(RecordTypeId=fspRTId, Name = 'Test Account', Acronym__c='XYZ', CurrencyISOCode='PHP');
        insert fspAccount;
        return fspAccount;
    }
    
    public static ContentVersion getContentVersion(){
        ContentVersion cv = new ContentVersion(Title = 'Test Document', PathOnClient = 'TestDocument.pdf', 
                                               VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        Insert cv;
        return cv;
    }
    
    public static ContentDocumentLink getContentDocumentLink(Account acc, String cvId){
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvId].ContentDocumentId;
        //return ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        return cdl;
    }
}