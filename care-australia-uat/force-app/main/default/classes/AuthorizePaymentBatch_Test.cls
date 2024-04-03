@istest
public class AuthorizePaymentBatch_Test  {
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

        
        RG_Processing_Batch__c rgProcessingBatch = new RG_Processing_Batch__c();
        rgProcessingBatch.Batch_Status__c = 'Submitted';
        rgProcessingBatch.Batch_Unique_Identifier__c = '123456';
        rgProcessingBatch.Scheduled_Date__c = Date.today();
        rgProcessingBatch.Payment_Method__c = 'Credit Card';
        rgProcessingBatch.Total_Transactions__c = 2;
        rgProcessingBatch.Total_Amount__c =3000;
        insert rgProcessingBatch;
        

    }
    @isTest 
    public static void testmethod_responce_0(){
		System.debug([SELECT Id, Batch_Unique_Identifier__c, Scheduled_Date__c, Payment_Method__c, Total_Transactions__c, 
                      Batch_Status__c, Total_Amount__c, Status_Description__c, Name FROM RG_Processing_Batch__c]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,0));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }
     @isTest 
    public static void testmethod_responce_1(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,1));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }
     @isTest 
    public static void testmethod_responce_2(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,2));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }
     @isTest 
    public static void testmethod_responce_3(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,3));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }
     @isTest 
    public static void testmethod_responce_4(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,4));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }
     @isTest 
    public static void testmethod_responce_5(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,5));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_99(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,99));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod_responce_ELSE(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraAuthoriseBatchTrnFileMock(200,50));
        AuthorizePaymentBatch apb = new AuthorizePaymentBatch();
        Database.executeBatch(apb);
        Test.stopTest();
    }

}