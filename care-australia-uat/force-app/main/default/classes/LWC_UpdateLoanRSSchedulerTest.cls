@isTest
public class LWC_UpdateLoanRSSchedulerTest {
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
        
         Id customerRTId = LWCUtility.getCustomerRecordTypeId();
       	User LenderUser = [SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'Lender' AND ContactId != null LIMIT 1];       
        List<Contact> lenderContacts=new List<Contact>();
        lenderContacts.add(new Contact(RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true, 
                                         Auto_Relend__c=true,Email='testLender@example.com'));
        lenderContacts.add(new Contact(RecordTypeId=customerRTId, FirstName='Test2', LastName = 'Staff',IsLender__c=true,Active__c=true,
                                         Auto_Relend__c=true,Email='testLender@example.com'));
        insert lenderContacts;
        
        
        List<Lender_Balance__c> LBList = new List<Lender_Balance__c>();
        Integer i=0;
        for(Contact con:lenderContacts){
            Lender_Balance__c lenderB = new Lender_Balance__c();
            if(i==0)
            	lenderB.Balance__c= 47;
            else if(i==1)
            	lenderB.Balance__c=1000000;
            else if(i==2)
            	lenderB.Balance__c= 0;
            else if(i==3)
            	lenderB.Balance__c= 9000;
            else
                lenderB.Balance__c=0;
            lenderB.Lender__c = con.Id;
            lenderB.CurrencyIsoCode = 'AUD';
            LBList.add(lenderB);
            i++;
            
        }
        insert LBList;
        
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
                    dt=dt.addDays(-1);
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
            l.Expected_Funded_Date__c=System.Today().addDays(60);
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
    }
    
    static testmethod void testLWC_UpdateLoanRSScheduler(){
        LWC_UpdateLoanRSScheduler ctrl = new LWC_UpdateLoanRSScheduler();
        Test.startTest();
        ctrl.execute(null);
        Test.stopTest();
    }
}