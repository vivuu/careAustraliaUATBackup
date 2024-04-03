@isTest
public class StripePaymentByCCTest {
	@TestSetup
    private static void testData(){
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/api/webhooks/pushDetails');
        request.setMethod('POST');
        request.setBody('');
        
        //HttpResponse response = http.send(request);
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opportunity', StageName='Pledged', npsp__Primary_Contact__c=conList[0].Id, AccountID=conList[0].AccountId, CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', Donation_Source__c='Telemarketing'));
        insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id, npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(), npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
        
        //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = conList[0].id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting; 
        
        List<npe03__Recurring_Donation__c> rdList = new List<npe03__Recurring_Donation__c>();
        rdList.add(new npe03__Recurring_Donation__c(npe03__Organization__c=conList[0].AccountId, npe03__Contact__c=conList[0].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=date.today().addDays(15), npsp__RecurringType__c='Fixed', npsp__InstallmentFrequency__c=1, npe03__Installment_Period__c='Weekly', npe03__Installments__c=12, Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        insert rdList;
        
        
    }
    
    public static testMethod void testdoPayment(){
        list<npe01__OppPayment__c> payments = [Select Id, npe01__Opportunity__c, npe01__Opportunity__r.npsp__Primary_Contact__c, Payment_Status__c, npe01__Opportunity__r.StageName,  npe01__Opportunity__r.npe03__Recurring_Donation__r.Id, npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c, npe01__Payment_Amount__c from npe01__OppPayment__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
		String response = '{"paymentMethod":{"id":"pm_1LqzAHGGWgtqSxG4LYV010Rd","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":null},"country":"US","exp_month":4,"exp_year":2024,"funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1666804787,"customer":null,"livemode":false,"type":"card"}}';
        StripePaymentByCC.doPayment(payments[0].id, response);
        
        Test.stopTest();
    }
    
    public static testMethod void testdoPaymentByContact(){
        list<Contact> contacts = [Select Id, Name from Contact];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
		String response = '{"paymentMethod":{"id":"pm_1LqzAHGGWgtqSxG4LYV010Rd","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":null},"country":"US","exp_month":4,"exp_year":2024,"funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1666804787,"customer":null,"livemode":false,"type":"card"}}';
        StripePaymentByCC.doPayment(contacts[0].id, response);
        
        Test.stopTest();
    }
    
    public static testMethod void testdoRDAuth(){
       
        list<npe03__Recurring_Donation__c> rdRec = [Select Id from npe03__Recurring_Donation__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
		String response = '{"paymentMethod":{"id":"pm_1LqzAHGGWgtqSxG4LYV010Rd","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":null},"country":"US","exp_month":4,"exp_year":2024,"funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1666804787,"customer":null,"livemode":false,"type":"card"}}';
        StripePaymentByCC.doPayment(rdRec[0].id, response);
        
        Test.stopTest();
    }
}