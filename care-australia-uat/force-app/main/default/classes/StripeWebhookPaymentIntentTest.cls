@isTest
public class StripeWebhookPaymentIntentTest {
@TestSetup
      private static void testData(){
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', stripe_customer_id__c = 'cus_MWHbeeJlTnGCgG', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
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
          
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opportunity', 
                                    StageName='Closed Won', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=System.today(), 
                                    Amount=500, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        //CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', 
          insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id, 
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(),
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
        
	}
    public static testMethod void testhandlePayment(){
       
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentIntent'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_3LnF37GGWgtqSxG41SIJKh0x","object":"event","api_version":"2020-08-27","created":1664428362,"data":{"object":{"id":"ch_3LnF37GGWgtqSxG41u2QGoRT","object":"charge","amount":10000,"amount_captured":10000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LnF37GGWgtqSxG4138ZdOnK","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"CAREAUSTRALIA","captured":true,"created":1664428362,"currency":"aud","customer":"cus_MWHbeeJlTnGCgG","description":"TestPayment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":63,"seller_message":"Paymentcomplete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LnF37GGWgtqSxG414Vgf2rw","payment_method":"src_1LnF36GGWgtqSxG45rKL0AWi","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KMvS1JkGMgaGj0sDEM46LBZDihtX8jIHZdw3qtFOH8qFu3nLP79o9qkfu_Bq-bDok-0IEqewC7mLocNe","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LnF37GGWgtqSxG41u2QGoRT/refunds"},"review":null,"shipping":null,"source":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"card","amount":null,"card":{"exp_month":12,"exp_year":2034,"last4":"4242","country":"US","brand":"Visa","address_zip_check":"pass","cvc_check":"pass","funding":"credit","fingerprint":"k3Oq1WWP1nBVr7hR","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_Tyl7cPQPYT6n79qWhk1ypYQ1","created":1664428362,"currency":null,"flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":"CAREAustralia","statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"charge.succeeded"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
    }
    
    public static testMethod void testhandlePaymentFailed(){
       
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentIntent'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_3LnF37GGWgtqSxG41SIJKh0x","object":"event","api_version":"2020-08-27","created":1664428362,"data":{"object":{"id":"ch_3LnF37GGWgtqSxG41u2QGoRT","object":"charge","amount":10000,"amount_captured":10000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LnF37GGWgtqSxG4138ZdOnK","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"CAREAUSTRALIA","captured":true,"created":1664428362,"currency":"aud","customer":"cus_MWHbeeJlTnGCgG","description":"TestPayment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":63,"seller_message":"Paymentcomplete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LnF37GGWgtqSxG414Vgf2rw","payment_method":"src_1LnF36GGWgtqSxG45rKL0AWi","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KMvS1JkGMgaGj0sDEM46LBZDihtX8jIHZdw3qtFOH8qFu3nLP79o9qkfu_Bq-bDok-0IEqewC7mLocNe","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LnF37GGWgtqSxG41u2QGoRT/refunds"},"review":null,"shipping":null,"source":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"card","amount":null,"card":{"exp_month":12,"exp_year":2034,"last4":"4242","country":"US","brand":"Visa","address_zip_check":"pass","cvc_check":"pass","funding":"credit","fingerprint":"k3Oq1WWP1nBVr7hR","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_Tyl7cPQPYT6n79qWhk1ypYQ1","created":1664428362,"currency":null,"flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":"CAREAustralia","statement_descriptor_suffix":null,"status":"failed","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"charge.succeeded"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
    }
    
    public static testMethod void testHandleOpportunityCase(){
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test Opportunity', LastName='Customer Opp', Email='testopp@test.com', stripe_customer_id__c = 'cus_MWHbeeJlTnGopp', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
         
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opp Opportunity', 
                                    StageName='Closed Won', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=System.today(), 
                                    Amount=500, 
                                    stripe_pi_id__c='pi_3LnF37GGWgtqSxG414Vgf2rw',
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        //CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', 
          insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id, 
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(),
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
       
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentIntent'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_3LnF37GGWgtqSxG41SIJKh0x","object":"event","api_version":"2020-08-27","created":1664428362,"data":{"object":{"id":"ch_3LnF37GGWgtqSxG41u2QGoRT","object":"charge","amount":10000,"amount_captured":10000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LnF37GGWgtqSxG4138ZdOnK","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"CAREAUSTRALIA","captured":true,"created":1664428362,"currency":"aud","customer":"cus_MWHbeeJlTnGCgG","description":"TestPayment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":63,"seller_message":"Paymentcomplete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LnF37GGWgtqSxG414Vgf2rw","payment_method":"src_1LnF36GGWgtqSxG45rKL0AWi","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KMvS1JkGMgaGj0sDEM46LBZDihtX8jIHZdw3qtFOH8qFu3nLP79o9qkfu_Bq-bDok-0IEqewC7mLocNe","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LnF37GGWgtqSxG41u2QGoRT/refunds"},"review":null,"shipping":null,"source":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"card","amount":null,"card":{"exp_month":12,"exp_year":2034,"last4":"4242","country":"US","brand":"Visa","address_zip_check":"pass","cvc_check":"pass","funding":"credit","fingerprint":"k3Oq1WWP1nBVr7hR","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_Tyl7cPQPYT6n79qWhk1ypYQ1","created":1664428362,"currency":null,"flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":"CAREAustralia","statement_descriptor_suffix":null,"status":"failed","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"charge.succeeded"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
    }
        
