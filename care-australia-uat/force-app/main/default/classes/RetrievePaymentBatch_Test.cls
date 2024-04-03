@istest
public class RetrievePaymentBatch_Test  {
    @testSetup 
    public static void setup() {
        BamboraAPI__c bamboraSettings = new BamboraAPI__c();
        bamboraSettings.Name = 'Bambora';
        bamboraSettings.Merchant_ID__c = 'test';
        bamboraSettings.Username__c = 'Test';
        bamboraSettings.Password__c = 'Test';
        bamboraSettings.Cash_Account_Number__c = 'Test';
        bamboraSettings.RG_Account_Number__c = 'Test';
        bamboraSettings.Batch_API__c = 'https://demo.ippayments.com.au/interface/api/batch.asmx';
        bamboraSettings.Payment_API__c = 'https://demo.ippayments.com.au/interface/api/dts.asmx';
        bamboraSettings.TokeniseCC_API__c = 'https://demo.ippayments.com.au/interface/api/sipp.asmx';
        insert bamboraSettings;
        
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 50;
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.Card_Token__c ='123456';
        rd.Card_Number_Masked__c = '123456780000';
        rd.Card_Type__c = 'Visa';
        insert rd;
        
        
        npe03__Recurring_Donation__c rd1 = new npe03__Recurring_Donation__c();
        rd1.npe03__Amount__c = 150;
        rd1.npe03__Contact__c = con.Id;
        rd1.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd1.npsp__PaymentMethod__c = 'Credit Card';
        rd1.Card_Token__c ='123456';
        rd1.Card_Number_Masked__c = '123456780000';
        rd1.Card_Type__c = 'Visa';
        insert rd1;
        
        npe03__Recurring_Donation__c rd2 = new npe03__Recurring_Donation__c();
        rd2.npe03__Amount__c = 250;
        rd2.npe03__Contact__c = con.Id;
        rd2.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd2.npsp__PaymentMethod__c = 'Credit Card';
        rd2.Card_Token__c ='123456';
        rd2.Card_Number_Masked__c = '123456780000';
        rd2.Card_Type__c = 'Visa';
        insert rd2;
        
        npe03__Recurring_Donation__c rd3 = new npe03__Recurring_Donation__c();
        rd3.npe03__Amount__c = 250;
        rd3.npe03__Contact__c = con.Id;
        rd3.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd3.npsp__PaymentMethod__c = 'Direct Debit';
        rd3.Account_Number__c ='123456';
        rd3.Account_BSB__c = '123-456';
        rd3.Financial_Institution__c = 'CITI';
        rd3.Payee_Name__c = 'Test Payee';
        insert rd3;
        
        RG_Processing_Batch__c rgProcessingBatchCC = new RG_Processing_Batch__c();
        rgProcessingBatchCC.Batch_Status__c = 'Authorized';
        rgProcessingBatchCC.Batch_Unique_Identifier__c = '123456';
        rgProcessingBatchCC.Scheduled_Date__c = Date.today();
        rgProcessingBatchCC.Payment_Method__c = 'Credit Card';
        rgProcessingBatchCC.Total_Transactions__c = 2;
        rgProcessingBatchCC.Total_Amount__c =3000;
        insert rgProcessingBatchCC;
        
        RG_Processing_Batch__c rgProcessingBatchDD = new RG_Processing_Batch__c();
        rgProcessingBatchDD.Batch_Status__c = 'Authorized';
        rgProcessingBatchDD.Batch_Unique_Identifier__c = '123456';
        rgProcessingBatchDD.Scheduled_Date__c = Date.today();
        rgProcessingBatchDD.Payment_Method__c = 'Direct Debit';
        rgProcessingBatchDD.Total_Transactions__c = 1;
        rgProcessingBatchDD.Total_Amount__c =7000;
        insert rgProcessingBatchDD;
        
        List<RG_Response__c> rgResponseList = new List<RG_Response__c>();
        
        RG_Response__c rgSuccessResponse = new RG_Response__c();
        rgSuccessResponse.Response_Code__c = '0' ;
        rgSuccessResponse.Result_Description__c = 'Approved' ;
        rgSuccessResponse.Payment_Result__c  = 'Success' ;
        rgSuccessResponse.Merchant_Category__c = 'Bambora' ;
        rgSuccessResponse.Payment_Method__c = 'Credit Card' ;
        rgResponseList.add(rgSuccessResponse);
        
        RG_Response__c rgFailHardResponse = new RG_Response__c();
        rgFailHardResponse.Response_Code__c = '12' ;
        rgFailHardResponse.Result_Description__c = 'Invalid Transaction' ;
        rgFailHardResponse.Payment_Result__c  = 'Fail Hard' ;
        rgFailHardResponse.Merchant_Category__c = 'Bambora' ;
        rgFailHardResponse.Payment_Method__c = 'Credit Card' ;
        rgResponseList.add(rgFailHardResponse);
        
        RG_Response__c rgFailSoftResponse = new RG_Response__c();
        rgFailSoftResponse.Response_Code__c = '5' ;
        rgFailSoftResponse.Result_Description__c = 'Do Not Honour' ;
        rgFailSoftResponse.Payment_Result__c  = 'Fail Soft' ;
        rgFailSoftResponse.Merchant_Category__c = 'Bambora' ;
        rgFailSoftResponse.Payment_Method__c = 'Credit Card' ;
        rgResponseList.add(rgFailSoftResponse);
        
        insert rgResponseList;
        
        
    }
    @isTest 
    public static void testmethod1_responce_CC0(){
        RG_Processing_Batch__c rgProcessingBatchCC = [Select Id from RG_Processing_Batch__c Where Payment_Method__c = 'Credit Card' limit 1];
        List<npe03__Recurring_Donation__c> ccRD = [Select Id from npe03__Recurring_Donation__c where npsp__PaymentMethod__c = 'Credit Card'];
        
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Card_Token__c,npsp__Card_Expiration_Month__c,
                                                  npsp__Card_Expiration_Year__c 
                                                  FROM npe01__OppPayment__c where npe01__Opportunity__r.npe03__Recurring_Donation__c IN:ccRD limit 3];
        system.debug('From testmethod1:::::::::::'+paymentList);
        
        
        String details = '';
        for(npe01__OppPayment__c payment : paymentList){
            payment.npe01__Payment_Method__c = 'Credit Card';
            payment.RG_Processing_Batch__c = rgProcessingBatchCC.Id;
            payment.Payment_Result__c = 'Processing';
            payment.Card_Token__c = '123456';
            payment.npsp__Card_Expiration_Month__c = '11';
            payment.npsp__Card_Expiration_Year__c = '25';
            
        }
        details += '1,9083427236956799,0,,,PMT-0001,'+paymentList[0].Id+',6000,21310788,,,,,';
        details += '\r\n';
        details += '1,9677701960027262,1,5,Do Not Honour,PMT-0002,'+paymentList[1].Id+',1000,21310787,,,,,';
        details += '\r\n';
        details += '1,9557831353768290,1,500,Unknown Error,PMT-0003,'+paymentList[2].Id+',5000,21310789,,,,,';
        details += '\r\n';
        update paymentList;
        
