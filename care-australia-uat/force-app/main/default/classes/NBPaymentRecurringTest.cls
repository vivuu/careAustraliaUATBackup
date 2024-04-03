@isTest
public class NBPaymentRecurringTest {
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
    
    static void init() {
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
        testAccount = NBTestDataFactory.createAccount('TestHousehold');        
        testOrgAccount = NBTestDataFactory.createOrgAccount('ACME');
        testContact = NBTestDataFactory.createContact(testAccount.Id, testFirstName, testLastName, testEmail);
        testCampaign = NBTestDataFactory.createCampaign();        
        testAmount = 5.00;
        
    }
    
    //String contact, Decimal amount, String session, String campaign, String paymentMethod, String paymentMode, String formURL
    static testMethod void nbRecurringDonationOrgTest() {
        init();
        System.debug('Account ID for Household: ' + testAccount.Id);
        System.debug('Account ID for ACME: ' + testOrgAccount.Id);
        Test.startTest();         
        Test.setMock(HttpCalloutMock.class, new NBHttpDonationMockTest()); 
       
        String restReturn = NBDonation.doPost(
          testSessionId, testFirstName, testLastName, testCampaign.Campaign_Code__c, 
          'monthly', 'Credit Card', testAmount, 
          'soruce', 'campaign', 'medium',
          testStreet, testCity, testState, testPostalCode, 'US',
          testPhone, testEmail, testURL,
          'organisation', 'ACME', 0,
          '123123123', '1234 **** **** 1234', 'Visa',
          '15', '12', '2025'
        );
        Test.stopTest();
        System.debug('Rest Return ' + restReturn);
        System.assert( null != restReturn );  
        
        // Split by ====
        Integer intIndex = restReturn.indexOf('====');
        String rcId = restReturn.substring((intIndex + 4));
        System.debug('Recurring Id ' + rcId);
        
        List<npe03__Recurring_Donation__c> oRGResult = [SELECT Id, Name, RG_Id__c, npe03__Organization__c,npsp__Status__c FROM npe03__Recurring_Donation__c WHERE RG_Id__c = :rcId];
        
        
        npe03__Recurring_Donation__c orgDonation;
        if ( null != oRGResult ) {
            for (npe03__Recurring_Donation__c oRGFound : oRGResult) {
                orgDonation = oRGFound;                                                
                break;
            }  
        }
        System.assert( null != orgDonation );
        if ( null != orgDonation ) {
            System.debug(orgDonation.npe03__Organization__c + ' ' + testOrgAccount.Id );
            System.assert( orgDonation.npe03__Organization__c == testOrgAccount.Id );            
            
        }        
    }
}