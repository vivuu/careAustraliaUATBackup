@isTest
public class StripeAddUpdateDDonRDTest {
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
        
        Stripe_Setting__c recSetting = new Stripe_Setting__c();
        recSetting.Name= 'Default';
        recSetting.Default_Contact__c = conList[0].id;
        recSetting.Default_Campaign__c = camp.id;
        recSetting.Activation__c = True;
        insert recSetting;
        
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opportunity', StageName='Pledged', npsp__Primary_Contact__c=conList[0].Id, AccountID=conList[0].AccountId, CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', Donation_Source__c='Telemarketing'));
        insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id, npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(), npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
    }
    
    public static testMethod void testdoPayment(){
        list<npe01__OppPayment__c> payments = [Select Id, npe01__Opportunity__c, npe01__Opportunity__r.npsp__Primary_Contact__c, Payment_Status__c, npe01__Opportunity__r.StageName,  npe01__Opportunity__r.npe03__Recurring_Donation__r.Id, npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c, npe01__Payment_Amount__c from npe01__OppPayment__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeAddUpdateDDonRD.updatePaymentMethod('123-122-12','242424242424','test','test@test.com', payments[0].npe01__Opportunity__r.npe03__Recurring_Donation__r.Id, 'TTT');
        Test.stopTest();
    }
    
    public static testMethod void testupdateDDonRD(){
        list<Contact> conList = [Select Id, Name, AccountId From Contact Where Name='Test Customer'];
        Campaign camp = [Select Id, Name From Campaign Where Name='2022 CAREGifts' limit 1];
        list<npe03__Recurring_Donation__c> rdList = new list<npe03__Recurring_Donation__c>();
        rdList.add(new npe03__Recurring_Donation__c(npe03__Contact__c=conList[0].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=System.Today(), npe03__Installment_Period__c='Monthly', Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        insert rdList;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeAddUpdateDDonRD.updatePaymentMethod('123-122-12','242424242424','test','test@test.com', rdList[0].Id, 'TTT');
        Test.stopTest();
    }
    
    public static testMethod void testupdateDDonRDWithCustomer(){
        list<Contact> conList = [Select Id, stripe_customer_id__c, Name, AccountId From Contact Where Name='Test Customer'];
        conList[0].stripe_customer_id__c = 'cus_MaqSawqM4GJrL8';
        update conList;
        Campaign camp = [Select Id, Name From Campaign Where Name='2022 CAREGifts' limit 1];
        list<npe03__Recurring_Donation__c> rdList = new list<npe03__Recurring_Donation__c>();
        rdList.add(new npe03__Recurring_Donation__c(npe03__Contact__c=conList[0].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=System.Today(), npe03__Installment_Period__c='Monthly', Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        insert rdList;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        //StripeAddUpdateDDonRD.updatePaymentMethod('242424242424','09','2024','Test Customer', rdList[0].Id);
        StripeAddUpdateDDonRD.updatePaymentMethod('123-122-12','242424242424','test','test@test.com', rdList[0].Id, 'TTT');
        Test.stopTest();
    }
}