    public static testMethod void testHandlePaymentCase(){
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test Opportunity', LastName='Customer Opp', Email='testopp@test.com', stripe_customer_id__c = 'cus_MWHbeeJlTnGopp', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opp Opportunity', 
                                    StageName='Closed Won', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=System.today(), 
                                    Amount=500, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        //CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', 
          insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id, Stripe_Charge_ID__c = 'ch_3LnF37GGWgtqSxG41u2QGoRT',
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(),
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
       
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentIntent'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_3LnF37GGWgtqSxG41SIJKh0x","object":"event","api_version":"2020-08-27","created":1664428362,"data":{"object":{"id":"ch_3LnF37GGWgtqSxG41u2QGoRT","object":"charge","amount":10000,"amount_captured":10000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LnF37GGWgtqSxG4138ZdOnK","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"CAREAUSTRALIA","captured":true,"created":1664428362,"currency":"aud","customer":"cus_MWHbeeJlTnGCgG","description":"TestPayment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":63,"seller_message":"Paymentcomplete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LnF37GGWgtqSxG414Vgf2rw","payment_method":"src_1LnF36GGWgtqSxG45rKL0AWi","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KMvS1JkGMgaGj0sDEM46LBZDihtX8jIHZdw3qtFOH8qFu3nLP79o9qkfu_Bq-bDok-0IEqewC7mLocNe","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LnF37GGWgtqSxG41u2QGoRT/refunds"},"review":null,"shipping":null,"source":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"card","amount":null,"card":{"exp_month":12,"exp_year":2034,"last4":"4242","country":"US","brand":"Visa","address_zip_check":"pass","cvc_check":"pass","funding":"credit","fingerprint":"k3Oq1WWP1nBVr7hR","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_Tyl7cPQPYT6n79qWhk1ypYQ1","created":1664428362,"currency":null,"flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":"CAREAustralia","statement_descriptor_suffix":null,"status":"failed","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"charge.succeeded"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
    }
    
    public static testMethod void testContactOppMatchCase(){
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test Opportunity', LastName='Customer Opp', Email='testopp@test.com', stripe_customer_id__c = 'cus_MWHbeeJlTnGopp', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
   		
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opp Opportunity', 
                                    StageName='Pledged', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=Date.newInstance(2022, 09, 29), 
                                    Amount=200, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        //CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', 
          insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id,
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(),
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
       
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentIntent'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_3LnF37GGWgtqSxG41SIJKh0x","object":"event","api_version":"2020-08-27","created":1664428362,"data":{"object":{"id":"ch_3LnF37GGWgtqSxG41u2QGoRT","object":"charge","amount":10000,"amount_captured":10000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LnF37GGWgtqSxG4138ZdOnK","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"CAREAUSTRALIA","captured":true,"created":1664428362,"currency":"aud","customer":"cus_MWHbeeJlTnGopp","description":"TestPayment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":63,"seller_message":"Paymentcomplete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LnF37GGWgtqSxG414Vgf2rw","payment_method":"src_1LnF36GGWgtqSxG45rKL0AWi","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KMvS1JkGMgaGj0sDEM46LBZDihtX8jIHZdw3qtFOH8qFu3nLP79o9qkfu_Bq-bDok-0IEqewC7mLocNe","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LnF37GGWgtqSxG41u2QGoRT/refunds"},"review":null,"shipping":null,"source":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"card","amount":null,"card":{"exp_month":12,"exp_year":2034,"last4":"4242","country":"US","brand":"Visa","address_zip_check":"pass","cvc_check":"pass","funding":"credit","fingerprint":"k3Oq1WWP1nBVr7hR","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_Tyl7cPQPYT6n79qWhk1ypYQ1","created":1664428362,"currency":null,"flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":"CAREAustralia","statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"charge.succeeded"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
    }
    
