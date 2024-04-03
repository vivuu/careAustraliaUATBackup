@isTest
public class NBDonationTest {

    static Account testAccount;
    static Contact testContact;
    static String testSession;
    static String testSession2;
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
    static String matchEmail;

    static npe01__OppPayment__c testPayment;
    static Campaign testCampaign;
    static Opportunity testOpportunity;
    static Opportunity testPPOpportunity;   
    static Decimal testAmount;
    
    static void init() {
        testSession    = 'testsession';
        testSession2    = 'testsession2';
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
        

        testCampaign = NBTestDataFactory.createCampaign();
        testPayment = NBTestDataFactory.createPayment(testCampaign);
        testOpportunity = NBTestDataFactory.createOpportunity(testCampaign);
        testPPOpportunity = NBTestDataFactory.createOpportunity(testCampaign);        
        testAmount = 5.00;   
    }
    
    //(String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode) {
	static testMethod void nbDonation() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBHttpDonationMockTest()); 
        
        String otccReturn = NBDonation.doPost(
          testSession, testFirstName, testLastName, testCampaign.Campaign_Code__c, 
          'one-off', 'Card', testAmount, 
          'soruce', 'campaign', 'medium',
          testStreet, testCity, testState, testPostalCode, 'US',
          testPhone, testEmail, testURL,
          '', '', 0,
          '123123123', '1234 **** **** 1234', 'Visa',
          '', '', ''
        );

        String otccReturn2 = NBDonation.doPost(
          testSession2, testFirstName, testLastName, testCampaign.Campaign_Code__c, 
          'one-off', 'Card', testAmount, 
          'soruce', 'campaign', 'medium',
          testStreet, testCity, testState, testPostalCode, 'US',
          testPhone, testEmail, testURL,
          '', '', 0,
          '123123123', '1234 **** **** 1234', 'Visa',
          '', '', ''
        );

        String otccReturnDupe = NBDonation.doPost(
          testSession, testFirstName, testLastName, testCampaign.Campaign_Code__c, 
          'one-off', 'Card', testAmount, 
          'soruce', 'campaign', 'medium',
          testStreet, testCity, testState, testPostalCode, 'US',
          testPhone, testEmail, testURL,
          '', '', 0,
          '123123123', '1234 **** **** 1234', 'Visa',
          '', '', ''
        );

        Test.stopTest();
        System.debug('Test1: ' + otccReturn);
        System.debug('Test2: ' + otccReturn2);
        System.debug('Test3: ' + otccReturnDupe);
        System.assert( null != otccReturn );
        System.assert( null != otccReturn2 );
        System.assert( otccReturn == otccReturnDupe );
    }
}