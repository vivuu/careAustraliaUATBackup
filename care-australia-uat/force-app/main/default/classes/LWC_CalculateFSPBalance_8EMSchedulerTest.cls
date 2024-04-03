@isTest
public class LWC_CalculateFSPBalance_8EMSchedulerTest {
    @TestSetup
    private static void testData(){
        String customerRTId=LWCUtility.getCustomerRecordTypeId();
        Contact fxGain = new Contact(RecordTypeId=customerRTId, FirstName='LWC FX', LastName = 'Lender', IsLender__c=true);
        insert fxGain;
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);
        Account fspAccount = LWCTestUtility.getFSPAccountRecord();
        Loan__c oldLoan = new Loan__c(Borrower__c=borrowers[0].Id, FSP__c=fspAccount.Id, FSP_Name__c=borrowers[0].FSP_Name__c, FSP_Loan_ID__c='L-'+borrowers[0].FSP_Client_ID__c+'X', 
                                  Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-89), 
                                  Loan_Principal_Disbursed__c=24000000, Loan_Schedule__c='Monthly', CurrencyISOCode='VND', 
                                  Consent_Provided__c=true, Number_of_Employees__c=1, Jobs_Created__c=1, Female_Employees_Count__c=1,
                                  Loan_Purpose__c='Farming', CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                  Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                  Loan_Proposal_Status__c='Published', Stage__c='Active', Funded_Date__C=System.Today().addMonths(-2));
        insert oldLoan;
        
        list<Repayment_Schedule__c> oldrsList = new list<Repayment_Schedule__c>();
        Decimal amount1 = oldLoan.Loan_Principal_Disbursed__c/oldLoan.Loan_Term_Months__c;
        for(Integer j=1; j<=oldLoan.Loan_Term_Months__c; j++){
            Date dt = System.Today();
            if(j==1){
                dt=dt.addDays(-58);
            }else if(j==2){
                dt=dt.addDays(-28);
            }else{
                dt=dt.addDays(2);
            }
            Repayment_Schedule__c rs = LWCTestUtility.getRepaymentRecord(oldLoan.Id, amount1, dt);
            system.debug('rs-> '+rs);
            rs.Loan_Repayment_Number__c=j;
            oldrsList.add(rs);
        }
        insert oldrsList;
        
            
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
                system.debug('rs-> '+rs);
                rs.Loan_Repayment_Number__c=j;
                rsList.add(rs);
            }
        }
        insert rsList;
        
        loanList = LWCTestUtility.submitLoanforReview(loanList);
        loanList = LWCTestUtility.updateLoansToPublish(loanList);
        
        list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        //list<Transaction__c> transactionList = LWCTestUtility.getLoanTransactionList(loanList, lenderIds);
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
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Published';
            l.Stage__c='Active';
            l.Funded_Date__C=System.Today().addMonths(-2);
        }
        update loanList;
        
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        list<FSP_Monthly_Settlement__c> fmsList = new list<FSP_Monthly_Settlement__c>();
        String monthYear=LWCUtility.getMonth(month)+'-'+year;
        for(User usr: fspStaffUsers){
            fmsList.add(new FSP_Monthly_Settlement__c(FSP__c=fspAccounts[0].Id, Offset_Calculation_Date__c=System.Today().addMonths(-1), 
                                                      Month__c=month, Year__c=year, Offset_Month_Year__c=monthYear, 
                                                      Offset_Balance_for_FSP_USD__c=20, Below_Threshold__c=true, Offset_Clearance__c=false));
        }
        insert fmsList;
    }
    
    public testmethod static void testScheduleRun_OffsetNonInclusive(){
        LWC_CalculateFSPBalance_8EMScheduler ctrl = new LWC_CalculateFSPBalance_8EMScheduler();
        Test.startTest();
        //ctrl.execute(null);
        String sch = '0 0 23 * * ?'; 
        system.schedule('CalculateFSPBalance', sch, ctrl);
        Test.stopTest();
    }
    
    public testmethod static void testScheduleRun_OffsetInclusiveError(){
        list<Loan__c> loanList = [Select Id, Name,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
          system.debug('loanList--> '+loanList);
        for(Loan__c l: loanList){
            l.Include_in_Offset_Calculation__c=true;
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        for(Loan__c l: loanList){
            l.Include_in_Offset_Calculation__c=false;
        }
        
        Test.startTest();
        try{
            LoanTriggerHandler.hasRanAfterUpdate=false;
            update loanList;
        }catch(Exception e){
            system.debug('### Expected Exception: '+e.getMessage());
        }
        Test.stopTest();
    }
    
    public testmethod static void testScheduleRun_OffsetInclusive(){
        list<CollaborationGroup> groups = [SELECT Id FROM CollaborationGroup WHERE Name = 'LWC Admin1' LIMIT 1];
        system.debug('groups 153 '+groups[0].Id);
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        
        // Get the first day of the month
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        Integer lastDayOfMonth = Date.daysInMonth(year, month);
        Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        Account fspRec = [Select Id, Name From Account Where Name='TestFSP0' limit 1];
        system.debug('fspRec 162 '+fspRec);
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
            l.Include_in_Offset_Calculation__c=true;
            l.Future_Offset_Inclusion_Date__c = firstDayOfThisMonth;
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        system.debug('### loanList Size: '+loanList.size());
        for(Loan__c l: loanList){
            system.debug('### Loan_Principal_Disbursed__c: '+l.Loan_Principal_Disbursed__c);
            system.debug('### Stage__c: '+l.Stage__c);
            system.debug('### Loan_Principal_Disbursed_AUD__c: '+l.Loan_Principal_Disbursed_AUD__c);
            system.debug('### Include_in_Offset_Calculation__c: '+l.Include_in_Offset_Calculation__c);
            system.debug('### Future_Offset_Inclusion_Date__c: '+l.Future_Offset_Inclusion_Date__c);
            system.debug('### FSP_Name__c: '+l.FSP_Name__c);
            system.debug('### Funded_Date__c: '+l.Funded_Date__c);
            system.debug('### Repaid_Date__c: '+l.Repaid_Date__c);
        }
        
       // LWC_CalculateFSPBalance_8EMScheduler.fspTestAccountId=fspRec.Id;
       // LWC_CalculateFSPBalance_8EMScheduler.lwcAdminGrpId=groups[0].Id;
       // LWC_CalculateFSPBalance_8EMScheduler ctrl = new LWC_CalculateFSPBalance_8EMScheduler();
        Test.startTest();
        //ctrl.execute(null);
        String sch = '0 0 8 * * ?'; 
       // system.schedule('CalculateFSPBalance', sch, ctrl);
        Test.stopTest();
    }
}