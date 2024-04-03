@isTest
public class LWC_AllLoansCtrlTest {
    @TestSetup
    private static void testData(){
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
        list<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);
        list<Account> fspAccounts = LWCTestUtility.getFSPAccounts();
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document_cover';
        cv.PathOnClient = 'TestDocument_cover.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Database.insert( cv, dml );
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        //Create ContentDocumentLink 
        
        for(Loan__c l: loanList){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = l.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            cdls.add(cdl);
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
        Database.insert( rsList, dml );
        Database.insert( cdls, dml );
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
        //LWCTestUtility.getLoanTransactionList(loanList, lenderIds);
        LWCTestUtility.getLastMonthsRepayments();
        ContentVersion cv2 = LWCTestUtility.getContentVersion();
        LWCTestUtility.getContentDocumentLink(fspAccounts[0], cv2.Id);
        
    }
    
    @isTest
    public static void testLWCConfigSettingMetadata(){
        Test.startTest();
        LWC_AllLoansCtrl.LWCConfigSettingMetadata();
        Test.stopTest();
    }
    @isTest
    public static void testgetLeastToCompleteLoanRecord(){
        Test.startTest();
        LWC_AllLoansCtrl.getLeastToCompleteLoanRecord();
        Test.stopTest();
    }
    @isTest
    public static void testgetCurrentUser(){
        Test.startTest();
        LWC_AllLoansCtrl.getCurrentUser();
        List<Id> loanIds = new List<id>();
        for( Loan__c l : [SELECT Id FROM Loan__c] ){
            loanIds.add(l.Id);	
        }
        LWC_AllLoansCtrl.getContentDistribution(loanIds);
        Test.stopTest();
    }
    @isTest
    public static void testgetRDCurrentUser(){
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Contact conRec = new Contact();
        conRec.LastName = 'test1';
        conRec.KYC_Required__c = false;
        conRec.KYC_failed__c = false;
        conRec.KYC_Completed__c = true;
        
        Database.insert( conRec, dml);
        
        Cart__c cart = new Cart__c();
        cart.Last_Transaction_DateTime__c = system.now();
        cart.Contact__c = conRec.Id;
        cart.Is_Having_RD__c = true;
        Database.insert( cart, dml );
        
        Test.startTest();
        LWC_AllLoansCtrl.getRDCurrentUser(conRec.Id);
        Test.stopTest();
    }
    @isTest
    public static void testcreateTransactionRecord(){
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Contact> conList = new List<Contact>();
        Contact conRec = new Contact();
        conRec.LastName = 'test1';
        conRec.KYC_Required__c = false;
        conRec.KYC_failed__c = false;
        conRec.KYC_Completed__c = true;
        conList.add(conRec);
        if(conList.size()>0){
            Database.insert( conList, dml );
        }
        
        Lender_Balance__c LB = new Lender_Balance__c();
        LB.Balance__c = 1000;
        LB.Lender__c = conList[0].Id;
        Database.insert( LB, dml );
        
        List<Transaction__c> tranList = new List<Transaction__c>();
        List<Loan__c> loanList = [select id from Loan__c limit 10];
        //system.debug('conList[0].Id '+conList[0].Id);
        for(integer i=0; i<loanList.size(); i++){
            Transaction__c tran = new Transaction__c();
            tran.Amount__c = 25;
            tran.Type__c = 'Loan';
            tran.Loan__c = loanList[i].id;
            tran.status__c = 'Held';
            //tran.Lender__c = conList[0].Id;
            tranList.add(tran);
        }
        
        Cart__c cart = new Cart__c();
        cart.Last_Transaction_DateTime__c = system.now();
        cart.Contact__c = conList[0].Id;
        Database.insert( cart, dml );
        
        system.debug('loanList size ' + loanList.size());
        
        Test.startTest();
        //LWC_AllLoansCtrl.createTransactionRecord(tranList);
        Test.stopTest();
    }
    @isTest
    public static void testupdateTransactionRecord(){
        List<Loan__c> loanList = [select id from Loan__c limit 10];
        
        Transaction__c tran = new Transaction__c();
        tran.Amount__c = 25;
        tran.Type__c = 'Loan';
        tran.Loan__c = loanList[0].id;
        tran.status__c = 'Held';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert( tran, dml );
        
        Transaction__c trans = [select id,Amount__c from Transaction__c where Id=:tran.Id limit 1];
        trans.Amount__c = 35;
        
        Test.startTest();
        LWC_AllLoansCtrl.updateTransactionRecord(trans);
        Test.stopTest();
    }
    @isTest
    public static void testremoveTransactionRecord(){
        
        Transaction__c tran = new Transaction__c();
        tran.Amount__c = 25;
        tran.Type__c = 'Topup';
        tran.status__c = 'Held';
        tran.Added_To_Cart__c = true;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert( tran, dml );
        
        
        Test.startTest();
        LWC_AllLoansCtrl.removeTransactionRecord(tran.Id);
        Test.stopTest();
    }
    @isTest
    public static void testremoveTransactionRecords(){
        
        
        Cart__c cart = new Cart__c();
        cart.Last_Transaction_DateTime__c = system.now();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(cart,dml);
        
        List<Transaction__c> tranList = new List<Transaction__c>();
        List<Loan__c> loanList = [select id from Loan__c limit 10];
        system.debug('loanList 124'+loanList);
        for(integer i=0; i>=loanList.size(); i++){
            Transaction__c tran = new Transaction__c();
            tran.Amount__c = 25;
            tran.Type__c = 'Loan';
            tran.Loan__c = loanList[i].id;
            tran.status__c = 'Held';
            tranList.add(tran);
        }
        Database.insert( tranList, dml );
        List<Id> idToremove = new List<Id>();
        for(Transaction__c tran: tranList){
            idToremove.add(tran.Id);
        }
        Test.startTest();
        LWC_AllLoansCtrl.removeTransactionRecords(idToremove);
        Test.stopTest();
    }
    @isTest
    public static void testTopupTransactionRecords(){
        List<Contact> conList = new List<Contact>();
        Contact conRec = new Contact();
        conRec.LastName = 'test1';
        conRec.KYC_Required__c = false;
        conRec.KYC_failed__c = false;
        conRec.KYC_Completed__c = true;
        conList.add(conRec);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        if(conList.size()>0){
            Database.insert( conList, dml );
        }
        
        Lender_Balance__c LB = new Lender_Balance__c();
        LB.Balance__c = 1000;
        LB.Lender__c = conList[0].Id;
        Database.insert(LB,dml);
        
        Cart__c cart = new Cart__c();
        cart.Last_Transaction_DateTime__c = system.now();
        cart.Contact__c = conList[0].Id;
        Database.insert( cart, dml );
        
        Transaction__c tran = new Transaction__c();
        tran.Amount__c = 25;
        tran.Type__c = 'Topup';
        tran.status__c = 'Held';
        tran.Lender__c = conList[0].Id;
        tran.Added_To_Cart__c = true;
        
        Test.startTest();
        LWC_AllLoansCtrl.TopupTransactionRecords(tran);
        LWC_AllLoansCtrl.createVDTransaction(tran);
        Test.stopTest();
        
    }
    @isTest
    public static void testrecurringRecordCreation(){
        Campaign parentCampaign = new Campaign();
        parentCampaign.Name = 'Parent Campaign';
        parentCampaign.IsActive = true; 
        // Set other fields as needed
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(parentCampaign,dml);
        
        // Create the child Campaign record
        Campaign childCampaign = new Campaign();
        childCampaign.Name = 'Child Campaign';
        childCampaign.IsActive = true;
        childCampaign.ParentId = parentCampaign.Id; 
        // Set other fields as needed
        Database.insert( childCampaign, dml );
        
        
        Stripe_Setting__c stripe = new Stripe_Setting__c();
        stripe.Name='default';
        stripe.Default_Campaign__c = childCampaign.Id;
        stripe.Activation__c = true;
        Database.insert( stripe, dml );
        
        List<Contact> conList = new List<Contact>();
        Contact conRec = new Contact();
        conRec.LastName = 'test1';
        conRec.KYC_Required__c = false;
        conRec.KYC_failed__c = false;
        conRec.KYC_Completed__c = true;
        conList.add(conRec);
        if(conList.size()>0){
            Database.insert( conList, dml );
        }
        
        Cart__c cart = new Cart__c();
        cart.Last_Transaction_DateTime__c = system.now();
        cart.Contact__c = conList[0].Id;
        Database.insert( cart, dml );
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 10;
        rd.npe03__Contact__c = conList[0].Id;
        rd.npsp__RecurringType__c = 'Fixed';
        rd.Payment_Gateway__c = 'Stripe';
        rd.CurrencyIsoCode = 'AUD';
        
        Test.startTest();
        LWC_AllLoansCtrl.recurringRecordCreation(rd);
        Test.stopTest();
        
    }
    @isTest
    public static void testgetLenderBalance(){
        List<Contact> conList = new List<Contact>();
        Contact conRec = new Contact();
        conRec.LastName = 'test1';
        conRec.KYC_Required__c = false;
        conRec.KYC_failed__c = false;
        conRec.KYC_Completed__c = true;
        conList.add(conRec);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        if(conList.size()>0){
            Database.insert( conList, dml );
        }
        
        Lender_Balance__c LB = new Lender_Balance__c();
        LB.Balance__c = 1000;
        LB.Lender__c = conList[0].Id;
        Database.insert( LB, dml );
        Test.startTest();
        LWC_AllLoansCtrl.getLenderBalance(conList[0].Id);
        Test.stopTest();
    }
    @isTest
    public static void testdonateFromDashboard(){
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Contact> conList = new List<Contact>();
        Contact conRec = new Contact();
        conRec.LastName = 'test1';
        conRec.KYC_Required__c = false;
        conRec.KYC_failed__c = false;
        conRec.KYC_Completed__c = true;
        conList.add(conRec);
        if(conList.size()>0){
            Database.insert( conList, dml );
        }
        
        Lender_Balance__c LB = new Lender_Balance__c();
        LB.Balance__c = 1000;
        LB.Lender__c = conList[0].Id;
        Database.insert( LB, dml );
        
        Transaction__c tran = new Transaction__c();
        tran.Amount__c = 25;
        tran.Type__c = 'Donation';
        tran.status__c = 'Completed';
        tran.Lender__c = conList[0].Id;
        
        Test.startTest();
        LWC_AllLoansCtrl.donateFromDashboard(tran);
        Test.stopTest();
    }
    @isTest
    public static void testupdateCommunicationPreference(){
        Contact conRec = new Contact();
        conRec.LastName = 'test1';
        conRec.KYC_Required__c = false;
        conRec.KYC_failed__c = false;
        conRec.KYC_Completed__c = true;
        conRec.Email_Lendwithcare_Opt_Out__c = false;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert( conRec, dml);
        
        conRec.Email_Lendwithcare_Opt_Out__c = true;
        
        Test.startTest();
        LWC_AllLoansCtrl.updateCommunicationPreference(conRec);
        LWC_AllLoansCtrl.getCommunicationPreferences(conRec.Id);
        Test.stopTest();
    }
    
