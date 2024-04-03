@isTest
public class StripeWebhookSubscriptionTest {
@TestSetup	
    private static void testData(){
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(
            npe03__Organization__c=conList[0].AccountId, 
            npe03__Contact__c=conList[0].Id, 
            npe03__Amount__c=500, 
            npe03__Recurring_Donation_Campaign__c=camp.Id, 
            npsp__CardExpirationMonth__c='12', 
            npsp__CardExpirationYear__c='2034', 
            npsp__CardLast4__c='4242', 
            Card_Number_Masked__c='', 
            Card_Token__c='', 
            Card_Type__c='Visa', 
            npsp__StartDate__c=System.Today(), 
            npe03__Installment_Period__c='Monthly', 
            Payment_Gateway__c='Bambora', 
            npsp__PaymentMethod__c='Credit Card',
            Stripe_Subscription_Id__c='sub_1LnFHbGGWgtqSxG4HZOrRj2u',
            npsp__Status__c='Active');
        insert rd;
        
        //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = conList[0].id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting;
        
    }
    
    public static testMethod void testhandleRecurringDonation(){
       list<npe03__Recurring_Donation__c> rd = [Select Id, Name from npe03__Recurring_Donation__c];        
        
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/RD'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_1LnFHcGGWgtqSxG4Tt3LHvJA","object":"event","api_version":"2020-08-27","created":1664429260,"data":{"object":{"id":"sub_1LnFHbGGWgtqSxG4HZOrRj2u","object":"subscription","application":null,"application_fee_percent":null,"automatic_tax":{"enabled":false},"billing_cycle_anchor":1664546400,"billing_thresholds":null,"cancel_at":1690588800,"cancel_at_period_end":false,"canceled_at":1664429259,"collection_method":"charge_automatically","created":1664429259,"currency":"aud","current_period_end":1664546400,"current_period_start":1664429259,"customer":"cus_MaqNgZCf0WUlah","days_until_due":null,"default_payment_method":null,"default_source":"card_1LtqyZGGWgtqSxG4c7qq1Gaf","default_tax_rates":[],"description":null,"discount":null,"ended_at":null,"items":{"object":"list","data":[{"id":"si_MWHrNd0SRx6VA0","object":"subscription_item","billing_thresholds":null,"created":1664429259,"metadata":{},"plan":{"id":"price_1LnFHbGGWgtqSxG4kCsTDbpg","object":"plan","active":false,"aggregate_usage":null,"amount":1000,"amount_decimal":"1000","billing_scheme":"per_unit","created":1664429259,"currency":"aud","interval":"month","interval_count":1,"livemode":false,"metadata":{},"nickname":null,"product":"prod_MW6y2WdwsxIhaR","tiers_mode":null,"transform_usage":null,"trial_period_days":null,"usage_type":"licensed"},"price":{"id":"price_1LnFHbGGWgtqSxG4kCsTDbpg","object":"price","active":false,"billing_scheme":"per_unit","created":1664429259,"currency":"aud","custom_unit_amount":null,"livemode":false,"lookup_key":null,"metadata":{},"nickname":null,"product":"prod_MW6y2WdwsxIhaR","recurring":{"aggregate_usage":null,"interval":"month","interval_count":1,"trial_period_days":null,"usage_type":"licensed"},"tax_behavior":"unspecified","tiers_mode":null,"transform_quantity":null,"type":"recurring","unit_amount":1000,"unit_amount_decimal":"1000"},"quantity":1,"subscription":"sub_1LnFHbGGWgtqSxG4HZOrRj2u","tax_rates":[]}],"has_more":false,"total_count":1,"url":"/v1/subscription_items?subscription=sub_1LnFHbGGWgtqSxG4HZOrRj2u"},"latest_invoice":"in_1LnFHbGGWgtqSxG44g8HF9QZ","livemode":false,"metadata":{"salesforce_rd_id":"a099t000000LldRAAS"},"next_pending_invoice_item_invoice":null,"pause_collection":null,"payment_settings":{"payment_method_options":null,"payment_method_types":null,"save_default_payment_method":"off"},"pending_invoice_item_interval":null,"pending_setup_intent":null,"pending_update":null,"plan":{"id":"price_1LnFHbGGWgtqSxG4kCsTDbpg","object":"plan","active":false,"aggregate_usage":null,"amount":1000,"amount_decimal":"1000","billing_scheme":"per_unit","created":1664429259,"currency":"aud","interval":"month","interval_count":1,"livemode":false,"metadata":{},"nickname":null,"product":"prod_MW6y2WdwsxIhaR","tiers_mode":null,"transform_usage":null,"trial_period_days":null,"usage_type":"licensed"},"quantity":1,"schedule":null,"start_date":1664429259,"status":"active","test_clock":null,"transfer_data":null,"trial_end":null,"trial_start":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_kzuwTKBbHNjcdx","idempotency_key":"a5c19c79-edd7-4ef2-a200-ffe1d55415bb"},"type":"customer.subscription.created"}');
    	RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookSubscription.handleRecurringDonation();
        Test.stopTest();
    }
    
}