    public static testMethod void testCustomerNotAvailableCase(){
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test Opportunity', LastName='Customer Opp', Email='testopp@test.com', stripe_customer_id__c = 'cus_MWHbeeJlTnGopp', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opp Opportunity', 
                                    StageName='Pledged', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=Date.newInstance(2022, 09, 29), 
                                    Amount=100, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        //CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', 
          insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id,
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(),
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
       
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentIntent'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_3LnF37GGWgtqSxG41SIJKh0x","object":"event","api_version":"2020-08-27","created":1664428362,"data":{"object":{"id":"ch_3LnF37GGWgtqSxG41u2QGoRT","object":"charge","amount":10000,"amount_captured":10000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LnF37GGWgtqSxG4138ZdOnK","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"CAREAUSTRALIA","captured":true,"created":1664428362,"currency":"aud","customer":"","description":"TestPayment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":63,"seller_message":"Paymentcomplete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LnF37GGWgtqSxG414Vgf2rw","payment_method":"src_1LnF36GGWgtqSxG45rKL0AWi","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KMvS1JkGMgaGj0sDEM46LBZDihtX8jIHZdw3qtFOH8qFu3nLP79o9qkfu_Bq-bDok-0IEqewC7mLocNe","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LnF37GGWgtqSxG41u2QGoRT/refunds"},"review":null,"shipping":null,"source":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"card","amount":null,"card":{"exp_month":12,"exp_year":2034,"last4":"4242","country":"US","brand":"Visa","address_zip_check":"pass","cvc_check":"pass","funding":"credit","fingerprint":"k3Oq1WWP1nBVr7hR","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_Tyl7cPQPYT6n79qWhk1ypYQ1","created":1664428362,"currency":null,"flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":"CAREAustralia","statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"charge.succeeded"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
    }
    
    public static testMethod void testContactNotAvailableCase(){
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test Opportunity', LastName='Customer Opp', Email='testopp@test.com', stripe_customer_id__c = 'cus_MWHbeeJlTnGopp', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opp Opportunity', 
                                    StageName='Pledged', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=Date.newInstance(2022, 09, 29), 
                                    Amount=100, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        //CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', 
          insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id,
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(),
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
       
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
        */
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/webhooks/PaymentIntent'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf('{"id":"evt_3LnF37GGWgtqSxG41SIJKh0x","object":"event","api_version":"2020-08-27","created":1664428362,"data":{"object":{"id":"ch_3LnF37GGWgtqSxG41u2QGoRTnew","object":"charge","amount":10000,"amount_captured":10000,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LnF37GGWgtqSxG4138ZdOnK","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"CAREAUSTRALIA","captured":true,"created":1664428362,"currency":"aud","customer":"cus_MQfbVwXxlomTAl","description":"TestPayment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":63,"seller_message":"Paymentcomplete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LnF37GGWgtqSxG414Vgf2new","payment_method":"src_1LnF36GGWgtqSxG45rKL0AWi","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":"pass"},"country":"US","exp_month":12,"exp_year":2034,"fingerprint":"k3Oq1WWP1nBVr7hR","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTElrTEdHR1dndHFTeEc0KMvS1JkGMgaGj0sDEM46LBZDihtX8jIHZdw3qtFOH8qFu3nLP79o9qkfu_Bq-bDok-0IEqewC7mLocNe","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LnF37GGWgtqSxG41u2QGoRT/refunds"},"review":null,"shipping":null,"source":{"id":"src_1LnF36GGWgtqSxG45rKL0AWi","object":"card","amount":null,"card":{"exp_month":12,"exp_year":2034,"last4":"4242","country":"US","brand":"Visa","address_zip_check":"pass","cvc_check":"pass","funding":"credit","fingerprint":"k3Oq1WWP1nBVr7hR","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_Tyl7cPQPYT6n79qWhk1ypYQ1","created":1664428362,"currency":null,"flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"00000","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":"CAREAustralia","statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}},"livemode":false,"pending_webhooks":1,"request":{"id":"req_9lKX66XTzN3eph","idempotency_key":"5a4046f6-3432-48bd-b5aa-724ac2241d78"},"type":"charge.succeeded"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        StripeWebhookPaymentIntent.handlePayment();
        Test.stopTest();
    }
}