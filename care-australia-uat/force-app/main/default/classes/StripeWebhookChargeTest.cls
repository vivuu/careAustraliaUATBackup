@isTest
public class StripeWebhookChargeTest {
	@isTest
    static void handleCharge_test() {
        Account acc = new Account(Name='Test acc');
        insert acc;
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(AccountId=acc.Id, FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666', Stripe_Customer_Id__c='cus_OezvOgmGSxROgw', Stripe_Customer_Ids__c='cus_OezvOgmGSxROgw'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        Stripe_Setting__c recSetting = new Stripe_Setting__c();
        recSetting.Name= 'Default';
        recSetting.Default_Contact__c = conList[0].id;
        recSetting.Default_Campaign__c = camp.id;
        recSetting.Activation__c = True;
        insert recSetting;
        
        Stripe_Charge_Settings__c mc = new Stripe_Charge_Settings__c();
        mc.Name= 'Default';
        mc.Type_of_donation_source__c = 'credit card';
        insert mc;
        
        String data = '{"id":"evt_3NrfvyGGWgtqSxG40ZVqddih","object":"event","api_version":"2020-08-27","created":1695037690,"data":{"object":{"id":"ch_3NrfvyGGWgtqSxG40U8tXiA7","object":"charge","amount":12000,"amount_captured":12000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3NrfvyGGWgtqSxG40LP62vcE","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":"Test first","phone":null},"calculated_statement_descriptor":"CARE AUSTRALIA","captured":true,"created":1695037690,"currency":"usd","customer":"cus_OezvOgmGSxROgw","description":null,"destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{"IsRecurring":"true","donation_source":"credit card","opp-id":"oppId","rg-id":"rgID","custom_parameter_frequency":"1","period":"month","day_of_month":"1","effective_date":"2022-01-01","number_of_installment":"1"},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":31,"seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":null,"payment_method":"card_1NrfvfGGWgtqSxG43zgAOXta","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":"pass"},"country":"US","exp_month":4,"exp_year":2024,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","incremental_authorization":{"status":"unavailable"},"installments":null,"last4":"4242","mandate":null,"moto":null,"network":"visa","network_token":{"used":false},"three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KPvxoKgGMgYNZYvhkxY6LBZqeYJPkEpHW5VMeSTREHH60WQ1VgAH0pCJsmSURNbzG0lRU9_8HTC0IBlX","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3NrfvyGGWgtqSxG40U8tXiA7/refunds"},"review":null,"shipping":null,"source":{"id":"card_1NrfvfGGWgtqSxG43zgAOXta","object":"card","address_city":null,"address_country":null,"address_line1":null,"address_line1_check":null,"address_line2":null,"address_state":null,"address_zip":null,"address_zip_check":null,"brand":"Visa","country":"US","customer":"cus_OezvOgmGSxROgw","cvc_check":"pass","dynamic_last4":null,"exp_month":4,"exp_year":2024,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","last4":"4242","metadata":{},"name":"Test first","tokenization_method":null,"wallet":null},"source_transfer":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_h0LQtdq76AhY1z","idempotency_key":"6655757b-2177-480e-ab68-1b8073e195e2"},"type":"charge.succeeded"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/Charge'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(data);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Id[] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = conList[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        StripeWebhookCharge.handleCharge();
        Test.stopTest();
    }
}