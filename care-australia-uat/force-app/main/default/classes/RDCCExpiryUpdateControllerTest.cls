@istest
public class RDCCExpiryUpdateControllerTest {
    static Account testAccount;
    static Account testOrgAccount;
    static Contact testContact;
    static Opportunity testReccuringOpp;
    static Campaign testCampaign;
    static String testSessionId;
    static Decimal testAmount;
    static String testFirstName;
	static String testLastName;
	static String testEmail;
	static String testPhone;
    static String testPhoneM;
	static String testStreet;
    static String testCity;
    static String testState;
    static String testPostalCode;
    static String testSource;
    static String testURL;
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
        
        testFirstName  = 'First';
        testLastName   = 'Last';
        testEmail      = 'test@test.com';
        testPhone 	   = '+61112345678';
        testPhoneM 	   = '+610423456789';
        testStreet     = '123 Main Street';
        testCity       = 'Somecity';
        testState      = 'Somestate';
        testPostalCode = 'PCODE';
        testSource     = 'General';
        testURL        = 'https://example.com';
        testSessionId = 'SessionTest000';		
        testContact = TestDataFactory.createContact(true);
        testCampaign = TestDataFactory.createCampaign(true);
        testAmount = 5.00;
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 100;
        rd.npe03__Contact__c = testContact.Id;
        rd.npe03__Recurring_Donation_Campaign__c = testCampaign.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.npsp__Status__c = 'Active';
        insert rd;
        
    }
    @isTest 
    static void testGetRD() {
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        Test.startTest();
        
		RDCCExpiryUpdateController.getRD(rd.Id);        
        Test.stopTest();
    }
    @isTest 
    static void testCallout_responce_200_0() {
        Boolean exceptionOccurred = false;
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,0));
        try{
		RDCCExpiryUpdateController.updateExpiry(rd.Id, '01', '2033'); 
        }
        catch(Exception e)
        {
            exceptionOccurred=true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');

        Test.stopTest();
    }
    @isTest 
    static void testCallout_responce_200_1() {
        Boolean exceptionOccurred = false;
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,1));
		try{
		RDCCExpiryUpdateController.updateExpiry(rd.Id, '01', '2033'); 
        }
        catch(Exception e)
        {
            exceptionOccurred=true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');        
        Test.stopTest();
    }
    @isTest 
    static void testCallout_responce_200_2() {
        Boolean exceptionOccurred = false;
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,2));
		try{
		RDCCExpiryUpdateController.updateExpiry(rd.Id, '01', '2033'); 
        }
        catch(Exception e)
        {
            exceptionOccurred=true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');       
        Test.stopTest();
    }
    @isTest 
    static void testCallout_responce_200_4() {
        Boolean exceptionOccurred = false;
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,4));
		try{
		RDCCExpiryUpdateController.updateExpiry(rd.Id, '01', '2033'); 
        }
        catch(Exception e)
        {
            exceptionOccurred=true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');        
        Test.stopTest();
    }
    @isTest 
    static void testCallout_responce_200_99() {
        Boolean exceptionOccurred = false;
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,99));
		try{
		RDCCExpiryUpdateController.updateExpiry(rd.Id, '01', '2033'); 
        }
        catch(Exception e)
        {
            exceptionOccurred=true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');        
        Test.stopTest();
    }
    @isTest 
    static void testCallout_responce_200_5096() {
        Boolean exceptionOccurred = false;
        npe03__Recurring_Donation__c rd = [select Id from npe03__Recurring_Donation__c limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new BamboraCCTokenizationTestMock(200,5096));
		try{
		RDCCExpiryUpdateController.updateExpiry(rd.Id, '01', '2033'); 
        }
        catch(Exception e)
        {
            exceptionOccurred=true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');        
        Test.stopTest();
    }

}