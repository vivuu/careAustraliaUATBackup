@isTest
public class LWC_TransactionTriggerTest {
	@TestSetup
    private static void testData(){
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
        list<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);
        list<Account> fspAccounts = LWCTestUtility.getFSPAccounts();
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        for(Loan__c l: loanList){
            Decimal amount = l.Loan_Principal_Disbursed__c/l.Loan_Term_Months__c;
            for(Integer j=1; j<=l.Loan_Term_Months__c; j++){
                Date dt = System.Today();
                if(j==1){
                    dt=dt.addDays(-20);
                }else if(j==2){
                    
                }else{
                    dt=dt.addDays(30);
                }
                Repayment_Schedule__c rs = LWCTestUtility.getRepaymentRecord(l.Id, amount, dt);
                rs.Loan_Repayment_Number__c=j;
                rsList.add(rs);
            }
        }
        insert rsList;
        
		loanList = LWCTestUtility.submitLoanforReview(loanList);
        loanList = LWCTestUtility.getLoansSystemRejected(loanList);
        loanList = LWCTestUtility.submitLoanforReview(loanList);
        loanList = LWCTestUtility.getLoansContentApproved(loanList);
        loanList = LWCTestUtility.getLoansReadyToPublish(loanList);
        loanList = LWCTestUtility.updateLoansToPublish(loanList);
        list<Contact> lenderContacts = LWCTestUtility.getLenderContacts();
        system.debug('lenderContacts '+lenderContacts.size());
        map<String, Lender_Balance__c> lenderBalanceMap = LWCTestUtility.getLenderBalances(lenderContacts);
        system.debug('lenderBalanceMap--> '+lenderBalanceMap);
        loanList=LWCTestUtility.updateLoansToActive(loanList);
        LWCTestUtility.getLenderUsers();
        list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        LWCTestUtility.getLoanTransactionList(loanList, lenderIds);
        LWCTestUtility.getLastMonthsRepayments();
        ContentVersion cv = LWCTestUtility.getContentVersion();
        LWCTestUtility.getContentDocumentLink(fspAccounts[0], cv.Id);
        
    }
    
    @isTest
    public static void testvalidateLenderBalance(){
        list<Transaction__c> transactionList = new list<Transaction__c>();
        list<Loan__c> loanList = [select Id from Loan__c];
        list<Contact> lenderIds = [select Id,Lender_Balance__c from Contact];
        system.debug('lenderIds 54 line '+lenderIds);
        for(Integer a=0; a<loanList.size(); a++){
                transactionList.add(new Transaction__c( Loan__c=loanList[a].Id, Lender__c=lenderIds[a].Id, Type__c='Withdrawal', Amount__c=1, Status__c='Completed'));
                a++;
            }
        //insert transactionList;
        //List<Transaction__c> transList = [select Id,Lender__c,Type__c,Amount__c,Status__c from Transaction__c];
        Test.startTest();
        LWC_TransactionTriggerHandler.validateLenderBalance(transactionList);
        Test.stopTest();
    }
    @isTest
    public static void testvalidateLenderBalanceFail(){
        list<Transaction__c> transactionList = new list<Transaction__c>();
        list<Loan__c> loanList = [select Id from Loan__c];
        list<Contact> lenderIds = [select Id,Lender_Balance__c from Contact];
        system.debug('lenderIds 54 line '+lenderIds);
        for(Integer a=0; a<loanList.size(); a++){
                transactionList.add(new Transaction__c( Loan__c=loanList[a].Id, Lender__c=lenderIds[a].Id, Type__c='Withdrawal', Amount__c=10000, Status__c='Completed'));
                a++;
            }
        //insert transactionList;
        //List<Transaction__c> transList = [select Id,Lender__c,Type__c,Amount__c,Status__c from Transaction__c];
        Test.startTest();
        LWC_TransactionTriggerHandler.validateLenderBalance(transactionList);
        Test.stopTest();
    }
    @isTest
    public static void testmanageLenderBalance(){
        list<Contact> lenderIds = [select Id from Contact];
        Set<String> ids=new Set<String>();
        for(Contact con:lenderIds){
            ids.add(con.Id);
        }
        Test.startTest();
        LWC_TransactionTriggerHandler.manageLenderBalance(ids);
        Test.stopTest();
        
    }
    @isTest
    public static void testvalidateTransaction(){
        list<Transaction__c> transactionList = new list<Transaction__c>();
        list<Loan__c> loanList = [select Id from Loan__c];
        list<Contact> lenderIds = [select Id from Contact];
        system.debug('lenderIds-->'+lenderIds.size());
        for(Integer a=0; a<loanList.size(); a++){
                transactionList.add(new Transaction__c( Loan__c=loanList[a].Id,Lender__c=lenderIds[a].Id, Type__c='Loan', Amount__c=90+a, Status__c='Completed'));
                a++;
            }
        
        //List<Transaction__c> transList = [select Id,Lender__c,Type__c,Amount__c,Status__c from Transaction__c];
        system.debug('transactionList-->'+transactionList.size());
        Test.startTest();
        LWC_TransactionTriggerHandler.validateTransaction(transactionList);
        Test.stopTest();
    }
    
    public testmethod static void testWithdrawal(){
        list<Contact> lenders = [Select Id, Name From Contact Where isLender__c=true];
        list<Transaction__c> transList = new list<Transaction__c>();
        for(Contact con: lenders){
            transList.add(new Transaction__c(Lender__c=con.Id, Type__c='Withdrawal', Amount__c=20, Status__c='Completed'));
        }
        
        Test.startTest();
        try{
            insert transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testInsertFail(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        
        Transaction__c trans = new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=20, Status__c='Completed');
        Test.startTest();
        try{
            insert trans;
            
            trans.Amount__c=l.Published_Amount_AUD__c-40;
            LWC_TransactionTriggerHandler.hasRanAfterInsert=false;
            insert trans;
            
            Transaction__c trans1 = new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=40, Status__c='Completed');
            LWC_TransactionTriggerHandler.hasRanAfterInsert=false;
            insert trans1;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testInsertFail1(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        system.debug('85 line '+ l.Id);
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=l.Published_Amount_AUD__c-20, Status__c='Completed'));
        //transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=25, Status__c='Completed'));
        Test.startTest();
        try{
            insert transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testInsertFail2(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=l.Published_Amount_AUD__c-40, Status__c='Completed'));
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=25, Status__c='Completed'));
        Test.startTest();
        try{
            insert transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testInsertFail3(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=l.Published_Amount_AUD__c-40, Status__c='Completed'));
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=45, Status__c='Completed'));
        Test.startTest();
        try{
            insert transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testInsertFail4(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=l.Published_Amount_AUD__c-40, Status__c='Completed'));
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=40, Status__c='Completed'));
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=10, Status__c='Completed'));
        Test.startTest();
        try{
            insert transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testInsertFail5(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=20, Status__c='Held'));
        Test.startTest();
        try{
            insert transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testInsertFail6(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=l.Published_Amount_AUD__c-40, Status__c='Completed'));
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=20, Status__c='Held'));
        Test.startTest();
        try{
            insert transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testUpdate(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        
        Transaction__c trans = new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=30, Status__c='Held');
        insert trans;
        Test.startTest();
        trans.Status__c='Completed';
        update trans;
        Test.stopTest();
    }
    
    public testmethod static void testDelete(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=30, Status__c='Completed'));
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=30, Status__c='Held', Added_To_Cart__c=true));
        insert transList;
        Test.startTest();
        try{
            delete transList;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public testmethod static void testUndelete(){
        Loan__c l = [Select Id, Name, Published_Amount_AUD__c From Loan__c limit 1];
        User lender = [SELECT Id, Name, ContactId FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        
        list<Transaction__c> transList = new list<Transaction__c>();
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=30, Status__c='Completed'));
        transList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lender.ContactId, Type__c='Loan', Amount__c=30, Status__c='Held', Added_To_Cart__c=true, Allow_Deletion__c=true));
        insert transList;
        Transaction__c trans = new Transaction__c();
        for(Transaction__c t: transList){
            if(t.Allow_Deletion__c==true){
                trans=t;
            }
        }
        delete trans;
        Test.startTest();
        try{
            undelete trans;
        }catch(Exception e){}
        Test.stopTest();
    }
}