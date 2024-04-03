@isTest
public class LWCLenderRepaymentSchedulerTest {
    @TestSetup
    private static void testData(){
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        list<Campaign> parentCampaignList = new list<Campaign>();
        parentCampaignList.add(new Campaign(Name='Donation', IsActive=true, Campaign_Code__c=lwcGlobalSettings.Campaign_GeneralDonation__c));
        parentCampaignList.add(new Campaign(Name='LenderBalance', IsActive=true, Campaign_Code__c=lwcGlobalSettings.Campaign_BalanceDonation__c));
        parentCampaignList.add(new Campaign(Name='AutoRelend', IsActive=true, Campaign_Code__c=lwcGlobalSettings.Campaign_AutoRelendDonation__c));
        insert parentCampaignList;
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name='Donation', IsActive=true, CurrencyIsoCode='AUD'));
        insert products;
        
        List<PricebookEntry> bookEntries = new List<PricebookEntry>();
        for(Product2 prod: products) {
         	bookEntries.add(new PricebookEntry(UnitPrice=1, Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive=true));   
        }
        insert bookEntries;
        
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
        list<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);
        list<Account> fspAccounts = LWCTestUtility.getFSPAccounts();
        system.debug('### fspAccounts size(): '+fspAccounts.size());
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
        
        String customerRTId=LWCUtility.getCustomerRecordTypeId();
        List<Contact> lenderContacts = new List<Contact>();
        set<Id> lIds = new set<Id>();
        System.debug('::'+LWCUtility.getAllActiveLenders().size());
        Contact l1 = new Contact(RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff', Street__c='Test', Ward__c='Test', 
                                    District__c='Test', City__c='Test', Country__c='Vietnam', Email='test11@example.com', IsLender__c=true
                                  );
        //for(user u : [SELECT ContactId FROM User WHERE Profile.Name = 'Lender' AND ContactId !=null LIMIT 1]){
        //    l1.Id = u.ContactId;
        //}
        insert l1;
        Contact lwcGuest = new Contact(RecordTypeId=customerRTId, FirstName='LWC Guest', LastName = 'Lender', IsLender__c=true);
        insert lwcGuest;
        
        Contact fxGain = new Contact(RecordTypeId=customerRTId, FirstName='LWC FX', LastName = 'Lender', IsLender__c=true);
        insert fxGain;
        list<String> lenderIds = new list<String>();
        list<Transaction__c> transactionList = new list<Transaction__c>();
        for(Loan__c l: loanList){
            system.debug('### Published_Amount_AUD__c: '+l.Published_Amount_AUD__c);
            transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=l1.Id, Type__c='Loan', Amount__c=25, Status__c='Completed'));
            transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=l1.Id, Type__c='Repayment', Amount__c=25, Status__c='Completed'));
            transactionList.add(new Transaction__c(Loan__c=l.Id, Lender__c=lwcGuest.Id, Type__c='Loan', Amount__c=25, Status__c='Completed'));
            l.Stage__c='Active';
            l.Actual_Loan_Principle_Disbursed_AUD__c=1500;
            l.Buffer_To_Repay__c=38.54;
            //l.Repaid_Date__c = Date.today();
        }
        insert transactionList;
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
        //system.debug('### rsToSetPayments Size: '+rsToSetPayments.size());
        Integer m=1;
        for(Repayment_Schedule__c rs: rsToSetPayments){
            rs.Repayment_Date__c=System.Today();
            if(m<3){
                rs.Principal_Repaid__c=rs.Amount_Due__c;
                rs.Repayment_Date__c=System.Today();
                rs.Status__c='Paid';
            }else if(m>=3 && m<6){
                if(m!=4){
                    rs.Principal_Repaid__c=rs.Amount_Due__c/2;
                    rs.Repayment_Date__c=System.Today();
                    rs.Status__c='Underpaid';
                    rs.Non_performing_loan_options__c='Loss of income';
                    rs.Non_performing_loan_options_other__c='test';
                }
            }else if(m>=6 && m<9){
                rs.Principal_Repaid__c=0;
                rs.Repayment_Date__c=System.Today();
                rs.Status__c='Skipped';
                rs.Non_performing_loan_options__c='Loss of income';
                rs.Non_performing_loan_options_other__c='test';
            }else{
                rs.Principal_Repaid__c=0;
                rs.Repayment_Date__c=System.Today();
                rs.Status__c='Skipped';
                rs.Non_performing_loan_options__c='Loss of income';
                rs.Non_performing_loan_options_other__c='test';
                rs.Write_Off_Request__c=true;
                rs.Comments__c='test';
            }
            m++;
        }
        update rsList;
        
        list<FSP_Monthly_Settlement__c> fmsList = new list<FSP_Monthly_Settlement__c>();
        String monthYear=LWCUtility.getMonth(month)+'-'+year;
        for(User usr: fspStaffUsers){
            fmsList.add(new FSP_Monthly_Settlement__c(FSP__c=fspAccounts[0].Id, FSP_Staff__c=usr.ContactId,
                                                      Offset_Calculation_Date__c=System.Today().addMonths(-1), Month__c=month, 
                                                      Year__c=year, Offset_Month_Year__c=monthYear, Offset_Balance_for_FSP_USD__c=20,
                                                      Below_Threshold__c=true, Offset_Clearance__c=false));
        }
        insert fmsList;
    }
    
    public testmethod static void testLWCLenderRepaymentScheduler(){
        LWCLenderRepaymentScheduler ctrl = new LWCLenderRepaymentScheduler();
        Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        Integer lastDayOfThisMonth = Date.daysInMonth(System.today().year(), System.today().month());
        Date lastDayDateOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), lastDayOfThisMonth);
        System.debug( 'F:'+firstDayOfThisMonth );
        System.debug( 'L:'+lastDayDateOfThisMonth );
        List<Repayment_Schedule__c> rSchs = [SELECT Name, Principal_Repaid__c, Repayment_Date__c, Status__c FROM Repayment_Schedule__c];
        for( Repayment_Schedule__c rSch: rSchs ){
            rSch.Principal_Repaid__c = 5;
            rSch.Status__c = 'Underpaid';
        }
        UPDATE rSchs;
        System.debug('recsss:'+[SELECT Name, Principal_Repaid__c, Repayment_Date__c, Status__c FROM Repayment_Schedule__c]);
        Test.startTest();
        String sch = '0 0 23 * * ?'; 
        system.schedule('LWCLenderRepayment', sch, ctrl);
        Test.stopTest();
    }
    
    public testmethod static void testLWCLenderRepaymentBatchScheduler(){
        List<Repayment_Schedule__c> rSchs = [SELECT Name, Principal_Repaid__c, Repayment_Date__c, Status__c FROM Repayment_Schedule__c];
        for( Repayment_Schedule__c rSch: rSchs ){
            rSch.Status__c = 'Underpaid';
        }
        UPDATE rSchs;
        Test.startTest();
        LWCLenderRepaymentScheduler uprb = new LWCLenderRepaymentScheduler();
        Database.executeBatch(uprb,50);
        Test.stopTest();
    }
}