        String Header ='CC_202109221741683';
        String footer = '3,12000';
        String finalOutputString = Header + '\r\n' + details + footer;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,0,finalOutputString));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod2_responce_CC0(){
        RG_Processing_Batch__c rgProcessingBatchCC = [Select Id from RG_Processing_Batch__c Where Payment_Method__c = 'Credit Card' limit 1];
        List<npe03__Recurring_Donation__c> ccRD = [Select Id from npe03__Recurring_Donation__c where npsp__PaymentMethod__c = 'Credit Card'];
        
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Card_Token__c,npsp__Card_Expiration_Month__c,
                                                  npsp__Card_Expiration_Year__c 
                                                  FROM npe01__OppPayment__c where npe01__Opportunity__r.npe03__Recurring_Donation__c IN:ccRD limit 3];
        system.debug('From testmethod1:::::::::::'+paymentList);
        
        list<Opportunity> oppList = [Select Id,Retry_Attempt__c from Opportunity where npe03__Recurring_Donation__c IN:ccRD limit 3 ];
        
        for(Opportunity opp : oppList){
            opp.Retry_Attempt__c = 5;
        }
        
        update oppList;
        String details = '';
        for(npe01__OppPayment__c payment : paymentList){
            payment.npe01__Payment_Method__c = 'Credit Card';
            payment.RG_Processing_Batch__c = rgProcessingBatchCC.Id;
            payment.Payment_Result__c = 'Processing';
            payment.Card_Token__c = '123456';
            payment.npsp__Card_Expiration_Month__c = '11';
            payment.npsp__Card_Expiration_Year__c = '25';
            
        }
        details += '1,9083427236956799,0,,,PMT-0004,'+paymentList[0].Id+',6000,21310788,,,,,';
        details += '\r\n';
        details += '1,9677701960027262,1,5,Do Not Honour,PMT-0005,'+paymentList[1].Id+',1000,21310787,,,,,';
        details += '\r\n';
        details += '1,9557831353768290,1,12,Invalid Transaction,PMT-0006,'+paymentList[2].Id+',5000,21310789,,,,,';
        details += '\r\n';
        update paymentList;
        
        String Header ='CC_202109221741683';
        String footer = '3,12000';
        String finalOutputString = Header + '\r\n' + details + footer;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,0,finalOutputString));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_DD0(){
        RG_Processing_Batch__c rgProcessingBatchDD = [Select Id from RG_Processing_Batch__c Where Payment_Method__c = 'Direct Debit' limit 1];
        List<npe03__Recurring_Donation__c> ddRD = [Select Id from npe03__Recurring_Donation__c where npsp__PaymentMethod__c = 'Direct Debit'];
        
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Financial_Institution__c,Account_BSB__c,Payee_Name__c,
                                                  Account_Number__c 
                                                  FROM npe01__OppPayment__c where npe01__Opportunity__r.npe03__Recurring_Donation__c IN:ddRD limit 1];
        system.debug('From testmethod1:::::::::::'+paymentList);
        String details = '';
        
        for(npe01__OppPayment__c payment : paymentList){
            payment.npe01__Payment_Method__c = 'Direct Debit';
            payment.RG_Processing_Batch__c = rgProcessingBatchDD.Id;
            payment.Account_Number__c ='123456';
            payment.Payment_Result__c = 'Processing';
            payment.Account_BSB__c = '123-456';
            payment.Financial_Institution__c = 'CITI';
            payment.Payee_Name__c = 'Test Payee';
            
        }
        details += '7,0,,,PMT-0007,'+paymentList[0].Id+',7000,21311983,,,,,';
        details += '\r\n';
        //details += '1,9677701960027262,1,5,Do Not Honour,'+paymentList[1].Id+',006p000000A2pUoAAJ,1000,21310787,,,,,';
        //details += '\r\n';
        //details += '1,9557831353768290,1,12,Invalid Transaction,'+paymentList[2].Id+',006p000000A2pX1AAJ,5000,21310789,,,,,';
        //details += '\r\n';
        update paymentList;
        
        String Header ='DD_202109221741683';
        String footer = '1,7000';
        String finalOutputString = Header + '\r\n' + details + footer;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,0,finalOutputString));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,1,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,2,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_3(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,3,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_4(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,4,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_5(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,5,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_6(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,6,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_7(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,7,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_99(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,99,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_ELSE(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraRetrieveBatchResultFileMock(200,50,'Test'));
        RetrievePaymentBatch rpb = new RetrievePaymentBatch();
        Database.executeBatch(rpb);
        Test.stopTest();
    }
}