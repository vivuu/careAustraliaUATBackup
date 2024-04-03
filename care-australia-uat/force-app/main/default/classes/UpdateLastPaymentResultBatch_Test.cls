@istest
public class UpdateLastPaymentResultBatch_Test {
    @istest
    public static void setup() {
        
        
        
    }
    @isTest 
    public static void testmethod_Success(){
        
        //RG_Processing_Batch__c rgProcessingBatchCC = [Select Id from RG_Processing_Batch__c limit 1];
        RG_Processing_Batch__c rgProcessingBatch = new RG_Processing_Batch__c();
        rgProcessingBatch.Batch_Unique_Identifier__c = 'CC_123456789';
        rgProcessingBatch.Payment_Method__c = 'Credit Card';
        rgProcessingBatch.Scheduled_Date__c = System.today();
        rgProcessingBatch.Batch_Status__c = 'Completed';
        
        insert rgProcessingBatch;
        
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        
        
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 50;
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.Card_Token__c ='123';
        rd.Card_Number_Masked__c = '123456780000';
        rd.Payee_Name__c = 'Test Payee';
        rd.Card_Type__c = 'Visa';
        rd.On_Held_Date__c = Date.newinstance(2021, 12, 1);
         insert rd;
        
        
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp =TestDataFactory.createOpportunity('Pledged',acc.Id,Date.newinstance(2022, 02, 01),false); 
        opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        opp.Amount = 100;
        opp.CampaignId = camp.Id;
        opp.npe03__Recurring_Donation__c = rd.Id;
        
        insert opp;
       
        
        
        List<npe01__OppPayment__c> oppPayList = new List<npe01__OppPayment__c>();
        
        npe01__OppPayment__c oppPay1 = new npe01__OppPayment__c();
        oppPay1.npe01__Opportunity__c = opp.Id;
        oppPay1.RG_Processing_Batch__c = rgProcessingBatch.Id;
        oppPay1.Payment_Result__c = 'Success';
        oppPayList.add(oppPay1);
        

        insert oppPayList;
        
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Card_Token__c,npsp__Card_Expiration_Month__c,RG_Processing_Batch__c,
                                                  npsp__Card_Expiration_Year__c FROM npe01__OppPayment__c ];
        system.debug('From testmethod1:::::::::::'+paymentList);
        
        
        for(npe01__OppPayment__c payment : paymentList){
            payment.RG_Processing_Batch__c = rgProcessingBatch.Id;
            payment.Payment_Result__c = 'Success';
        }
        update paymentList;        
        
        Test.startTest();
        UpdateLastPaymentResultBatch uprb = new UpdateLastPaymentResultBatch();
        Database.executeBatch(uprb,50);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_FailSoft(){
        
        //RG_Processing_Batch__c rgProcessingBatchCC = [Select Id from RG_Processing_Batch__c limit 1];
        RG_Processing_Batch__c rgProcessingBatch = new RG_Processing_Batch__c();
        rgProcessingBatch.Batch_Unique_Identifier__c = 'CC_123456789';
        rgProcessingBatch.Payment_Method__c = 'Credit Card';
        rgProcessingBatch.Scheduled_Date__c = System.today();
        rgProcessingBatch.Batch_Status__c = 'Completed';
        
        insert rgProcessingBatch;
        
        
        Contact con1 = TestDataFactory.createContact(true);
        
        Campaign camp = TestDataFactory.createCampaign(true);
        
        
        
        
        npe03__Recurring_Donation__c rd1 = new npe03__Recurring_Donation__c();
        rd1.npe03__Amount__c = 50;
        rd1.npe03__Contact__c = con1.Id;
        rd1.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd1.npsp__PaymentMethod__c = 'Credit Card';
        rd1.Card_Token__c ='123';
        rd1.Card_Number_Masked__c = '123456780000';
        rd1.Payee_Name__c = 'Test Payee';
        rd1.Card_Type__c = 'Visa';
        rd1.On_Held_Date__c = Date.newinstance(2021, 12, 1);
        
        insert rd1;
               
        Account acc = TestDataFactory.createAccount(true);
        
        
        Opportunity opp1 =TestDataFactory.createOpportunity('Pledged',acc.Id,Date.newinstance(2022, 02, 01),false); 
        opp1.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        opp1.Amount = 100;
        opp1.CampaignId = camp.Id;
        opp1.npe03__Recurring_Donation__c = rd1.Id;
        
        insert opp1;
        
        
        List<npe01__OppPayment__c> oppPayList = new List<npe01__OppPayment__c>();
        
        
        npe01__OppPayment__c oppPay2 = new npe01__OppPayment__c();
        oppPay2.npe01__Opportunity__c = opp1.Id;
        oppPay2.RG_Processing_Batch__c = rgProcessingBatch.Id;
        oppPay2.Payment_Result__c = 'Fail Soft';
        oppPayList.add(oppPay2);
        
       
        
        
        insert oppPayList;
        
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Card_Token__c,npsp__Card_Expiration_Month__c,RG_Processing_Batch__c,
                                                  npsp__Card_Expiration_Year__c FROM npe01__OppPayment__c ];
        system.debug('From testmethod1:::::::::::'+paymentList);
        
        
        for(npe01__OppPayment__c payment : paymentList){
            payment.RG_Processing_Batch__c = rgProcessingBatch.Id;
            payment.Payment_Result__c = 'Fail Soft';
        }
        update paymentList;        
        
