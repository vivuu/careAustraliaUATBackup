@istest
public class paymentBeforeInsert_TDTM_Test {
    @testSetup 
    public static void setup() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Payment Before Insert';
        th.npsp__Class__c = 'paymentBeforeInsert_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c =0;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Account acc = new Account();
        acc.Name = 'Test Account 1';
        insert acc;
        
        Campaign  camp = TestDataFactory.createCampaign(false);
        camp.Email_Content__c= 'Thank you for your very valuable and thoughtful gift in memory of <memoryof>, your support is allowing CARE to continue to help people in need throughout the developing world. Thanks to you, children will be able to go to school, families will have better healthcare close to come, communities will be able to prepare for and recover from natural disasters, and so much more.Your gift reflects your kindness and generosity and will be used to offer hope, a better life and a brighter future for people in poor and marginalized communities. Thank you.';
        insert camp;
        
        Opportunity opp = TestDataFactory.createOpportunity('Pledged',acc.Id,system.today()+10,false);
        opp.CampaignId = camp.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CARE Gift').getRecordTypeId();
        opp.npsp__Honoree_Name__c  = 'Test Honoree';
        insert opp;

        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp.Id ;
        pay.npe01__Payment_Amount__c  = 100;        
        insert pay;
    }
    @isTest 
    public static void testmethod_ContactDonor(){
        
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Payment Before Insert';
        th.npsp__Class__c = 'paymentBeforeInsert_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c =0;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Contact con = TestDataFactory.createContact(false);
        con.Email = 'test@test.com';
        insert con;
        
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c();
        gau.Name ='Test GAU';
        insert gau;
        
        Campaign camp = TestDataFactory.createCampaign(false);
        camp.AUS_Code__c = 'AUS779';
        camp.GAU__c = gau.Id;
        insert camp;
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 50;
        rd.npe03__Contact__c = con.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        Test.startTest();
        insert rd;
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_AccountDonor(){
        
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Payment Before Insert';
        th.npsp__Class__c = 'paymentBeforeInsert_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c =0;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Account acc = new Account();
        acc.Name = 'Test Account 2';
        acc.Email__c = 'test@test.com';
        acc.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        insert acc;
        
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c();
        gau.Name ='Test GAU';
        insert gau;
        
        Campaign camp = TestDataFactory.createCampaign(false);
        camp.AUS_Code__c = 'AUS779';
        camp.GAU__c = gau.Id;
        insert camp;
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 50;
        rd.npe03__Organization__c = acc.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        Test.startTest();
        insert rd;
        Test.stopTest();
        system.debug('acc:::'+acc);
        system.debug([Select Id, Donor_Type__c,Donor_Email__c From npe01__OppPayment__c]);
        system.debug([Select Id, Email__c,RecordType.Name From Account]);
        system.debug([Select Id, AUS_Code__c,GAU__c From Campaign]);
        system.debug([SELECT Id, AccountId,Account.Email__c,Account.Do_Not_Email__c, npsp__Primary_Contact__c,
                      npsp__Primary_Contact__r.Email,npsp__Primary_Contact__r.Do_Not_Email__c,CampaignId,
                      Campaign.AUS_Code__c,Campaign.GAU__c,Donor_Type__c FROM Opportunity]);
    }
    @isTest 
    public static void testmethod_BulkPaymentCreationWithRD(){
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Payment Before Insert';
        th.npsp__Class__c = 'paymentBeforeInsert_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c =0;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Contact con = TestDataFactory.createContact(false);
        con.Email = 'test@test.com';
        insert con;
        
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c();
        gau.Name ='Test GAU';
        insert gau;
        
        Campaign camp = TestDataFactory.createCampaign(false);
        camp.AUS_Code__c = 'AUS779';
        camp.GAU__c = gau.Id;
        insert camp;
        List<npe03__Recurring_Donation__c> rdList = new List<npe03__Recurring_Donation__c>();
        for(Integer i =0;i<200 ; i++){
            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
            rd.npe03__Amount__c = 50+i;
            rd.npe03__Contact__c = con.Id;
            rd.npsp__PaymentMethod__c = 'Credit Card';
            rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
            rdList.add(rd);
        }
        
        Test.startTest();
        insert rdList;
        Test.stopTest();
    }
    
    @isTest 
    public static void testmethod_NonRGPayment(){
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Payment Before Insert';
        th.npsp__Class__c = 'paymentBeforeInsert_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c =0;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Account acc = new Account();
        acc.Name = 'Test Account 3';
        insert acc;
        
        Campaign campaign_test = new Campaign(Name ='Catalogue General Internet');
        insert campaign_test;
        
        Opportunity opp = TestDataFactory.createOpportunity('Pledged',acc.Id,system.today()+10,false);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CARE Gift').getRecordTypeId();
        opp.CampaignId = campaign_test.Id;
        insert opp;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp.Id ;
        pay.npe01__Payment_Amount__c  = 500;
        
        Test.startTest();
        insert pay;
        Test.stopTest();
        
    }
    @isTest 
    public static void testmethod_EstateEmail(){
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
         // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Payment Before Insert';
        th.npsp__Class__c = 'paymentBeforeInsert_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c =0;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
       
        Contact solicitor = TestDataFactory.createContact(false);
        solicitor.Email = 'test@solicitor.com';
        insert solicitor;
        
        Account acc = new Account();
        acc.Name = 'Test Account 34';
        acc.Solicitor__c =solicitor.Id;
        insert acc;
        
        Campaign  camp = TestDataFactory.createCampaign(false);
        camp.Email_Content__c= 'Thank you for your very valuable and thoughtful gift in memory of <memoryof>, your support is allowing CARE to continue to help people in need throughout the developing world. Thanks to you, children will be able to go to school, families will have better healthcare close to come, communities will be able to prepare for and recover from natural disasters, and so much more.Your gift reflects your kindness and generosity and will be used to offer hope, a better life and a brighter future for people in poor and marginalized communities. Thank you.';
        insert camp;
        Opportunity opp = TestDataFactory.createOpportunity('Pledged',acc.Id,system.today()+10,false);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Estate').getRecordTypeId();
        opp.CampaignId = camp.Id;
        insert opp;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp.Id ;
        pay.npe01__Payment_Amount__c  = 500;
        
        Test.startTest();
        insert pay;
        Test.stopTest();
        
        npe01__OppPayment__c updatedPayment = [Select Id,Donor_Email__c,Email_Content_Merged__c From npe01__OppPayment__c where Id=:pay.Id limit 1];
        
        system.assertEquals(solicitor.Email  , updatedPayment.Donor_Email__c);
        //system.assertEquals(updatedPayment.Email_Content_Merged__c, 'Thank you for your very valuable and thoughtful gift in memory of Test Honoree, your support is allowing CARE to continue to help people in need throughout the developing world. Thanks to you, children will be able to go to school, families will have better healthcare close to come, communities will be able to prepare for and recover from natural disasters, and so much more.Your gift reflects your kindness and generosity and will be used to offer hope, a better life and a brighter future for people in poor and marginalized communities. Thank you');
        
    }
    @isTest 
    public static void testmethod_ACMapping(){
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
         // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Payment Before Insert';
        th.npsp__Class__c = 'paymentBeforeInsert_TDTM';
        th.npsp__Object__c = 'npe01__OppPayment__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c =0;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);
        
        Account acc = new Account();
        acc.Name = 'Test Account 2';
        insert acc;
        
        Campaign  camp = TestDataFactory.createCampaign(true);
        Opportunity opp = TestDataFactory.createOpportunity('Pledged',acc.Id,system.today()+10,false);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        opp.CampaignId = camp.Id;
        opp.Donation_Source__c = 'Mail';
        insert opp;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp.Id ;
        pay.npe01__Payment_Amount__c  = 500;
        pay.npe01__Payment_Method__c = 'Direct Debit';
        pay.Merchant_Category__c = 'Offline';
        Test.startTest();
        insert pay;
        Test.stopTest();
        
        npe01__OppPayment__c updatedPayment = [Select Id,Credit_AC_Code__c,Debit_AC_Code__c From npe01__OppPayment__c where Id=:pay.Id limit 1];
        
        system.assertEquals(updatedPayment.Debit_AC_Code__c,'400000');
        system.assertEquals(updatedPayment.Credit_AC_Code__c,'133035');
    }
}