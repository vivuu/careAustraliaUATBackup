@istest
public with sharing class accountAfterUpdate_TDTM_Test {
    
    @testSetup 
    public static void setup() {
        
        Account acc = new Account();
        acc.Name = 'Test Account 1';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        insert acc;
        
        Campaign  camp = TestDataFactory.createCampaign(true);
        npe03__Recurring_Donation__c rd1 = new npe03__Recurring_Donation__c();
        rd1.npe03__Amount__c = 50;
        rd1.npe03__Organization__c = acc.Id;
        rd1.npsp__PaymentMethod__c = 'Credit Card';
        rd1.npe03__Recurring_Donation_Campaign__c = camp.Id;
        insert rd1;
        
        npe03__Recurring_Donation__c rd2 = new npe03__Recurring_Donation__c();
        rd2.npe03__Amount__c = 100;
        rd2.npe03__Organization__c = acc.Id;
        rd2.npsp__PaymentMethod__c = 'Credit Card';
        rd2.npe03__Recurring_Donation_Campaign__c = camp.Id;
        insert rd2;
        
    }
    
    @isTest 
    public static void testmethod_AccoutEmailUpdate(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Account fter Update';
        th.npsp__Class__c = 'accountAfterUpdate_TDTM';
        th.npsp__Object__c = 'Account';
        th.npsp__Trigger_Action__c = 'AfterUpdate;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
		Account acc = [Select Id,Email__c From Account limit 1];
        acc.Email__c = 'test@test.com';
        // set up test data
        test.startTest();
		update acc;
        test.stopTest();
        
        List<npe03__Recurring_Donation__c> rdList = [Select Id,Donor_Email__c From npe03__Recurring_Donation__c];
        for(npe03__Recurring_Donation__c rd : rdList){
            System.assertEquals('test@test.com', rd.Donor_Email__c);
        }
        
        List<npe01__OppPayment__c> paymentList = [Select Id,Donor_Email__c From npe01__OppPayment__c];
        for(npe01__OppPayment__c payment : paymentList){
            System.assertEquals('test@test.com', payment.Donor_Email__c);
        }
        
    }
}