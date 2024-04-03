@isTest
public class paymentAfterInsertUpdate_TDTM_test {
    @isTest public static void positiveSecnarions(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'a0Qp000000Wm1gS';
        th.npsp__Class__c = 'paymentAfterInsertUpdate_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
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
        
        Campaign camp = TestDataFactory.createCampaign(true);
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecType;
        opp.Name = 'Test Opp 1';
        opp.CampaignId = camp.Id;
        opp.AccountId = acc.Id;
        opp.npsp__Primary_Contact__c = con.Id;
        opp.StageName = 'Pledged';
        opp.CloseDate = Date.newInstance(2021, 12, 9);
        insert opp;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp.Id;
        pay.npe01__Paid__c = true;
        insert pay;
        
        pay.Refund_Status__c = 'Processed';
        pay.npe01__Paid__c = false;
        pay.npe01__Written_Off__c = true;
        pay.npe01__Payment_Amount__c = 1234;
        update pay;
        
        pay.Chargeback_Status__c = 'Approved';
        pay.npe01__Written_Off__c = true;
        pay.Chargeback_Date__c = Date.newInstance(2021, 12, 12);
        update pay;
        
        pay.Adjustment_Status__c = 'Processed';
        pay.AUS_Code__c = 'AUS774';
        update pay;
        
        test.stopTest();
    }
    @isTest public static void positiveSecnarions2(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'a0Qp000000Wm1gS';
        th.npsp__Class__c = 'paymentAfterInsertUpdate_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'AfterUpdate;AfterInsert;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        
        triggerHandlers.add(th);
        
        // set up test data
        test.startTest();
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Test Acc 1';
        acc.RecordTypeId = accRecType;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        insert con;
        
        Campaign camp = TestDataFactory.createCampaign(true);
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecType;
        opp.Name = 'Test Opp 1';
        opp.CampaignId = camp.Id;
        opp.AccountId = acc.Id;
        opp.npsp__Primary_Contact__c = con.Id;
        opp.StageName = 'Closed Won';
        opp.Amount = 250;
        opp.CloseDate = Date.newInstance(2021, 12, 9);
        insert opp;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp.Id;
        pay.npe01__Paid__c = true;
        insert pay;
        
        pay.npe01__Payment_Date__c = Date.newInstance(2021, 12, 12);
        update pay;
        
        test.stopTest();
    }
    @isTest public static void negativeSecnarions2(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'a0Qp000000Wm1gS';
        th.npsp__Class__c = 'paymentAfterInsertUpdate_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'AfterUpdate;AfterInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        
        triggerHandlers.add(th);
        
        // set up test data
        test.startTest();
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Test Acc 1';
        acc.RecordTypeId = accRecType;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        insert con;
        
        Campaign camp = TestDataFactory.createCampaign(true);
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecType;
        opp.Name = 'Test Opp 1';
        opp.CampaignId = camp.Id;
        opp.AccountId = acc.Id;
        opp.npsp__Primary_Contact__c = con.Id;
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.newInstance(2021, 12, 9);
        insert opp;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp.Id;
        pay.npe01__Payment_Amount__c = 0;
        pay.npe01__Paid__c = true;
        insert pay;
        
        npe01__OppPayment__c pay2 = new npe01__OppPayment__c();
        pay2.npe01__Opportunity__c = opp.Id;
        pay2.npe01__Payment_Amount__c = 0;
        pay2.npe01__Paid__c = true;
        insert pay2;
        
        pay.FinanceReportCheck__c = false;
        pay.npe01__Payment_Date__c = Date.newInstance(2021, 12, 12);
        update pay;
        
        pay2.Adjustment_Status__c = 'In Process';
        pay2.FinanceReportCheck__c = false;
        pay2.npe01__Payment_Date__c = Date.newInstance(2021, 12, 12);
        update pay2;
        
        test.stopTest();
    }
}