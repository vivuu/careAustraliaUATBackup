@isTest
public class LoanTriggerTest {
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
        
        list<Contact> lenderContacts = LWCTestUtility.getLenderContacts();
        if(lenderContacts != null && lenderContacts.size()>0){
            list<String> lenderIds = new list<String>();
            list<Transaction__c> transactionList = new list<Transaction__c>();
            for(Loan__c l: loanList){
                system.debug('### Published_Amount_AUD__c: '+l.Published_Amount_AUD__c);
                if(lenderContacts[0].Id != null){
                    transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lenderContacts[0].Id, Type__c='Loan', Amount__c=25, Status__c='Completed'));
                    l.Stage__c='Active';
                }
            }
            try{
                insert transactionList;
            }
            catch(Exception e){
                system.debug('error Loantriggertest class 44 line '+ e);
            }
            
            update loanList;
        }
    }
    
    public testmethod static void testInsert(){
        Contact borrower = [Select Id, Name, FSP_Name__c, FSP_Client_ID__c From Contact Where Recordtype.Name='Borrower' limit 1];
        Loan__c l = new Loan__c(Borrower__c=borrower.Id, FSP_Name__c=borrower.FSP_Name__c, FSP_Loan_ID__c='L-'+borrower.FSP_Client_ID__c+'7378', 
                                Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-29), 
                                Loan_Principal_Disbursed_FSP_Txt__c='24000000', Loan_Schedule__c='Monthly', CurrencyISOCode='VND', 
                                Consent_Provided__c=true, Number_of_Employees__c=1, Jobs_Created__c=1, Female_Employees_Count__c=1,
                                Loan_Purpose__c='Farming', CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                Loan_Proposal_Status__c='Draft', Stage__c='New', Loan_Principal_Disbursed__c=24000000);
        list<Loan__c> loans = new list<Loan__c>();
        for (Integer i = 1; i <= 50; i++) {
            loans.add(new Loan__c(
                Borrower__c =borrower.Id,
                FSP_Name__c = borrower.FSP_Name__c,
                FSP_Loan_ID__c = 'L-' + borrower.FSP_Client_ID__c + i,
                Loan_Term_Months__c = 3,
                Loan_Disbursement_Date__c = System.Today().addDays(-10),
                Loan_Principal_Disbursed_FSP_Txt__c = '24000000',
                Loan_Schedule__c = 'Monthly',
                CurrencyISOCode = 'VND',
                Consent_Provided__c = true,
                Number_of_Employees__c = 1,
                Jobs_Created__c = 1,
                Female_Employees_Count__c = 1,
                Loan_Purpose__c = 'Farming',
                CA_Themes__c = 'Climate Mitigation',
                Loan_Type__c = 'Farming',
                Loan_Title__c = 'Help Farmer to grow',
                Loan_Description__c = 'So and So farmer need help in farming',
                Loan_Proposal_Status__c = 'Draft',
                Stage__c = 'New',
                Loan_Principal_Disbursed__c = 24000000
            ));
            
            
        }
        Test.startTest();
        insert l;
        
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        Decimal amount = l.Loan_Principal_Disbursed__c/l.Loan_Term_Months__c;
        //system.debug('### Loan_Principal_Disbursed__c for Loan - amount: '+l.Loan_Principal_Disbursed__c+' - '+amount);
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
        Test.stopTest();
    }
     
    public testmethod static void testUpdate(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
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
    }
    
    public testmethod static void testUpdate1(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
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
            l.Manager_Approval_Request__c=true;
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
    }
    
    public testmethod static void testUpdate2(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
        for(Loan__c l: loanList){
            l.Loan_Principal_Disbursed_USD__c=6000;
            l.Loan_Term_Months__c=10;
            l.Loan_Principal_Disbursed__c=73889255.92;
            l.Loan_Disbursement_Date__c=System.Today().addDays(-45);
        }
        update loanList;
        
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
    }
    
    public testmethod static void testDelete(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
        
        Test.startTest();
            delete loanList[0];
        Test.stopTest();
    }
    
    public testmethod static void testRepaid(){
        Loan__c loan = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c 
                                  Where Stage__c='Active' limit 1];
        
        Test.startTest();
        loan.Actual_Loan_Principle_Disbursed_AUD__c=loan.Published_Amount_AUD__c-50;
        loan.Buffer_To_Repay__c=50;
        loan.Total_Repaid_Amount_AUD__c=loan.Published_Amount_AUD__c-50;
        update loan;
        Test.stopTest();
    }
}