@isTest
public class DonateLenderBalanceInactiveLenderTest {
    @testSetup
	public static void testDonateForInactiveLender(){
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
        
        list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        Id customerRTId = LWCUtility.getCustomerRecordTypeId();
        LWCTestUtility.getLenderContacts();
        List<Contact> lenderContacts=[SELECT Id,Name,RecordTypeId FROM Contact WHERE RecordTypeId=:customerRTId] ;
       	List<User> lenderUser=[SELECT Id, Name,ContactId FROM User WHERE isActive=true AND ContactId!=null LIMIT 2];
        list<Loan__c> getloans= LWCTestUtility.getBorrowerLoans(LWCTestUtility.getBorrowerRecords(lenderUser));
        List<String> testLenderIds=new List<string>();
        for(Contact c: lenderContacts)
        	testLenderIds.add(c.Id);
        System.debug('lender Contacts from donate test-->'+lenderContacts);
        map<String, Lender_Balance__c> lenderBalanceMap = LWCTestUtility.getLenderBalances(lenderContacts);
        System.debug('Lender balance map-->'+lenderBalanceMap);
        List<Transaction__c> transactions=LWCTestUtility.getLoanTransactionList(getloans,testLenderIds);
        System.debug('Transactions list-->'+transactions);
        
    }
        
        @isTest
        public static void positiveTest()
        {
            
        //System.debug('RS List-->'+rslist+' '+getloans.size());
        LWC_DonateLenderBalanceInactiveLender ctrl = new LWC_DonateLenderBalanceInactiveLender();
        Test.startTest();
            Loan__c loan=[SELECT Id FROM Loan__c Limit 1];
            List<Repayment_Schedule__c> rslist=new List<Repayment_Schedule__c>();
		rslist.add(new Repayment_Schedule__c(Loan__c=loan.Id,Status__c=null,Repayment_Date__c=null,Amount_Due__c=100000, Due_Date__c=Date.today().addDays(30)));
        insert rslist;
        //ctrl.execute(null);
        String sch = '0 0 8 * * ?'; 
        system.schedule('LWC_DonateLenderBalanceInactiveLender'+System.Now(), sch, ctrl);
        Test.stopTest();
        }
        
        @isTest
        public static void negativeTest()
        {
        LWC_DonateLenderBalanceInactiveLender ctrl = new LWC_DonateLenderBalanceInactiveLender();
        Test.startTest();
        //ctrl.execute(null);
        String sch = '0 0 8 * * ?'; 
        system.schedule('LWC_DonateLenderBalanceInactiveLender'+System.Now(), sch, ctrl);
        Test.stopTest();
        }
}