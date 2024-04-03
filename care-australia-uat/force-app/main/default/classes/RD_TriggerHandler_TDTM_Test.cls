@istest
public class RD_TriggerHandler_TDTM_Test {
    @testSetup 
    public static void setup() {
        /*Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        
        List<npe03__Recurring_Donation__c> rdCrediCardList = new List<npe03__Recurring_Donation__c>();
        for(Integer  i=0;i<50;i++){
            npe03__Recurring_Donation__c rdCrediCard = new npe03__Recurring_Donation__c();
            rdCrediCard.npe03__Amount__c = 50;
            rdCrediCard.npe03__Contact__c = con.Id;
            rdCrediCard.npsp__PaymentMethod__c = 'Credit Card';
            
            rdCrediCard.npe03__Recurring_Donation_Campaign__c = camp.Id; 
            rdCrediCardList.add(rdCrediCard);
        }
        
        insert rdCrediCardList;*/
        
    }
    @isTest 
    public static void testmethod1(){
        
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'RD TriggerHandler';
        th.npsp__Class__c = 'RD_TriggerHandler_TDTM';
        th.npsp__Object__c = 'npe03__Recurring_Donation__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;BeforeUpdate;AfterUpdate,BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        npe03__Recurring_Donation__c rdCrediCard = new npe03__Recurring_Donation__c();
        rdCrediCard.npe03__Amount__c = 50;
        rdCrediCard.npe03__Contact__c = con.Id;
        rdCrediCard.npsp__PaymentMethod__c = 'Credit Card';
        //rdCrediCard.npsp__Status__c ='Held';
        //rdCrediCard.Card_Token__c ='123567';
        rdCrediCard.npe03__Recurring_Donation_Campaign__c = camp.Id;
        insert rdCrediCard;
        
        npe03__Recurring_Donation__c rdDirectDebit = new npe03__Recurring_Donation__c();
        rdDirectDebit.npe03__Amount__c = 60;
        rdDirectDebit.npe03__Contact__c = con.Id;
        rdDirectDebit.npsp__PaymentMethod__c = 'Direct Debit';
        rdDirectDebit.Account_Number__c ='23456789';
        rdDirectDebit.Account_BSB__c = '123-456';
        rdDirectDebit.Payee_Name__c = 'Test Payee';
        rdDirectDebit.Financial_Institution__c = 'HDFC';
        rdDirectDebit.npe03__Recurring_Donation_Campaign__c = camp.Id;
        
        npe03__Recurring_Donation__c rdActive = new npe03__Recurring_Donation__c();
        rdActive.npe03__Amount__c = 70;
        rdActive.npe03__Contact__c = con.Id;
        rdActive.npsp__PaymentMethod__c = 'Direct Debit';
        rdActive.Account_Number__c ='12345678';
        rdActive.Account_BSB__c = '002-146';
        rdActive.Payee_Name__c = 'Test Payee';
        rdActive.Financial_Institution__c = 'HDFC';
        rdActive.npsp__Status__c ='Held';
        rdActive.npe03__Recurring_Donation_Campaign__c = camp.Id;
        
        insert rdDirectDebit;
        insert rdActive;
        
        system.debug('rdCrediCard***'+rdCrediCard);
        Test.startTest();
        //insert rdCrediCard;
        
        rdCrediCard.Card_Token__c ='12356447';
        rdCrediCard.Card_Number_Masked__c ='424242******4242';
        update rdCrediCard;
        
        rdDirectDebit.Account_Number__c ='178954';
        
        update rdDirectDebit;
        
        rdActive.Failed_Consecutive_Opportunities__c = 3;
        update rdActive;
        
        Test.stopTest();
        
        system.debug('rdDirectDebit.npsp__Status__c***'+rdDirectDebit.npsp__Status__c);
        system.debug('rdActive.npsp__Status__c***'+rdActive.npsp__Status__c);
        system.debug('rdActive.npsp__ClosedReason__c***'+rdActive.npsp__ClosedReason__c);
        
        List<Donor_Constituency__c> dCList = [SELECT Id, Name, Account__c, Contact__c, Start_Date__c, End_Date__c, Constituency_Type__c,
                                              Active__c, RE_Legacy_ID__c FROM Donor_Constituency__c] ;
        System.debug('Donor Constituency::::::'+dCList);
        System.debug('Donor Constituency size::::::'+dCList.size());
    }
    @isTest 
    public static void testmethod2(){
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'RD TriggerHandler';
        th.npsp__Class__c = 'RD_TriggerHandler_TDTM';
        th.npsp__Object__c = 'npe03__Recurring_Donation__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;BeforeUpdate;AfterUpdate,BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Account acc = TestDataFactory.createAccount(false);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        insert acc;
        Campaign camp = TestDataFactory.createCampaign(true);
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 50;
        rd.npe03__Organization__c = acc.Id;
        rd.npsp__PaymentMethod__c = 'Direct Debit';
        rd.Account_Number__c ='12345678';
        rd.Account_BSB__c = '002-146';
        rd.Payee_Name__c = 'Test Payee';
        rd.Financial_Institution__c = 'HDFC';
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        
        npe03__Recurring_Donation__c rd2 = new npe03__Recurring_Donation__c();
        rd2.npe03__Amount__c = 100;
        rd2.npe03__Organization__c = acc.Id;
        rd2.npsp__PaymentMethod__c = 'Direct Debit';
        rd2.Account_Number__c ='1567900';
        rd2.Account_BSB__c = '002-146';
        rd2.Payee_Name__c = 'Test Payee';
        rd2.Financial_Institution__c = 'HDFC';
        rd2.npe03__Recurring_Donation_Campaign__c = camp.Id;
        
        Test.startTest();
        insert rd2;
        insert rd;
        Test.stopTest();
        
        List<Donor_Constituency__c> dCList = [SELECT Id, Name, Account__c, Contact__c, Start_Date__c, End_Date__c, Constituency_Type__c,
                                              Active__c, RE_Legacy_ID__c FROM Donor_Constituency__c] ;
        System.debug('testmethod2 Donor Constituency::::::'+dCList);
        System.debug('testmethod2Donor Constituency size::::::'+dCList.size());
    }
    @isTest 
    public static void testmethod3(){
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'RD TriggerHandler';
        th.npsp__Class__c = 'RD_TriggerHandler_TDTM';
        th.npsp__Object__c = 'npe03__Recurring_Donation__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;BeforeUpdate;AfterUpdate,BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Account acc = TestDataFactory.createAccount(false);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        insert acc;
        Campaign camp = TestDataFactory.createCampaign(true);
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 50;
        rd.npe03__Organization__c = acc.Id;
        rd.npsp__PaymentMethod__c = 'Direct Debit';
        rd.Account_Number__c ='123456';
        rd.Account_BSB__c = '002-146';
        rd.Payee_Name__c = 'Test Payee';
        rd.Financial_Institution__c = 'HDFC';
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        insert rd;
        
        npe03__Recurring_Donation__c rd2 = new npe03__Recurring_Donation__c();
        rd2.npe03__Amount__c = 100;
        rd2.npe03__Organization__c = acc.Id;
        rd2.npsp__PaymentMethod__c = 'Direct Debit';
        rd2.Account_Number__c ='12345670';
        rd2.Account_BSB__c = '002-146';
        rd2.Payee_Name__c = 'Test Payee';
        rd2.Financial_Institution__c = 'HDFC';
        rd2.npe03__Recurring_Donation_Campaign__c = camp.Id;
        
        insert rd2;
        
        Contact con = TestDataFactory.createContact(true);
        npe03__Recurring_Donation__c rd3 = new npe03__Recurring_Donation__c();
        rd3.npe03__Amount__c = 150;
        rd3.npe03__Contact__c = con.Id;
        rd3.npsp__PaymentMethod__c = 'Direct Debit';
        rd3.Account_Number__c ='12378900';
        rd3.Account_BSB__c = '002-146';
        rd3.Payee_Name__c = 'Test Payee';
        rd3.Financial_Institution__c = 'HDFC';
        rd3.npe03__Recurring_Donation_Campaign__c = camp.Id;
        insert rd3;
        
        Test.startTest();
        rd.npsp__Status__c = 'Cancelled';
        rd2.npsp__Status__c = 'Cancelled';
        rd3.npsp__Status__c = 'Cancelled';
        update rd;
        update rd2;
        update rd3;
        Test.stopTest();
        
        List<Donor_Constituency__c> dCList = [SELECT Id, Name, Account__c, Contact__c, Start_Date__c, End_Date__c, Constituency_Type__c,
                                              Active__c, RE_Legacy_ID__c FROM Donor_Constituency__c] ;
        System.debug('testmethod3 Donor Constituency::::::'+dCList);
        System.debug('testmethod3 Donor Constituency size::::::'+dCList.size());
    }
    
}