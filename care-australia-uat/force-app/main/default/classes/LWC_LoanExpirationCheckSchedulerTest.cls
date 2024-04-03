@isTest
public class LWC_LoanExpirationCheckSchedulerTest {
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
        list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        list<Transaction__c> transactionList = LWCTestUtility.getLoanTransactionList(loanList, lenderIds);
    }
    
    public testmethod static void testScheduleRun_OffsetInclusive(){
        LWC_LoanExpirationCheckScheduler ctrl = new LWC_LoanExpirationCheckScheduler();
        Test.startTest();
        String sch = '0 0 8 * * ?'; 
        system.schedule('LoanExpirationCheck', sch, ctrl);
        Test.stopTest();
    }
}