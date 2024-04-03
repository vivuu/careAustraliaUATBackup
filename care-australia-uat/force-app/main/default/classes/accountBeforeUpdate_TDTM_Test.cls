@istest
public with sharing class accountBeforeUpdate_TDTM_Test {
    @isTest 
    public static void testmethod1(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Account Before Update';
        th.npsp__Class__c = 'accountBeforeUpdate_TDTM';
        th.npsp__Object__c = 'Account';
        th.npsp__Trigger_Action__c = 'BeforeUpdate;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        // set up test data
        test.startTest();
        Account acc = new Account();
        acc.Name = 'Testing Account for Trigger';
        acc.RecordTypeId = [select Id from RecordType where DeveloperName = 'Organization' AND sObjectType = 'Account' limit 1].Id;
        insert acc;
        acc.Do_Not_Contact__c = true;
        update acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Acc 1';
        acc2.RTS_Received_Date__c = Date.newInstance(2021, 12, 8);
        insert acc2;
        acc2.RTS_Received_Date__c = Date.newInstance(2021, 13, 8);
        update acc2;
        acc2.RTS_Received_Date__c = Date.newInstance(2021, 14, 8);
        update acc2;
        acc2.RTS_Received_Date__c = Date.newInstance(2021, 15, 8);
        update acc2;
        acc2.ShippingCity = 'Pune';
        update acc2;        
        test.stopTest();
    }
}