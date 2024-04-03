@isTest(SeeAllData=true)
public class LWCUserTriggerTest {
	public testmethod static void testScheduleRun_OffsetNonInclusive(){
        User u = [SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null limit 1];
        u.CurrencyISOCode='PHP';
        u.Country='';
        
        Test.startTest();
        	update u;
        Test.stopTest();
    }
    
    public testmethod static void testScheduleCountryBlank(){
        User u = [SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'FSP Staff' AND ContactId != null limit 1];
        u.CurrencyISOCode='PHP';
        u.Country='';
        
        Test.startTest();
        try{
            update u;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public static void testAllMethods(){
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
        loanList = LWCTestUtility.updateLoansToPublish(loanList);
        list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        list<Transaction__c> transactionList = LWCTestUtility.getLoanTransactionList(loanList, lenderIds);
        list<Repayment_Schedule__c> rsToSetPayments = LWCTestUtility.getLastMonthsRepayments();
        
        Integer m=1;
        for(Repayment_Schedule__c rs: rsToSetPayments){
            rs.Repayment_Date__c=System.Today();
            if(m<3){
                rs.Principal_Repaid__c=rs.Amount_Due__c;
                rs.Status__c='Paid';
            }else if(m>=3 && m<6){
                if(m!=4){
                    rs.Principal_Repaid__c=rs.Amount_Due__c/2;
                    rs.Status__c='Underpaid';
                    rs.Non_performing_loan_options__c='Loss of income';
                    rs.Non_performing_loan_options_other__c='test';
                }
            }else if(m>=6 && m<9){
                rs.Principal_Repaid__c=0;
                rs.Status__c='Skipped';
                rs.Non_performing_loan_options__c='Loss of income';
                rs.Non_performing_loan_options_other__c='test';
            }else{
                rs.Principal_Repaid__c=0;
                rs.Status__c='Skipped';
                rs.Non_performing_loan_options__c='Loss of income';
                rs.Non_performing_loan_options_other__c='test';
                rs.Write_Off_Request__c=true;
                rs.Comments__c='test';
            }
            m++;
        }
        update rsList;
        loanList = LWCTestUtility.submitLoanforReview(loanList);
        loanList = LWCTestUtility.updateLoansToPublish(loanList);
        loanList = LWCTestUtility.updateLoansToActive(loanList);
        list<User> lenders = LWCTestUtility.getLenderUsers();
        list<String> lenderUserIds = LWCTestUtility.getLenderUsersIds();
    }
}