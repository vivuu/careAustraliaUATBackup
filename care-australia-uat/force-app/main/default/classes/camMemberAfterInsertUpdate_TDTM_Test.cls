@isTest
public class camMemberAfterInsertUpdate_TDTM_Test {
    @isTest public static void positiveSecnarions(){
         // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'a0Qp000000WmaMp';
        th.npsp__Class__c = 'camMemberAfterInsertUpdate_TDTM';
        th.npsp__Object__c = 'CampaignMember';
        th.npsp__Trigger_Action__c = 'AfterUpdate;AfterInsert;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        
        triggerHandlers.add(th);
        
         // set up test data
        test.startTest();
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Test Acc 1';
        acc.RecordTypeId = accRecType;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        insert con;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Camp';
        camp.Channel__c = 'Telemarketing';
        camp.IsActive = true;
        insert camp;
        
        CampaignMember campMem = new CampaignMember();
        campMem.ContactId = con.Id;
        campMem.Action_Date__c = Date.newInstance(2021, 15, 10);
        campMem.Call_Type__c = 'C2C';
        campMem.Telemarketing_Result__c = 'Refusal';
        campMem.CampaignId = camp.Id;
        insert campMem;
        
        campMem.Telemarketing_Result__c = 'Maximum Attempts';
        update campMem;
        
        campMem.Call_Type__c = 'Upgrades';
        update campMem;
        
    }
    
    @isTest public static void positiveSecnarions2(){
         // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'a0Qp000000WmaMp';
        th.npsp__Class__c = 'camMemberAfterInsertUpdate_TDTM';
        th.npsp__Object__c = 'CampaignMember';
        th.npsp__Trigger_Action__c = 'AfterUpdate;AfterInsert;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        
        triggerHandlers.add(th);
        
         // set up test data
        test.startTest();
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Test Acc 1';
        acc.RecordTypeId = accRecType;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        insert con;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Camp';
        camp.Channel__c = 'Telemarketing';
        camp.IsActive = true;
        insert camp;
        
        CampaignMember campMem = new CampaignMember();
        campMem.ContactId = con.Id;
        campMem.Action_Date__c = Date.newInstance(2021, 15, 10);
        campMem.Call_Type__c = 'Reactivates';
        campMem.Telemarketing_Result__c = 'Refusal';
        campMem.CampaignId = camp.Id;
        insert campMem;
        
        campMem.Telemarketing_Result__c = 'Maximum Attempts';
        update campMem;
        
        campMem.Call_Type__c = 'Rejections';
        update campMem;
    }
}