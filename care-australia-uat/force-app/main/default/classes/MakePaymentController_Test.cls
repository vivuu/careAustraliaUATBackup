@istest
public class MakePaymentController_Test  {
    @testSetup 
    public static void setup() {
        
        BamboraAPI__c bamboraSettings = new BamboraAPI__c();
        bamboraSettings.Name = 'Bambora';
        bamboraSettings.Merchant_ID__c = 'test';
        bamboraSettings.Username__c = 'RG Test';
        bamboraSettings.Password__c = 'RG Test';
        bamboraSettings.Cash_Username__c = 'Cash Test';
        bamboraSettings.Cash_Password__c = 'Cah Test';
        bamboraSettings.Cash_Account_Number__c = 'Test';
        bamboraSettings.RG_Account_Number__c = 'Test';
        bamboraSettings.Batch_API__c = 'https://demo.ippayments.com.au/interface/api/batch.asmx';
        bamboraSettings.Payment_API__c = 'https://demo.ippayments.com.au/interface/api/dts.asmx';
        bamboraSettings.TokeniseCC_API__c = 'https://demo.ippayments.com.au/interface/api/sipp.asmx';
        insert bamboraSettings;
        
        
        
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 100;
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.npsp__Status__c = 'Active';
        insert rd;
        
      /* npe01__OppPayment__c payment = new npe01__OppPayment__c();
       payment.npe01__Payment_Amount__c = 100;
       inseRt payment;*/
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
        
         RG_Response__c rgERRORResponse = new RG_Response__c();
        rgERRORResponse.Response_Code__c = 'ERROR' ;
        rgERRORResponse.Result_Description__c = 'Unknown Error' ;
        rgERRORResponse.Payment_Result__c  = 'ERROR' ;
        rgERRORResponse.Merchant_Category__c = 'Bambora' ;
        rgERRORResponse.Payment_Method__c = 'Credit Card' ;
        rgResponseList.add(rgERRORResponse);
        
        insert rgResponseList;
    }
    
    @isTest 
    public static void testmethod1(){
        npe01__OppPayment__c payment = [SELECT Id, npe01__Payment_Amount__c FROM npe01__OppPayment__c limit 1];
        ApexPages.currentpage().getparameters().put('id' , payment.Id);
        
        Test.startTest();
        MakePaymentController makePayment = new MakePaymentController();
        makePayment.initVFP();
        MakePaymentController.getPaymentRecords(payment.Id);
        Test.stopTest();
        
    }
    /*@isTest 
    public static void testmethod2(){
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        PageReference reference = Page.RDTokenizationVisualforce;
        
        Test.startTest();
        Test.setCurrentPage(reference);
       	reference.getparameters().put('stt' ,'Test-Test');
        RDTokenizationController rdTokenization = new RDTokenizationController();
        rdTokenization.getCCToken();
        Test.stopTest();
    }*/
    @isTest 
    static void testCallout_responce_0() {
        // Set mock callout class 
       
        
        npe01__OppPayment__c payment = [SELECT Id, npe01__Payment_Amount__c FROM npe01__OppPayment__c limit 1];
         PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
       	reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
         ApexPages.currentpage().getparameters().put('id' , payment.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
         MakePaymentController makePayment = new MakePaymentController();
        Test.startTest();
        makePayment.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraMakePaymentMock(200,0));
        makePayment.makePayment();
        Test.stopTest();
        
        
    }
    @isTest 
    static void testCallout_responce_500() {
        // Set mock callout class 
       
        
        npe01__OppPayment__c payment = [SELECT Id, npe01__Payment_Amount__c FROM npe01__OppPayment__c limit 1];
         PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
       	reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
         ApexPages.currentpage().getparameters().put('id' , payment.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
         MakePaymentController makePayment = new MakePaymentController();
        Test.startTest();
        makePayment.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraMakePaymentMock(200,500));
        makePayment.makePayment();
        Test.stopTest();
        
        
    }

    @isTest 
    static void testCallout_responce_5068() {
        // Set mock callout class 
       
        
        npe01__OppPayment__c payment = [SELECT Id, npe01__Payment_Amount__c FROM npe01__OppPayment__c limit 1];
         PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
       	reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
         ApexPages.currentpage().getparameters().put('id' , payment.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
         MakePaymentController makePayment = new MakePaymentController();
        Test.startTest();
        makePayment.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraMakePaymentMock(200,5068));
        makePayment.makePayment();
        Test.stopTest();
        
        
    }
}