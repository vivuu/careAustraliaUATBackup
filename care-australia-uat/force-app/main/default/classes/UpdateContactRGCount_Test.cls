@isTest
public class UpdateContactRGCount_Test {
 static Campaign testCampaign;
static Opportunity testOpportunity;    
    @testSetup
    static void setup() {
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        
         testCampaign = NBTestDataFactory.createCampaign();
        testOpportunity = NBTestDataFactory.createOpportunity(testCampaign);
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 100;
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.npsp__Status__c = 'Active';
        insert rd;
        npe03__Recurring_Donation__c rd1 = new npe03__Recurring_Donation__c();
        rd1.npe03__Amount__c = 1000;
        rd1.npe03__Contact__c = con.Id;
        rd1.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd1.npsp__PaymentMethod__c = 'Credit Card';
        rd1.npsp__Status__c = 'Active';
        insert rd1;
    }
    @isTest static void test() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP,  new UpdateContactRGCountScheduler());
        Test.stopTest();
        
    }
    
}