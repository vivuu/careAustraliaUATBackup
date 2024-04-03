@isTest
public class LWCUtilityTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test user record
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'TUser',
            Username = 'managertest@queue.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id, // Replace with the correct profile name
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    }
    
    



    public testmethod static void testGetLenderTransaction(){
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
                newLoanRecViewController.getRecordTypeId(l.Id);
                rsList.add(rs);
            }
        }
        insert rsList;
        
        
        
        loanList = LWCTestUtility.submitLoanforReview(loanList);
        loanList = LWCTestUtility.updateLoansToPublish(loanList);
        list<Contact> lenders = LWCTestUtility.getLenderContacts();
        
        Test.startTest();
        LWCUtility.getLenderTransaction(lenders[0], 'Loan', 35, loanList[0].Id, 'Held');
        LWCUtility.createChatterFeed_LoanRejection('', lenders[0].Id);
        LWCUtility.sendEmailToUsers(new set<String>{fspStaffUsers[0].Id});
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testGetAllActiveLenders(){
        Test.startTest();
        LWCUtility.getAllActiveLenders();
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testGetAllActiveFSPs(){
        Test.startTest();
        LWCUtility.getAllActiveFSPs();
        Test.stopTest();
    }
    
    public testmethod static void testexecuteOffsetCalculationManually(){
        Test.startTest();
        LWCUtility.executeOffsetCalculationManually();
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testCreateChatterFeed_LoanRepayment(){
        // Create a Chatter group
        CollaborationGroup cg = new CollaborationGroup(Name = 'LWC Admin1', CollaborationType = 'Private', Description = 'LWC Admin Chatter group', CanHaveGuests = false, IsArchived = false, IsAutoArchiveDisabled = true);
        insert cg;
        Test.startTest();
        LWCUtility.createChatterFeed_LoanRepayment(cg.Id, 'test', 'test');
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testupdateFXRatesManually(){
        Test.startTest();
        LWCUtility.updateFXRatesManually();
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testgetLWCAdminUsers(){
        Test.startTest();
        LWCUtility.getLWCAdminUsers();
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testgetFinanceTeamUsers(){
        Test.startTest();
        LWCUtility.getFinanceTeamUsers();
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testgetCommunityUser(){
        Test.startTest();
        LWCUtility.getCommunityUser();
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testgetMonth(){
        Test.startTest();
        LWCUtility.getMonth(LWCUtility.getMonth(1));
        LWCUtility.getMonth(LWCUtility.getMonth(2));
        LWCUtility.getMonth(LWCUtility.getMonth(3));
        LWCUtility.getMonth(LWCUtility.getMonth(4));
        LWCUtility.getMonth(LWCUtility.getMonth(5));
        LWCUtility.getMonth(LWCUtility.getMonth(6));
        LWCUtility.getMonth(LWCUtility.getMonth(7));
        LWCUtility.getMonth(LWCUtility.getMonth(8));
        LWCUtility.getMonth(LWCUtility.getMonth(9));
        LWCUtility.getMonth(LWCUtility.getMonth(10));
        LWCUtility.getMonth(LWCUtility.getMonth(11));
        LWCUtility.getMonth(LWCUtility.getMonth(12));
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    public testmethod static void testgetLoanReviwerIsManager(){
        // Create a test user
        User testUser = [select Id,Name from User where FirstName ='Test' AND LastName='User' limit 1];
        // Create a test queue
        Group testQueue = new Group(
            Name = 'Care Loan Managers',
            Type = 'Queue'
        );
        insert testQueue;

        // Create a test contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com'
        );
        insert testContact;

        // Add the test contact to the test queue
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember testQueueMember = new GroupMember(
                GroupId = testQueue.Id,
                UserOrGroupId = testUser.Id
                
            );
            insert testQueueMember;
        }
        
        Test.startTest();
        LWCUtility.checkIfLoanReviewerIsManager(testContact.Id);
        LWCUtility.increasePerformance();
        Test.stopTest();
    }
    
    public testmethod static void testAMLCheck()
    {
         //LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
         list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        Id customerRTId = LWCUtility.getCustomerRecordTypeId();
        //LWCTestUtility.getLenderContacts();
        //List<Contact> lenderContacts=[SELECT Id,Name,RecordTypeId FROM Contact WHERE RecordTypeId=:customerRTId] ;
       	List<User> lenderUser=[SELECT Id, Name,ContactId FROM User WHERE isActive=true AND Profile.Name='Lender' AND ContactId!=null LIMIT 2];
        List<Contact> lenderContacts=new List<Contact>();
        for(User u: lenderUser)
        	lenderContacts.add(new Contact(RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true,
                                         Email='testLender@example.com',Id=u.ContactId));
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult[] sr=Database.update(lenderContacts, dml);
        list<Loan__c> getloans= LWCTestUtility.getBorrowerLoans(LWCTestUtility.getBorrowerRecords(lenderUser));
        List<String> testLenderIds=new List<string>();
        for(Contact c: lenderContacts)
        	testLenderIds.add(c.Id);
        System.debug('lender Contacts from donate test-->'+lenderContacts);
        map<String, Lender_Balance__c> lenderBalanceMap = LWCTestUtility.getLenderBalances(lenderContacts);
        System.debug('Lender balance map-->'+lenderBalanceMap);
        
        Test.startTest();
        try{
            List<Transaction__c> transactions=LWCTestUtility.getLoanTransactionList(getloans,testLenderIds);
            List<Transaction__c> transactionsR=LWCTestUtility.getRepaymentTransactionList(getloans,testLenderIds);
            List<Transaction__c> updatetrans=new List<Transaction__c>();
            for(Transaction__c t: transactions)
                updatetrans.add(t);
            
            for(Transaction__c t: transactionsR)
                updatetrans.add(t);
            
            System.debug('Transactions list-->'+updatetrans);
            List<Repayment_Schedule__c> rslist=new List<Repayment_Schedule__c>();
            for(Loan__c l:getloans)
                rslist.add(new Repayment_Schedule__c(Loan__c=l.Id,Status__c=null,Repayment_Date__c=null,Amount_Due__c=1000000, Due_Date__c=Date.today()));
            insert rslist;
            
            System.debug('Repayments from AML Test-->'+rslist);
            
            LWC_AMLScreeningScheduler ctrl = new LWC_AMLScreeningScheduler();
            // Loan__c loan=[SELECT Id FROM Loan__c Limit 1];
            //ctrl.execute(null);
            String sch = '0 0 8 * * ?'; 
            system.schedule('LWC_DonateLenderBalanceInactiveLender', sch, ctrl);
        }catch(Exception e){}
        Test.stopTest();
        
    }
      
    
    
    
}