@isTest
public class LWC_DataCleanUpSchedulerTest {
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
            l.Expected_Funded_Date__c=System.Today().addDays(60);
        }
        LoanTriggerHandler.hasRanAfterUpdate=false;
        update loanList;
        
        list<Contact> lenderContacts = LWCTestUtility.getLenderContacts();
        list<Cart__c> carts = new list<Cart__c>();
        for(Contact con: lenderContacts){
            carts.add(new Cart__c(Contact__c=con.Id, CurrencyIsoCode='AUD', Last_Transaction_DateTime__c=System.Now().addMinutes(-60)));
        }
        insert carts;
        
        list<Cart_Items__c> ciList = new list<Cart_Items__c>();
        for(Cart__c c: carts){
            ciList.add(new Cart_Items__c(Cart__c=c.Id, Amount__c=30, CurrencyIsoCode='AUD', Lender__c=c.Contact__c, Loan__c=loanList[0].Id, Type__c='Loan'));
        }
        insert ciList;
        
        list<Transaction__c> transList = new list<Transaction__c>();
        for(Cart_Items__c ci: ciList){
            transList.add(new Transaction__c(Cart_Items__c=ci.Id, Added_To_Cart__c=true, Amount__c=30, CurrencyIsoCode='AUD', Lender__c=ci.Lender__c, Loan__c=ci.Loan__c, Type__c='Loan', Status__c='Held'));
        }
        insert transList;
    }
    
    public testmethod static void testRollup(){
        LWC_DataCleanUpScheduler ctrl = new LWC_DataCleanUpScheduler();
        Test.startTest();
        System.debug('LLS::'+[SELECT Stage__c FROM Loan__c]);
        ctrl.execute(null);
        Test.stopTest();
    }
}