    /*public static testmethod void testLoansOnHome(){
Test.startTest();
Loan__c loan = [SELECT Id, Borrower__c, Loan_Type__c, Location_of_Business__c FROM Loan__c LIMIT 1];
LWC_AllLoansCtrl.getAllLoansAndDoc_HomePage();
LWC_AllLoansCtrl.getAllLoans_HomePage();
LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Least To Complete', null, 2);
LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Most To Complete', null, 2);
LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Oldest Loan', null, 2);
LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Most Recent Loan', null, 2);
LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Most', null, 2);
LWC_AllLoansCtrl.updateLoanFundings(loan.Id);
LWC_AllLoansCtrl.getLoanLendersInformation( loan.Id );
LWC_AllLoansCtrl.getRelatedLoans( loan.Id, loan.Loan_Type__c );
LWC_AllLoansCtrl.getLoan(loan.Id);
loan.Stage__c = 'Active';
Database.DMLOptions dml = new Database.DMLOptions(); 
dml.DuplicateRuleHeader.AllowSave = true;
Database.Update( loan, dml );
LWC_AllLoansCtrl.getAllLoansDev(loan.Borrower__c, 'All');
LWC_AllLoansCtrl.getLoanTypeCount(loan.Borrower__c);

Transaction__c tran = new Transaction__c();
tran.Amount__c = 24;
tran.Type__c = 'Loan';
tran.Loan__c = loan.id;
tran.status__c = 'Held';
tran.Lender__c = loan.Borrower__c;
Database.INSERT( tran, dml ); 

tran.Status__c='Completed';
update tran;
LWC_AllLoansCtrl.getAllLoansDev(loan.Borrower__c, 'All');
LWC_AllLoansCtrl.getAlert();
Cart__c c = new Cart__c(Contact__c=loan.Borrower__c);
Database.insert(c,dml);
LWC_AllLoansCtrl.getLoansByStage( 'Held',loan.Borrower__c );
LWC_AllLoansCtrl.getLoanSchedules( loan.Id );
LWC_AllLoansCtrl.getLoanDetails( loan.Id );
LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2','Yest', System.today() );
LWC_AllLoansCtrl.getContactInfo( loan.Borrower__c );
LWC_AllLoansCtrl.getImpactInfo();
LWC_AllLoansCtrl.LWCConfigSettingMetadata( );
LWC_AllLoansCtrl.getLoanDetailsForCart( new List<Id>{loan.Id} );
LWC_AllLoansCtrl.getLeastToCompleteLoanRecord( );
LWC_AllLoansCtrl.createTransactionRecord( new List<Transaction__c>{new Transaction__c(Amount__c = 24,Type__c = 'Loan',Loan__c = loan.id,status__c = 'Held',Lender__c = loan.Borrower__c)} );
LWC_AllLoansCtrl.updateTransactionRecord( tran );
LWC_AllLoansCtrl.updateTransactionRecords( new List<Id>{tran.Id}, loan.Borrower__c );
LWC_AllLoansCtrl.updateTransactionRecordsAfterPayment( new List<Id>{tran.Id}, loan.Borrower__c );
LWC_AllLoansCtrl.getLoanTypes( );
LWC_AllLoansCtrl.isGuestUser( );
LWC_AllLoansCtrl.getMinOtherCurrency( );
Contact cont = new Contact( Id = loan.Borrower__c, Email_Lendwithcare_Opt_Out__c=false );
Database.UPDATE( cont, dml );
LWC_AllLoansCtrl.updateCommunicationPreferences( cont );
LWC_AllLoansCtrl.updateCommunicationPreference( cont );
cont = new Contact( Id = loan.Borrower__c, Email_Lendwithcare_Opt_Out__c=true );
Database.UPDATE( cont, dml );
LWC_AllLoansCtrl.updateCommunicationPreference( cont );
LWC_AllLoansCtrl.updateCommunicationPreferences( cont );
tran.Type__c = 'Withdrawal';
Database.UPDATE( tran, dml );
LWC_AllLoansCtrl.getContactInfo( loan.Borrower__c );
LWC_AllLoansCtrl.getImpactInfo();
//LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2' );
LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2','Yest', System.today() );
tran.Type__c = 'Donation';
Database.UPDATE( tran, dml );
LWC_AllLoansCtrl.getContactInfo( loan.Borrower__c );
LWC_AllLoansCtrl.getImpactInfo();
//LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2' );
LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2','Yest', System.today() );
Map<String,String> nMap = new Map<String,String>();
nMap.put( 'fromAmount','1' );
nMap.put( 'toAmount','24' );
LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'MostRecent', nMap );
LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'Oldest', nMap );
LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'HighestLowest', nMap );
LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'LowestHighest', nMap );

//LWC_AllLoansCtrl.createLead( 'Test121', 'Test112LName', 'tes11t@te11st.com');
Test.stopTest();
}*/
    
