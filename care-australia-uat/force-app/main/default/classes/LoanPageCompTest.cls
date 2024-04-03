@IsTest
public class LoanPageCompTest {
    public static testmethod void doTest () {
        
        ApprovalComponentController.getPermissionSetDetails(UserInfo.getUserId());
		list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);
        Contact borrower = [Select Id, Name, FSP_Name__c, FSP_Client_ID__c From Contact Where Recordtype.Name='Borrower' limit 1];
        Loan__c l = new Loan__c(Borrower__c=borrower.Id, FSP_Name__c=borrower.FSP_Name__c, FSP_Loan_ID__c='L-'+borrower.FSP_Client_ID__c+'7378', 
                                Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-29), 
                                Loan_Principal_Disbursed_FSP_Txt__c='24000000', Loan_Schedule__c='Monthly', CurrencyISOCode='VND', 
                                Consent_Provided__c=true, Number_of_Employees__c=1, Jobs_Created__c=1, Female_Employees_Count__c=1,
                                Loan_Purpose__c='Farming', CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                Loan_Proposal_Status__c='Draft', Stage__c='New', Loan_Principal_Disbursed__c=24000000);
    
   		insert l;
        
		Loan__c l1=[SELECT Id FROM Loan__c LIMIT 1];
        Date dt=Date.today();
        Repayment_Schedule__c rs=LWCTestUtility.getRepaymentRecord(l1.Id, 10000.0,dt);
        insert rs;
        Test.startTest();
        newLoanRecViewController.getRecordTypeId(l1.Id);
       LoanRecordViewCompController.getLoanDetails(l1.Id);
       LoanRecordViewCompController.getRelatedRepaymentSchedules(l1.Id);
        Test.stopTest();     
    }

}