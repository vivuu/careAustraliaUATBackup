@isTest
public class StripePaymentControllerTest {
    static String email = 'abc@gmail.com';
    static String name = 'abc';
    
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
    }
    
	@isTest
    static void getStripePaymentConfigs_returnConfigs() {
        Test.startTest();
        Stripe_Payment_Configs__mdt metadataRecords = StripePaymentController.getStripePaymentConfigs();
        Test.stopTest();
        
        Stripe_Payment_Configs__mdt testMetadataRecords = [SELECT Allow_Apple_Pay__c, Allow_Credit_Card__c, Allow_Google_Pay__c, Allow_Paypal__c, VF_page_domain__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
    	
        Assert.areEqual(testMetadataRecords.Allow_Apple_Pay__c, metadataRecords.Allow_Apple_Pay__c, 'Should match Allow_Apple_Pay__c of Checkout_config');
        Assert.areEqual(testMetadataRecords.Allow_Credit_Card__c, metadataRecords.Allow_Credit_Card__c, 'Should match Allow_Credit_Card__c of Checkout_config');
        Assert.areEqual(testMetadataRecords.Allow_Google_Pay__c, metadataRecords.Allow_Google_Pay__c, 'Should match Allow_Google_Pay__c of Checkout_config');
        Assert.areEqual(testMetadataRecords.Allow_Paypal__c, metadataRecords.Allow_Paypal__c, 'Should match Allow_Paypal__c of Checkout_config');
        Assert.areEqual(testMetadataRecords.VF_page_domain__c, metadataRecords.VF_page_domain__c, 'Should match VF_page_domain__c of Checkout_config');
    }
    
    @isTest
    static void processPaymentByCard_whenContactWithoutCustomerIdNoError_postCharge() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processPaymentByCard(con.Id, 'tokenId', 'paymentTypeId', 1000, transIds, 0, email, name);
        Test.stopTest();
        
        Assert.areEqual(false, response.isError, 'isError should be false');
    }
    
    @isTest
    static void processPaymentByCard_whenContactWithoutCustomerIdErrorInCharge_returnErrorResponse() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeError());
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processPaymentByCard(con.Id, 'tokenId', 'paymentTypeId', 1000, transIds, 0, email, name);
        Test.stopTest();
        
        Assert.areEqual(true, response.isError, 'isError should be true');
    }
    
    @isTest
    static void processPaymentByCard_whenContactWithCustomerIdNoError_postCharge() {
        Contact con = createContactData();
        con.Stripe_Customer_Id__c = 'cus_5a651s56adfwe';
        update con;
        
        List<Id> transIds = createTransaction(con);
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processPaymentByCard(con.Id, 'tokenId', 'paymentTypeId', 1000, transIds, 0, email, name);
        Test.stopTest();
        
        Assert.areEqual(false, response.isError, 'isError should be false');
    }
    
    @isTest
    static void processPaymentByWallet_whenContactWithoutCustomerIdNoError_postPaymentIntent() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripePaymentIntentSuccess());
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processPaymentByWallet(con.Id, 'tokenId', 1000, transIds, 0, email, name);
        Test.stopTest();
        
        Assert.areEqual(false, response.isError, 'isError should be false');
    }
    
    @isTest
    static void processPaymentByWallet_whenContactWithoutCustomerIdErrorInCharge_returnErrorResponse() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeError());
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processPaymentByWallet(con.Id, 'tokenId', 1000, transIds, 0, email, name);
        Test.stopTest();
        
        Assert.areEqual(true, response.isError, 'isError should be true');
    }
    
    @isTest
    static void processPaymentByCard_whenContactWithCustomerIdNoError_postPaymentIntent() {
        Contact con = createContactData();
        con.Stripe_Customer_Id__c = 'cus_5a651s56adfwe';
        update con;
        List<Id> transIds = createTransaction(con);
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripePaymentIntentSuccess());
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processPaymentByWallet(con.Id, 'tokenId', 1000, transIds, 0, email, name);
        Test.stopTest();
        
        Assert.areEqual(false, response.isError, 'isError should be false');
    }
    
    @isTest
    static void processRD_Test() {
        Map<String, Object> card = new Map<String, Object>();
        card.put('brand', 'visa');
        card.put('fingerprint', 'nyNNNzbeuO4fqNe0');
        card.put('exp_month', '04');
        card.put('exp_year', '2024');
        card.put('last4', '2345');
        card.put('id', 'card_asoiio123p9op0wdks');
		Map<String, Object> cardWrap = new Map<String, Object>{
        	'card' => card
    	};
            
        Contact con = createContactData();
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeError());
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processRD(con.Id, 'tokenId', 'paymentTypeId', 1000, JSON.serialize(cardWrap));
        Test.stopTest();
        
        Assert.areEqual(true, response.isError, 'isError should be true');
    }
    
    @isTest
    static void processPayPal_test() {
        Contact con = createContactData();
        List<Id> transIds = createTransaction(con);
        
        Map<String, Object> paypalObject = new Map<String, Object>{
            'object' => 'paypal',
            'id' => 'paypalOId'
        };
        
        Test.startTest();
        StripePaymentController.StripePaymentResponseWrapper response = StripePaymentController.processPayPal(con.Id, JSON.serialize(paypalObject), transIds, 10, email, name);
        Test.stopTest();
        
        Assert.areEqual(false, response.isError, 'isError should be false');
    }
    
    private static Contact createContactData() {
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Phone = '+61987654321';
        con.CurrencyIsoCode = 'AUD';
        con.Email = 'abc@gmail.com';
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
        
        Transaction__c trans = new Transaction__c(Loan__c=loanList[0].Id, Lender__c=con.Id, Type__c='Loan', Amount__c=25, Status__c='Completed',Transaction_Date__c=Date.today());
        
        insert trans;
        return new List<Id>{trans.Id};
    }
}