    public static testmethod void testLoansOnHome1(){
        Test.startTest();
        Loan__c loan = [SELECT Id, Borrower__c, Loan_Type__c, Location_of_Business__c FROM Loan__c LIMIT 1];
        LWC_AllLoansCtrl.getAllLoansAndDoc_HomePage();
        LWC_AllLoansCtrl.getAllLoans_HomePage();
        LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Least To Complete', null, 2);
        LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Most To Complete', null, 2);
        LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Oldest Loan', null, 2);
        LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Most Recent Loan', null, 2);
        LWC_AllLoansCtrl.getAllLoans( loan.Loan_Type__c, loan.Location_of_Business__c, 'Most', null, 2);
        LWC_AllLoansCtrl.updateLoanFundings(loan.Id);
        LWC_AllLoansCtrl.getLoanLendersInformation( loan.Id );
        LWC_AllLoansCtrl.getRelatedLoans( loan.Id, loan.Loan_Type__c );
        LWC_AllLoansCtrl.getLoan(loan.Id);
        loan.Stage__c = 'Active';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.Update( loan, dml );
        LWC_AllLoansCtrl.getAllLoansDev(loan.Borrower__c, 'All');
        LWC_AllLoansCtrl.getLoanTypeCount(loan.Borrower__c);
        Test.stopTest();
    }
    
