@isTest
public class StripeWebhookProductTest {
@TestSetup
    private static void testData(){
         list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
       /* Stripe_Product_Id__c defaults = new Stripe_Product_Id__c();
        defaults.Name = '2006CAREGifts';
        defaults.value__c = 'prod_MW6y2WdwsxIhaR';
        //setting.Name = '2006CAREGifts'; id : 
        //setting.data2__c = 'test_name2';
        insert defaults;
		*/
        //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = conList[0].id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting;
	}
    public static testMethod void testhandleProduct(){
       /*
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookProduct.handleProduct();
        Test.stopTest();
*/
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/productapi'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_1LrZX3GGWgtqSxG4jOPJk0pG","object":"event","api_version":"2020-08-27","created":1665460409,"data":{"object":{"id":"prod_Mal3NhjOEPVFdr","object":"product","active":true,"attributes":[],"created":1665460409,"default_price":null,"description":null,"images":[],"livemode":false,"metadata":{},"name":"per-day","package_dimensions":null,"shippable":null,"statement_descriptor":null,"tax_code":"txcd_00000000","type":"service","unit_label":null,"updated":1665460409,"url":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_eAPj0PFIIuDmOM","idempotency_key":"cc9144f8-acc2-4b3e-bb9f-f1b4990ff6b3"},"type":"product.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookProduct.handleProduct();
        Test.stopTest();
        
        
    }
}