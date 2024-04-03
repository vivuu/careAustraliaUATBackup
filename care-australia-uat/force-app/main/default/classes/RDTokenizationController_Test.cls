@istest
public class RDTokenizationController_Test  {
    @testSetup 
    public static void setup() {
        
        BamboraAPI__c bamboraSettings = new BamboraAPI__c();
        bamboraSettings.Name = 'Bambora';
        bamboraSettings.Merchant_ID__c = 'test';
        bamboraSettings.Username__c = 'Test';
        bamboraSettings.Password__c = 'Test';
        bamboraSettings.Cash_Account_Number__c = 'Test';
        bamboraSettings.RG_Account_Number__c = 'Test';
        bamboraSettings.Customer_Storage_Number__c = 'Test';
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
    }
    
    @isTest 
    public static void testmethod1(){
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        ApexPages.currentpage().getparameters().put('id' , rd.Id);
        
        Test.startTest();
        RDTokenizationController rdTokenization = new RDTokenizationController();
        rdTokenization.initVFP();
        RDTokenizationController.getRDRecords(rd.Id);
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
        
        
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
        reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
        ApexPages.currentpage().getparameters().put('id' , rd.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        RDTokenizationController rdTokenization = new RDTokenizationController(); 
        Test.startTest();
        rdTokenization.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,0));
        rdTokenization.getCCToken();
        Test.stopTest();
        
        
    }
    @isTest 
    static void testCallout_responce_1() {
        // Set mock callout class 
        
        
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
        reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
        ApexPages.currentpage().getparameters().put('id' , rd.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        RDTokenizationController rdTokenization = new RDTokenizationController(); 
        Test.startTest();
        rdTokenization.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,1));
        rdTokenization.getCCToken();
        Test.stopTest();
        
        
    }
    @isTest 
    static void testCallout_responce_2() {
        // Set mock callout class 
        
        
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
        reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
        ApexPages.currentpage().getparameters().put('id' , rd.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        RDTokenizationController rdTokenization = new RDTokenizationController(); 
        Test.startTest();
        rdTokenization.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,2));
        rdTokenization.getCCToken();
        Test.stopTest();
        
        
    }
    @isTest 
    static void testCallout_responce_4() {
        // Set mock callout class 
        
        
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
        reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
        ApexPages.currentpage().getparameters().put('id' , rd.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        RDTokenizationController rdTokenization = new RDTokenizationController(); 
        Test.startTest();
        rdTokenization.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,4));
        rdTokenization.getCCToken();
        Test.stopTest();
        
        
    } 
    @isTest 
    static void testCallout_responce_99() {
        // Set mock callout class 
        
        
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
        reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
        ApexPages.currentpage().getparameters().put('id' , rd.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        RDTokenizationController rdTokenization = new RDTokenizationController(); 
        Test.startTest();
        rdTokenization.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,99));
        rdTokenization.getCCToken();
        Test.stopTest();
        
        
    }
    @isTest 
    static void testCallout_responce_5068() {
        // Set mock callout class 
        
        
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        PageReference reference = Page.RDTokenizationVisualforce;
        Test.setCurrentPage(reference);
        reference.getparameters().put('stt' ,'Test-Test');
        reference.getparameters().put('payeeName' ,'Test-payeeName');
        ApexPages.currentpage().getparameters().put('id' , rd.Id);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        RDTokenizationController rdTokenization = new RDTokenizationController(); 
        Test.startTest();
        rdTokenization.initVFP();
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,5068));
        rdTokenization.getCCToken();
        Test.stopTest();
        
        
    }
}