@isTest
public class StripeWebhookPaymentMethodTest {
@TestSetup
       private static void testData(){
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer',stripe_customer_id__c='cus_MWHbeeJlTnGCgG',Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        npe03__Recurring_Donation__c RD = new npe03__Recurring_Donation__c(npe03__Organization__c=conList[0].AccountId, npe03__Contact__c=conList[0].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=System.Today(), npe03__Installment_Period__c='Monthly', Payment_Gateway__c='Bambora', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active');
        insert rd;
        
           //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = conList[0].id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting;
       
        
	}
    public static testMethod void testhandlePaymentMethod(){
        list<npe03__Recurring_Donation__c> RD = [Select Id, Name from npe03__Recurring_Donation__c];
       /* Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentMethod.handlePaymentMethod();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentMethod'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_1LnF39GGWgtqSxG4d2NUhG1p","object":"event","api_version":"2020-08-27","created":1664428363,"data":{"object":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1664428360,"customer":"cus_MWHbeeJlTnGCgG","livemode":false,"metadata":{},"type":"card"}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"payment_method.attached"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentMethod.handlePaymentMethod();
        Test.stopTest();
        
    }
}