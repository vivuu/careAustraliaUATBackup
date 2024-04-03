@isTest
public class StripeWebhookCustomerTest {
@TestSetup
    private static void testData(){
        
        /*Stripe_Setting__c recSetting = new Stripe_Setting__c();
        recSetting.name = 'Default';
        insert recsetting;
        */
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='David', LastName='Smith', Email='', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
                
       // list<Contact> conList1 = new list<Contact>();
        //conList1.add(new Contact(FirstName='David', LastName='Smith', Email='', npe01__PreferredPhone__c='Home', Phone='+61566666666'));
        //insert conList1;
        
       
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
         //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = conList[0].id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting;
        
	}
    public static testMethod void testhandleCustomer(){
       
       	list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='David', LastName='Miller', Stripe_Customer_Id__c = 'cus_MWHbeeJlTnGCgG', Email='', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/customerAPI'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_1LnF1tGGWgtqSxG46Q7PB9uJ","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"cus_MWHbeeJlTnGCgG","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"DavidSmith","next_invoice_sequence":1,"phone":"+61415345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookCustomer.handleCustomer();
        Test.stopTest();

    }
    
    public static testMethod void testhandleCustomerHomePhone(){
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/customerAPI'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_1LnF1tGGWgtqSxG46Q7PB9uJ","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"cus_MWHbeeJlTnGCgG","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"DavidSmith","next_invoice_sequence":1,"phone":"+610415345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookCustomer.handleCustomer();
        Test.stopTest();

    }
    public static testMethod void testcreateCustomer(){
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
          
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/customerAPI'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"null","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"null","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"DavidSmith","next_invoice_sequence":1,"phone":"+610215345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookCustomer.handleCustomer();
        Test.stopTest();
    }
    
    public static testMethod void testcreateCustomerPhoneNumber(){
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
          
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/customerAPI'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"null","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"null","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"DavidSmith","next_invoice_sequence":1,"phone":"+61215345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookCustomer.handleCustomer();
        Test.stopTest();
    }
    
    public static testMethod void testcreateCustomerHandlePhone2(){
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
          
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/customerAPI'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"null","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"null","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"DavidSmith","next_invoice_sequence":1,"phone":"61215345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookCustomer.handleCustomer();
        Test.stopTest();
    }
    
    public static testMethod void testcreateCustomerHandleMobilePhone(){
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
          
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/customerAPI'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"null","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"null","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"David Smith","next_invoice_sequence":1,"phone":"0415345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookCustomer.handleCustomer();
        Test.stopTest();
    }
    
    public static testMethod void testcreateCustomerHandleMobilePhone2(){
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
          
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/customerAPI'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"null","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"null","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{"firstName":"deepesh","lastName":"Bansal"},"name":"DavidSmith","next_invoice_sequence":1,"phone":"+61415345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookCustomer.handleCustomer();
        Test.stopTest();
    }
}