    public static testmethod void testLoansOnHome2(){
        Test.startTest();
        Loan__c loan = [SELECT Id, Borrower__c, Loan_Type__c, Location_of_Business__c FROM Loan__c LIMIT 1];
        loan.Stage__c = 'Active';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.Update( loan, dml );
        
        Transaction__c tran = new Transaction__c();
        tran.Amount__c = 24;
        tran.Type__c = 'Loan';
        tran.Loan__c = loan.id;
        tran.status__c = 'Completed';
        tran.Lender__c = loan.Borrower__c;
        Database.INSERT( tran, dml ); 
        
        LWC_AllLoansCtrl.getAllLoansDev(loan.Borrower__c, 'All');
        LWC_AllLoansCtrl.getAlert();
        Cart__c c = new Cart__c(Contact__c=loan.Borrower__c);
        Database.insert(c,dml);
        LWC_AllLoansCtrl.getLoansByStage( 'Held',loan.Borrower__c );
        LWC_AllLoansCtrl.getLoanSchedules( loan.Id );
        LWC_AllLoansCtrl.getLoanDetails( loan.Id );
        LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2','Yest', System.today(),true  );
        LWC_AllLoansCtrl.getContactInfo( loan.Borrower__c );
        LWC_AllLoansCtrl.getImpactInfo();
        LWC_AllLoansCtrl.LWCConfigSettingMetadata( );
        LWC_AllLoansCtrl.getLoanDetailsForCart( new List<Id>{loan.Id} );
        LWC_AllLoansCtrl.getLeastToCompleteLoanRecord( );
        LWC_AllLoansCtrl.createTransactionRecord( new List<Transaction__c>{new Transaction__c(Amount__c = 24,Type__c = 'Loan',Loan__c = loan.id,status__c = 'Held',Lender__c = loan.Borrower__c)} );
        LWC_AllLoansCtrl.updateTransactionRecord( tran );
        LWC_AllLoansCtrl.updateTransactionRecords( new List<Id>{tran.Id}, loan.Borrower__c );
        LWC_AllLoansCtrl.updateTransactionRecordsAfterPayment( new List<Id>{tran.Id}, loan.Borrower__c );
        LWC_AllLoansCtrl.getLoanTypes( );
        LWC_AllLoansCtrl.isGuestUser( );
        LWC_AllLoansCtrl.getMinOtherCurrency( );
        Contact cont = new Contact( Id = loan.Borrower__c, Email_Lendwithcare_Opt_Out__c=false );
        Database.UPDATE( cont, dml );
        LWC_AllLoansCtrl.updateCommunicationPreferences( cont );
        LWC_AllLoansCtrl.updateCommunicationPreference( cont );
        cont = new Contact( Id = loan.Borrower__c, Email_Lendwithcare_Opt_Out__c=true );
        Database.UPDATE( cont, dml );
        LWC_AllLoansCtrl.updateCommunicationPreference( cont );
        LWC_AllLoansCtrl.updateCommunicationPreferences( cont );
        tran.Type__c = 'Withdrawal';
        Database.UPDATE( tran, dml );
        LWC_AllLoansCtrl.getContactInfo( loan.Borrower__c );
        LWC_AllLoansCtrl.getImpactInfo();
        //LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2' );
        LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2','Yest', System.today(),true );
        tran.Type__c = 'Donation';
        Database.UPDATE( tran, dml );
        LWC_AllLoansCtrl.getContactInfo( loan.Borrower__c );
        LWC_AllLoansCtrl.getImpactInfo();
        //LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2' );
        LWC_AllLoansCtrl.putContactInfo( loan.Borrower__c, 'Test', 'Test2','Yest', System.today(),true );
        Map<String,String> nMap = new Map<String,String>();
        nMap.put( 'fromAmount','1' );
        nMap.put( 'toAmount','24' );
        LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'MostRecent', nMap );
        LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'Oldest', nMap );
        LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'HighestLowest', nMap );
        LWC_AllLoansCtrl.getYourTransactionDetails( 'All', loan.Borrower__c, false,'LowestHighest', nMap );
        Test.stopTest();
    }
    //Search Loan is covered in homePageCtrlTest
    
    @isTest
    static void getCreditCardDetail_test() {
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name='parent', Campaign_Code__c='parent', IsActive=true));
        campaigns.add(new Campaign(Name='child', Campaign_Code__c='child', IsActive=true));
        Database.Insert( campaigns, dml);
        
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test $' + 50;
        opp.AccountId = con.AccountId;
        opp.ContactId = con.Id;
        opp.CurrencyIsoCode = 'AUD';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        opp.Donation_Source__c = 'Web';
        opp.Amount = 50;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get('LendWithCare').getRecordTypeId();
        opp.CampaignId = campaigns[1].Id;
        Database.insert(opp, dml);
        
        npe01__OppPayment__c payment = new npe01__OppPayment__c();
        payment.npe01__Payment_Method__c = 'Credit Card';
        payment.Card_Number_Masked__c = '*************4242';
        payment.npe01__Paid__c = true;
        payment.npe01__Opportunity__c = opp.Id;
        payment.npe01__Payment_Amount__c = 20;
        Database.insert( payment, dml );
        
        Test.startTest();
        LWC_AllLoansCtrl.getCreditCardDetail(con.Id, 20);
        Test.stopTest();
    }
    
    @isTest
    static void refundAndDonate_test() {
        Id customerRTId = LWCUtility.getCustomerRecordTypeId();
        User LenderUser = [SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null LIMIT 1];
        
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name='parent', Campaign_Code__c='parent', IsActive=true));
        campaigns.add(new Campaign(Name='child', Campaign_Code__c='child', IsActive=true));
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert( campaigns, dml );
        
        List<Contact> lenderContacts=new List<Contact>();
        lenderContacts.add(new Contact(RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true, 
                                       Email='testLender@example.com'));
        //lenderContacts.add(new Contact(RecordTypeId=customerRTId, FirstName='Test2', LastName = 'Staff',IsLender__c=true,Active__c=true,
        //Email='testLender@example.com'));
        
        Database.insert( lenderContacts, dml );
        List<Lender_Balance__c> LBList = new List<Lender_Balance__c>();
        for(Contact con:lenderContacts){
            Lender_Balance__c leanderB = new Lender_Balance__c();
            leanderB.Balance__c= 1000;
            leanderB.Lender__c = con.Id;
            leanderB.CurrencyIsoCode = 'AUD';
            LBList.add(leanderB);
            
        }
        Database.insert(LBList,dml);
        
        Contact con = lenderContacts[0];
        Opportunity opp = new Opportunity();
        opp.Name = 'Test $' + 50;
        opp.AccountId = con.AccountId;
        opp.ContactId = con.Id;
        opp.CurrencyIsoCode = 'AUD';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        opp.Donation_Source__c = 'Web';
        opp.Amount = 50;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get('LendWithCare').getRecordTypeId();
        opp.CampaignId = campaigns[1].Id;
        Database.insert( opp, dml );
        
        npe01__OppPayment__c payment = new npe01__OppPayment__c();
        payment.npe01__Payment_Method__c = 'Credit Card';
        payment.Card_Number_Masked__c = '*************4242';
        payment.npe01__Paid__c = true;
        payment.npe01__Opportunity__c = opp.Id;
        payment.npe01__Payment_Amount__c = 20;
        payment.npe01__Check_Reference_Number__c = 'ch_adsfp320';
        Database.insert(payment,dml);
        
        Test.setMock(HttpCalloutMock.class, new InvoiceStripeChargeSuccess());
        
        Test.startTest();
        LWC_AllLoansCtrl.refundAndDonate(con.Id, 1, 1, '*************4242');
        Test.stopTest();
    }
    
    @IsTest
    static void refundAndDonate_WithCaseCreationOne() {
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name='parent', Campaign_Code__c='parent', IsActive=true));
        campaigns.add(new Campaign(Name='child', Campaign_Code__c='child', IsActive=true));
        Database.insert( campaigns, dml );
        
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        con.Number_of_Refunds__c = 3;
        con.Last_Refund_Date__c = System.now();
        Database.update( con, dml );
        
        Test.startTest();
        LWC_AllLoansCtrl.refundAndDonate(con.Id, 1, 1, '*************4242');
        Test.stopTest();        
    }
    
    @IsTest
    static void refundAndDonate_WithCaseCreationTwo() {
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name='parent', Campaign_Code__c='parent', IsActive=true));
        campaigns.add(new Campaign(Name='child', Campaign_Code__c='child', IsActive=true));
        Database.insert( campaigns, dml );
        
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        
        Test.startTest();
        LWC_AllLoansCtrl.refundAndDonate(con.Id, 1000, 0, '*************4242');
        Test.stopTest();        
    }
    
    @IsTest
    static void refundAndDonate_WithCaseCreationNoCharge() {
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name='parent', Campaign_Code__c='parent', IsActive=true));
        campaigns.add(new Campaign(Name='child', Campaign_Code__c='child', IsActive=true));
        Database.insert( campaigns, dml );
        
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        
        Test.startTest();
        LWC_AllLoansCtrl.refundAndDonate(con.Id, 2, 0, '*************4242');
        Test.stopTest();        
    }
    
    @isTest
    static void testCreateLead() {
        String fName = 'John';
        String lName = 'Doe';
        String email = 'john.doe@example.com';
        Test.startTest();
        String result = LWC_AllLoansCtrl.createLead(fName, lName, email);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testGetLogOutURL() {
        Test.startTest();
        String result = LWC_AllLoansCtrl.getLogOutURL();
        Test.stopTest(); 
    }
    
    @isTest
    static void testGetUserEmail() {
        Test.startTest();
        String userEmail = LWC_AllLoansCtrl.getUserEmail();
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateAutoRelend() {
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Auto_Relend__c=false);
        insert testContact;
        Test.startTest();
        LWC_AllLoansCtrl.updateAutoRelend(testContact.Id, true);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateDonationRecord() {
        
       // Create a test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com'
        );
        insert testContact;

        // Create a test Cart record related to the test Contact
        Cart__c testCart = new Cart__c(Contact__c = testContact.Id);
        insert testCart;

        // Create a test Cart Item record related to the test Cart
        Cart_Items__c testCartItem = new Cart_Items__c(
            Cart__c = testCart.Id,
            Type__c = 'Donation',
            Amount__c = 50.00 // You can adjust the amount as needed
        );
        insert testCartItem;

        Test.startTest();
        Transaction__c result = LWC_AllLoansCtrl.updateDonationRecord(10.00, testContact.Id, true,'12345678');
        Test.stopTest();

    }
    private class InvoiceStripeChargeSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "ch_503as6asdas"}');
            res.setStatusCode(200);
            return res;
        }
    }
}