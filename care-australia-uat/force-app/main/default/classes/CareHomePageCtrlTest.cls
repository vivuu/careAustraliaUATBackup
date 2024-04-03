@isTest(SeeAllData=true)
public class CareHomePageCtrlTest {
    static CareHomePageCtrl ctrl = new CareHomePageCtrl();
    @isTest
    public static void unitTest1(){
        Contact cont = new Contact(LastName='TestHomePageCtrl');
        INSERT cont;
        Transaction__c t = new Transaction__c(Status__c='Held',Completed_Date__c=System.now(),Type__c='Donation',Amount__c=10);
        INSERT t;
        CareHomePageCtrl.getContent('Why LWC');    
        CareHomePageCtrl.LWCSectionMetaData('HomePage');
        CareHomePageCtrl.getPdfFileAsBase64String(cont.Id, t.Id, 'LWC Transaction PDF');
        CareHomePageCtrl ctrl = new CareHomePageCtrl();
        ctrl.fillBody(cont.Id, t.Id, 'LWC Transaction PDF','');
    }
    @isTest
    static void searchLoanTest(){ 
        list<User> fspStaffUsers = [SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'FSP Staff' AND ContactId != null];
        User usr = fspStaffUsers[0];
        Id borrowerRTId = LWCUtility.getBorrowerRecordTypeId();
        Contact con = new Contact(RecordTypeId=borrowerRTId, FSP_Name__c=fspStaffUsers[0].ContactId, Published_Name__c='TB', 
                                  FSP_Client_ID__c='FSP-0000965', FirstName=usr.ContactId, LastName='Borrower', City__c='Test', 
                                  Country__c='Vietnam', Gender__c='Female', Disability__c='No', Borrower_Type__c='Individual');
        insert con;
        
        
        Loan__c lo = new Loan__c(Borrower__c=con.Id, FSP_Name__c=con.FSP_Name__c, FSP_Loan_ID__c='L-'+con.FSP_Client_ID__c, 
                                 Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-29), 
                                 Actual_Loan_Principle_Disbursed_AUD__c=24000000,
                                 Loan_Principal_Disbursed__c=24000000, Loan_Schedule__c='Monthly', CurrencyISOCode='VND', 
                                 Consent_Provided__c=true, Number_of_Employees__c=1, Jobs_Created__c=1, Female_Employees_Count__c=1,
                                 Loan_Purpose__c='Farming', CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                 Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                 Loan_Proposal_Status__c='Draft', Stage__c='New');
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        Database.SaveResult accountSaveResult = Database.insert(lo, dml);
        
        

        Test.StartTest();
        LWC_AllLoansCtrl.searchLoan(lo.FSP_Loan_ID__c);
        Test.stopTest();
    }
    
}