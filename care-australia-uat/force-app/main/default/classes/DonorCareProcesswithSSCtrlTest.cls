@isTest
public class DonorCareProcesswithSSCtrlTest {
    @testSetup
    static void createData() {
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        Account acc = new Account(Name='Test acc');
        insert acc;
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(AccountId=acc.Id, FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666', Stripe_Customer_Id__c='cus_OezvOgmGSxROgw', Stripe_Customer_Ids__c='cus_OezvOgmGSxROgw'));
        insert conList;
        
        insert new npe03__Recurring_Donation__c(
            npe03__Contact__c=conList[0].Id, 
            npe03__Amount__c=500,
            npe03__Recurring_Donation_Campaign__c=camp.Id, 
            npsp__CardExpirationMonth__c='09', 
            npsp__CardExpirationYear__c='2024', 
            npsp__CardLast4__c='2424', 
            Card_Number_Masked__c='',
            Card_Token__c='', 
            Card_Type__c='Visa',
            npsp__StartDate__c=date.today().addDays(15), 
            npsp__RecurringType__c='Fixed', 
            npsp__InstallmentFrequency__c=1, 
            npe03__Installment_Period__c='Weekly', 
            npe03__Installments__c=12, 
            Payment_Gateway__c='Stripe', 
            npsp__PaymentMethod__c='Credit Card',
            npsp__Status__c='Active',
            Stripe_Subscription_Id__c = 'subsId'
        );
    }
    
	@isTest
    static void getSSUrl_test() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id campaignId = [SELECT Id FROM Campaign LIMIT 1].Id;
        Id rdId = [SELECT Id FROM npe03__Recurring_Donation__c LIMIT 1].Id;
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
        Test.startTest();
        DonorCareProcesswithSSCtrl.getSSUrl(String.valueOf(contactId), String.valueOf(campaignId), '100', true, String.valueOf(rdId), String.valueOf(oppId));
        Test.stopTest();
    }
    
    @isTest
    static void hangUpCall_test() {
        Test.setMock(HttpCalloutMock.class, new PostStripeChargeSuccess());
        
        Test.startTest();
        DonorCareProcesswithSSCtrl.hangUpCall(true);
        Test.stopTest();
    }
    
    public class PostStripeChargeSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "ch_503as6asdas"}');
            res.setStatusCode(301);
            return res;
        }
    }
}