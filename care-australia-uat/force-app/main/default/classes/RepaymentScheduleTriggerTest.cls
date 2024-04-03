@isTest
public class RepaymentScheduleTriggerTest {
    @TestSetup
    private static void testData(){
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
        list<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);   
    }
    
    public testmethod static void testInsert(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        for(Loan__c l: loanList){
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
        }
        Test.startTest();
        insert rsList;
        Test.stopTest();
    }
    
    public testmethod static void testUpdate(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        for(Loan__c l: loanList){
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
        }
        insert rsList;
        
        list<Repayment_Schedule__c> repayList = [Select Id, Name From Repayment_Schedule__c Where Loan__c=:loanList[0].Id];
        for(Repayment_Schedule__c rs: repayList){
            rs.Principal_Repaid__c=0;
            rs.Status__c='Skipped';
            rs.Non_performing_loan_options__c='Loss of income';
            rs.Non_performing_loan_options_other__c='Comments';
        }
        Test.startTest();
        update repayList;
        Test.stopTest();
    }
    
    public testmethod static void testDelete(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        for(Loan__c l: loanList){
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
        }
        insert rsList;
        
        Test.startTest();
        delete rsList[0];
        Test.stopTest();
    }
    
    public testmethod static void testUndelete(){
        list<Loan__c> loanList = [Select Id, Name, Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c From Loan__c];
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        for(Loan__c l: loanList){
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
        }
        insert rsList;
        delete rsList[0];
        Test.startTest();
            undelete rsList[0];
        Test.stopTest();
    }
    public testmethod static void testPerformance(){
        RepaymentScheduleTriggerHandler.increasePerformance();
    }
}