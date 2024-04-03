@isTest
public class StripeWebhookInvoiceTest {
@TestSetup
    private static void testData(){
         list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
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
    public static testMethod void testhandleInvoice(){
       
       /* Test.startTest();
        
        StripeWebhookInvoice.handleInvoice();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/invoiceAPI'; //Request URL
        req.httpMethod = 'POST';
       
        //subscription json
       // req.requestBody = blob.valueOf('{"id":"evt_1LnF1tGGWgtqSxG46Q7PB9uJ","object":"event","api_version":"2020-08-27","created":1664428285,"data":{"object":{"id":"cus_MWHbeeJlTnGCgG","object":"customer","address":null,"balance":0,"created":1664428285,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"Davidemailpersonal@testemail.com","invoice_prefix":"B998E4F6","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"DavidSmith","next_invoice_sequence":1,"phone":"+61415345623","preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_g6js4MpzjvS1Z3","idempotency_key":"b62da7d3-80c5-4157-bb0c-94df27c5fcfa"},"type":"customer.created"}');
        req.requestBody = blob.valueof('{"id":"evt_1LrCT8GGWgtqSxG46dXapO6b","object":"event","api_version":"2020-08-27","created":1665371754,"data":{"object":{"id":"in_1LrCT6GGWgtqSxG46LCezZyZ","object":"invoice","account_country":"AU","account_name":"CareAustralia","account_tax_ids":null,"amount_due":5000,"amount_paid":5000,"amount_remaining":0,"application":null,"application_fee_amount":null,"attempt_count":1,"attempted":true,"auto_advance":false,"automatic_tax":{"enabled":false,"status":null},"billing_reason":"subscription_create","charge":"ch_3LrCT6GGWgtqSxG411hkUqku","collection_method":"charge_automatically","created":1665371752,"currency":"aud","custom_fields":null,"customer":"cus_MaN81EyvsZ22po","customer_address":null,"customer_email":"emilytest@testemail.com","customer_name":"EmilyJohn","customer_phone":"+61252356342","customer_shipping":null,"customer_tax_exempt":"none","customer_tax_ids":[],"default_payment_method":null,"default_source":null,"default_tax_rates":[],"description":null,"discount":null,"discounts":[],"due_date":null,"ending_balance":0,"footer":null,"from_invoice":null,"hosted_invoice_url":"https://invoice.stripe.com/i/acct_1LIkLGGGWgtqSxG4/test_YWNjdF8xTElrTEdHR1dndHFTeEc0LF9NYU5EQVQ1NWpwa1pFSk55UlcyUkdPOWhva3VnU1RzLDU1OTEyNTU00200CKcyHvdr?s=ap","invoice_pdf":"https://pay.stripe.com/invoice/acct_1LIkLGGGWgtqSxG4/test_YWNjdF8xTElrTEdHR1dndHFTeEc0LF9NYU5EQVQ1NWpwa1pFSk55UlcyUkdPOWhva3VnU1RzLDU1OTEyNTU00200CKcyHvdr/pdf?s=ap","last_finalization_error":null,"latest_revision":null,"lines":{"object":"list","data":[{"id":"il_1LrCT6GGWgtqSxG49HgwpSwW","object":"line_item","amount":5000,"amount_excluding_tax":5000,"currency":"aud","description":"5000×2006CAREGifts(at$0.01/week)","discount_amounts":[],"discountable":true,"discounts":[],"livemode":false,"metadata":{"salesforce_rd_id":"a099t000000OGGXAA4"},"period":{"end":1665976551,"start":1665371751},"plan":{"id":"price_1LrCT5GGWgtqSxG4QuTxtmJ7","object":"plan","active":false,"aggregate_usage":null,"amount":1,"amount_decimal":"1","billing_scheme":"per_unit","created":1665371751,"currency":"aud","interval":"week","interval_count":1,"livemode":false,"metadata":{},"nickname":null,"product":"prod_MW6y2WdwsxIhaR","tiers_mode":null,"transform_usage":null,"trial_period_days":null,"usage_type":"licensed"},"price":{"id":"price_1LrCT5GGWgtqSxG4QuTxtmJ7","object":"price","active":false,"billing_scheme":"per_unit","created":1665371751,"currency":"aud","custom_unit_amount":null,"livemode":false,"lookup_key":null,"metadata":{},"nickname":null,"product":"prod_MW6y2WdwsxIhaR","recurring":{"aggregate_usage":null,"interval":"week","interval_count":1,"trial_period_days":null,"usage_type":"licensed"},"tax_behavior":"unspecified","tiers_mode":null,"transform_quantity":null,"type":"recurring","unit_amount":1,"unit_amount_decimal":"1"},"proration":false,"proration_details":{"credited_items":null},"quantity":5000,"subscription":"sub_1LrCT5GGWgtqSxG45L8y3VSv","subscription_item":"si_MaNDDVmZz0yRCh","tax_amounts":[],"tax_rates":[],"type":"subscription","unit_amount_excluding_tax":"1"}],"has_more":false,"total_count":1,"url":"/v1/invoices/in_1LrCT6GGWgtqSxG46LCezZyZ/lines"},"livemode":false,"metadata":{},"next_payment_attempt":null,"number":"3E9DA816-0001","on_behalf_of":null,"paid":true,"paid_out_of_band":false,"payment_intent":"pi_3LrCT6GGWgtqSxG41lwhfNa5","payment_settings":{"default_mandate":null,"payment_method_options":null,"payment_method_types":null},"period_end":1665371751,"period_start":1665371751,"post_payment_credit_notes_amount":0,"pre_payment_credit_notes_amount":0,"quote":null,"receipt_number":null,"rendering_options":null,"starting_balance":0,"statement_descriptor":null,"status":"paid","status_transitions":{"finalized_at":1665371752,"marked_uncollectible_at":null,"paid_at":1665371751,"voided_at":null},"subscription":"sub_1LrCT5GGWgtqSxG45L8y3VSv","subtotal":5000,"subtotal_excluding_tax":5000,"tax":null,"test_clock":null,"total":5000,"total_discount_amounts":[],"total_excluding_tax":5000,"total_tax_amounts":[],"transfer_data":null,"webhooks_delivered_at":null}},"livemode":false,"pending_webhooks":2,"request":{"id":"req_oYbDVcXm16jgI8","idempotency_key":"64142ed5-e9ef-4fc2-b022-3e02e0a6b562"},"type":"invoice.created"}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookInvoice.handleInvoice();
        Test.stopTest();
    }
}