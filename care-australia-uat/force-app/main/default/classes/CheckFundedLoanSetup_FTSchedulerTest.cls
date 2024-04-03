@isTest
public class CheckFundedLoanSetup_FTSchedulerTest {
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
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Under Review';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='System Rejected';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Under Review';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Content Approved';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Ready To Publish';
            l.Stage__c='Scheduled';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Published';
            l.Stage__c='Fundraising';
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        map<String, User> lendersMap = new map<String, User>();
        list<User> lenderUsers = [SELECT Id, FirstName, LastName, ContactId, Email FROM User 
                                  WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null];
        for(User usr: lenderUsers){
            lendersMap.put(usr.ContactId, usr);
        }
        
        list<String> lenderIds = new list<String>();
        lenderIds.addAll(lendersMap.keyset());
        
        /*list<Contact> conList = new list<Contact>();
        for(String lId: lendersMap.keyset()){
            conList.add(new Contact(Id= lId, IsLender__c=true, RecordTypeId=LWCUtility.getCustomerRecordTypeId()));
        }
        update conList;*/
        
        list<Transaction__c> transactionList = new list<Transaction__c>();
        for(Loan__c l: loanList){
            system.debug('### Published_Amount_AUD__c: '+l.Published_Amount_AUD__c+' - '+lendersMap.size());
            for(Integer a=0; a<lendersMap.size(); a++){
                transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lenderIds[a], Type__c='Loan', Amount__c=25, Status__c='Completed'));
            }
            l.Stage__c='Active';
        }
        try{
            insert transactionList;
        }
        catch(Exception e){
            system.debug('error in checkfundedloansetup 95 '+ e);
        }
        
        update loanList;
        
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
    }
    
    public testmethod static void testScheduleRun_OffsetNonInclusive(){
        list<CollaborationGroup> groups = [SELECT Id FROM CollaborationGroup WHERE Name = 'LWC Admin1' LIMIT 1];
        
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        
        // Get the first day of the month
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        Integer lastDayOfMonth = Date.daysInMonth(year, month);
        Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        Account fspRec = [Select Id, Name From Account Where Name='TestFSP0' limit 1];
        list<Loan__c> loanList = [Select Id, Name, FSP_Name__c, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c, 
                                  Include_in_Offset_Calculation__c, Funded_Date__c, Future_Offset_Inclusion_Date__c, Stage__c, Repaid_Date__c
                                  From Loan__c 
                                  Where Stage__c='Active' AND Loan_Principal_Disbursed_AUD__c>0 AND Repaid_Date__c=NULL
                                  AND Include_in_Offset_Calculation__c=false];
        system.debug('### loanList Size: '+loanList.size());
        List<User> usr = [Select Id, Name, ContactId, Contact.Name, Contact.AccountId From User Where Profile.Name='FSP Staff' AND isActive=true LIMIT 1];
        for(Loan__c l: loanList){
            l.FSP_Name__c = usr[0].ContactId;
            System.debug('FSPNAM:'+l.FSP_Name__c);
            l.Funded_Date__c=firstDayOfMonth;
            //l.Include_in_Offset_Calculation__c=true;
            //l.Future_Offset_Inclusion_Date__c = firstDayOfThisMonth;
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        CheckFundedLoanSetup_FTScheduler.lwcAdminGrpId=groups[0].Id;
        CheckFundedLoanSetup_FTScheduler ctrl = new CheckFundedLoanSetup_FTScheduler();
        Test.startTest();
        String sch = '0 0 23 * * ?'; 
        system.schedule('CheckFundedLoanSetup_FTScheduler', sch, ctrl);
        Test.stopTest();
    }
}