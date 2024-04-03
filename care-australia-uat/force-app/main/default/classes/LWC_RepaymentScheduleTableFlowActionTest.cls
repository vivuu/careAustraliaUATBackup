@isTest
public class LWC_RepaymentScheduleTableFlowActionTest {
    @TestSetup
    private static void testData(){
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
        list<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);
    }
    
    public testmethod static void testdeleterecords(){
        Loan__c l = [Select Id, Name, Loan_Term_Months__c, CurrencyIsoCode, Loan_Principal_Disbursed__c, 
                     (Select Id, Name, Loan__c, Amount_Due__c, Due_Date__c, Loan_Repayment_Number__c 
                      From Repayment_Schedules__r) 
                     From Loan__c limit 1];
        
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        Decimal amount = l.Loan_Principal_Disbursed__c/l.Loan_Term_Months__c;
        for(Integer j=1; j<=l.Loan_Term_Months__c; j++){
            Date dt = System.Today();
            if(j==1){
                dt=dt.addDays(-20);
            }else if(j==2){
                
            }else{
                dt=dt.addDays(30);
            }
            rsList.add(new Repayment_Schedule__c(Loan__c=l.Id, Loan_Repayment_Number__c=j, Amount_Due__c=amount, Due_Date__c=dt));
        }
        insert rsList;
        Test.startTest();
        LWC_RepaymentScheduleTableFlowAction.deleterecords(String.valueOf(l.Id));
        Test.stopTest();
    }
    
    public testmethod static void testCreaterecords(){
        Loan__c l = [Select Id, Name, Loan_Term_Months__c, CurrencyIsoCode, Loan_Principal_Disbursed__c, 
                     (Select Id, Name, Loan__c, Amount_Due__c, Due_Date__c, Loan_Repayment_Number__c 
                      From Repayment_Schedules__r) 
                     From Loan__c limit 1];
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        Decimal amount = l.Loan_Principal_Disbursed__c/l.Loan_Term_Months__c;
        for(Integer j=1; j<=l.Loan_Term_Months__c; j++){
            Date dt = System.Today();
            if(j==1){
                dt=dt.addDays(-20);
            }else if(j==2){
                
            }else{
                dt=dt.addDays(30);
            }
            rsList.add(new Repayment_Schedule__c(Loan__c=l.Id, Loan_Repayment_Number__c=j, Amount_Due__c=amount, Due_Date__c=dt));
        }
        Test.startTest();
        LWC_RepaymentScheduleTableFlowAction.createrecords(String.valueOf(l.Id), rsList.size(), rsList);
        Test.stopTest();
    }
    
    public testmethod static void testGetRepayment(){
        list<Loan__c> loanRecords = [Select Id, Name From Loan__c limit 1];
        Test.startTest();
        LWC_RepaymentScheduleTableFlowAction.getrepayment(loanRecords[0].Id);
        Test.stopTest();
    }
    
    public testmethod static void testUpdaterecords(){
        Loan__c l = [Select Id, Name, Loan_Term_Months__c, CurrencyIsoCode, Loan_Principal_Disbursed__c, 
                     (Select Id, Name, Loan__c, Amount_Due__c, Due_Date__c, Loan_Repayment_Number__c 
                      From Repayment_Schedules__r) 
                     From Loan__c limit 1];
        
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        Decimal amount = l.Loan_Principal_Disbursed__c/l.Loan_Term_Months__c;
        for(Integer j=1; j<=l.Loan_Term_Months__c; j++){
            Date dt = System.Today();
            if(j==1){
                dt=dt.addDays(-20);
            }else if(j==2){
                
            }else{
                dt=dt.addDays(30);
            }
            rsList.add(new Repayment_Schedule__c(Loan__c=l.Id, Loan_Repayment_Number__c=j, Amount_Due__c=amount, Due_Date__c=dt));
        }
        insert rsList;
        Test.startTest();
        LWC_RepaymentScheduleTableFlowAction.updaterecords(String.valueOf(l.Id), rsList.size(), rsList);
        Test.stopTest();
    }
}