        Test.startTest();
        UpdateLastPaymentResultBatch uprb = new UpdateLastPaymentResultBatch();
        Database.executeBatch(uprb,50);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_FailHard(){
        
        //RG_Processing_Batch__c rgProcessingBatchCC = [Select Id from RG_Processing_Batch__c limit 1];
        RG_Processing_Batch__c rgProcessingBatch = new RG_Processing_Batch__c();
        rgProcessingBatch.Batch_Unique_Identifier__c = 'CC_123456789';
        rgProcessingBatch.Payment_Method__c = 'Credit Card';
        rgProcessingBatch.Scheduled_Date__c = System.today();
        rgProcessingBatch.Batch_Status__c = 'Completed';
        
        insert rgProcessingBatch;
        
        
        Contact con2 = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        
        
        
       
        npe03__Recurring_Donation__c rd2 = new npe03__Recurring_Donation__c();
        rd2.npe03__Amount__c = 50;
        rd2.npe03__Contact__c = con2.Id;
        rd2.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd2.npsp__PaymentMethod__c = 'Credit Card';
        rd2.Card_Token__c ='123';
        rd2.Card_Number_Masked__c = '123456780000';
        rd2.Payee_Name__c = 'Test Payee';
        rd2.Card_Type__c = 'Visa';
        rd2.On_Held_Date__c = Date.newinstance(2021, 12, 1);
        
        insert rd2;
        
        Account acc = TestDataFactory.createAccount(true);
        
        
        Opportunity opp2 =TestDataFactory.createOpportunity('Pledged',acc.Id,Date.newinstance(2022, 02, 01),false); 
        opp2.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        opp2.Amount = 100;
        opp2.CampaignId = camp.Id;
        opp2.npe03__Recurring_Donation__c = rd2.Id;
        
        insert opp2;
        
        List<npe01__OppPayment__c> oppPayList = new List<npe01__OppPayment__c>();
        
        
        
        npe01__OppPayment__c oppPay3 = new npe01__OppPayment__c();
        oppPay3.npe01__Opportunity__c = opp2.Id;
        oppPay3.RG_Processing_Batch__c = rgProcessingBatch.Id;
        oppPay3.Payment_Result__c = 'Fail Hard';
        oppPayList.add(oppPay3);
        
        
        insert oppPayList;
        
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Card_Token__c,npsp__Card_Expiration_Month__c,RG_Processing_Batch__c,
                                                  npsp__Card_Expiration_Year__c FROM npe01__OppPayment__c ];
        system.debug('From testmethod1:::::::::::'+paymentList);
        
        
        for(npe01__OppPayment__c payment : paymentList){
            payment.RG_Processing_Batch__c = rgProcessingBatch.Id;
            payment.Payment_Result__c = 'Fail Hard';
        }
        update paymentList;        
        
        Test.startTest();
        UpdateLastPaymentResultBatch uprb = new UpdateLastPaymentResultBatch();
        Database.executeBatch(uprb,50);
        Test.stopTest();
    }
}