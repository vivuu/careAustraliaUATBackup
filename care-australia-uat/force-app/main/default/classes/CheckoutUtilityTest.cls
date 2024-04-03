@isTest
public class CheckoutUtilityTest {
    static String email = 'abc@gmail.com';
    static String name = 'abc';
    
    static Map<String, Object> card = new Map<String, Object>();
	static Map<String, Object> cardWrap = new Map<String, Object>{
        'card' => card
    };
    static Map<String, Object> chargeObject = new Map<String, Object>{
        'payment_method_details' => cardWrap,
        'id' => 'ch_3LJ9eSGGWgtqSxG40QnBwDhY',
        'payment_method' => 'src_1LJ9eRGGWgtqSxG46k30tvhs',
        'object' => 'charge'
    };
    static Map<String, Object> charges = new Map<String, Object>{
        'data' => new List<Object>{chargeObject}     
    }; 
    static Map<String, Object> paymentIntentResponse = new Map<String, Object>{
        'charges' => charges,
        'object' => 'payment_intent'
    };  
    
    @testSetup
    static void createTestData() {
        Stripe_Payment_Configs__mdt metadataRecords = [SELECT Donation_Campaign__c, Lend_With_Care_Campaign__c, Donation_Product_Name__c, Loan_Product_Name__c, Topup_Product_Name__c, RD_Campaign__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
        String lendWithCareCampaign = metadataRecords.Lend_With_Care_Campaign__c;
        String donationCampaign = metadataRecords.Donation_Campaign__c;
        String loanProductName = metadataRecords.Loan_Product_Name__c;
        String topUpProductName = metadataRecords.Topup_Product_Name__c;
        String donationProductName = metadataRecords.Donation_Product_Name__c;
        String rdCampaign = metadataRecords.RD_Campaign__c;
        
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name=lendWithCareCampaign, Campaign_Code__c=lendWithCareCampaign, IsActive=true));
        campaigns.add(new Campaign(Name=donationCampaign, Campaign_Code__c=donationCampaign, IsActive=true));
        campaigns.add(new Campaign(Name=rdCampaign, Campaign_Code__c=rdCampaign, IsActive=true));
        insert campaigns;
        
        campaigns[2].ParentId = campaigns[0].Id;
        update campaigns[2];
        
    	List<Product2> products = new List<Product2>();
        products.add(new Product2(Name=loanProductName, IsActive=true, CurrencyIsoCode='AUD'));
        products.add(new Product2(Name=topUpProductName, IsActive=true, CurrencyIsoCode='AUD'));
        products.add(new Product2(Name=donationProductName, IsActive=true, CurrencyIsoCode='AUD'));
        insert products;
        
        List<PricebookEntry> bookEntries = new List<PricebookEntry>();
        for(Product2 prod: products) {
         	bookEntries.add(new PricebookEntry(UnitPrice=1, Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive=true));   
        }
        insert bookEntries;
        
        card.put('brand', 'visa');
        card.put('fingerprint', 'nyNNNzbeuO4fqNe0');
        card.put('exp_month', '04');
        card.put('exp_year', '2024');
        card.put('last4', '2345');
    }
    
    @isTest
    static void processTransactionsAndPayment_whenChargeObject_WithoutLenderBalance() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Test.startTest();
        CheckoutUtility.lenderName = name;
        CheckoutUtility.processTransactionsAndPayment(transIds, con, 0, chargeObject, email);
        Test.stopTest();
        
        assertResult();
    }
    
    @isTest
    static void processTransactionsAndPayment_whenPaymentIntentObject_WithLenderBalance() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Test.startTest();
        CheckoutUtility.processTransactionsAndPayment(transIds, con, 10, paymentIntentResponse, email);
        Test.stopTest();
        
        assertResult();
    }
    
    @isTest
    static void processTransactionsAndPayment_whenPayPalObject_WithLenderBalance() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Map<String, Object> paypalObject = new Map<String, Object>{
            'object' => 'paypal',
            'id' => 'paypalOId'
        };
        
        Test.startTest();
        CheckoutUtility.processTransactionsAndPayment(transIds, con, 10, paypalObject, email);
        Test.stopTest();
        
        assertResult();
    }
    
    @isTest
    static void processRD_test() {
        card.put('brand', 'visa');
        card.put('fingerprint', 'nyNNNzbeuO4fqNe0');
        card.put('exp_month', '04');
        card.put('exp_year', '2024');
        card.put('last4', '2345');
        card.put('id', 'card_asoiio123p9op0wdks');
        
        Contact con = createContactData();
        
        Test.startTest();
        CheckoutUtility.processRD(con, 10, cardWrap);
        Test.stopTest();
    }
    
    private static void assertResult() {
        for(Transaction__c trans: [SELECT Status__c FROM Transaction__c]) {
            Assert.areEqual('Completed', trans.Status__c, 'Transaction must be completed');
        }
    }
    
    private static Contact createContactData() {
        Account acc = new Account();
        acc.Name = 'Test Contact';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Phone = '+61987654321';
        con.CurrencyIsoCode = 'AUD';
        con.Email = 'abc@gmail.com';
        con.AccountId = acc.Id;
        con.Active__c = true;
        con.IsLender__c = true;
        con.RecordTypeId = LWCUtility.getCustomerRecordTypeId();
        
        insert con;
        return con;
    }
    
    private static List<Id> createTransaction(Contact con) {
        List<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        List<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
       	List<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);
        
        List<Transaction__c> trans = new List<Transaction__c>();
        trans.add(new Transaction__c(Loan__c=loanList[0].Id, Lender__c=con.Id, Type__c='Loan', Amount__c=25, Status__c='Held',Transaction_Date__c=Date.today()));
        trans.add(new Transaction__c(Loan__c=loanList[0].Id, Lender__c=con.Id, Type__c='Donation', Amount__c=25, Status__c='Held',Transaction_Date__c=Date.today()));
        trans.add(new Transaction__c(Loan__c=loanList[0].Id, Lender__c=con.Id, Type__c='Topup', Amount__c=25, Status__c='Held',Transaction_Date__c=Date.today()));
        
        insert trans;
        
        return new List<Id>{trans[0].Id, trans[1].Id, trans[2].Id};
    }
}