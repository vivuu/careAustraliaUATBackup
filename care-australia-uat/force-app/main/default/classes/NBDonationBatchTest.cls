@isTest
public class NBDonationBatchTest {
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
    static String processedDate;
    static String serviceFee;

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
        processedDate  = '2023-06-01T00:00:00.000';
        serviceFee     = '3.2';
        

        testCampaign = NBTestDataFactory.createCampaign();
        testPayment = NBTestDataFactory.createPayment(testCampaign);
        testOpportunity = NBTestDataFactory.createOpportunity(testCampaign);
        testPPOpportunity = NBTestDataFactory.createOpportunity(testCampaign);        
        testAmount = 5.00;   
    }
    
    //(String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode) {
	static testMethod void nbDonationBatch() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBHttpDonationMockTest()); 
        
        String otcc1 = testSession + ',' +
            '127.0.0.1' + ',' +
            testFirstName + ',' +
            testLastName + ',' +
            testCampaign.Campaign_Code__c  + ',' +
            'one-off' + ',' +
            'CreditCard' + ',' +
            testAmount + ',' +
            testStreet + ',' +
            testCity + ',' +
            testState + ',' +
            testPostalCode + ',' +
            'US' + ',' +
            testPhone + ',' +
            testEmail + ',' +
            ' ,' +
            ' ,' +
            testURL  + ',' +
            'soruce' + ',' +
            'campaign' + ',' +
            'medium' + ',' +
            '123123123'  + ',' +
            '' + ',' +
            '1234 **** **** 1234'  + ',' +
            'Visa'  + ',' +
            ' ' + ',' +
            ' ' + ',' +
            processedDate + ',' +
            serviceFee;

            // Trigger Duplicate on session
            String otccd = testSession + ',' +
            '127.0.0.1' + ',' +
            testFirstName + ',' +
            testLastName + ',' +
            testCampaign.Campaign_Code__c  + ',' +
            'one-off' + ',' +
            'CreditCard' + ',' +
            testAmount + ',' +
            testStreet + ',' +
            testCity + ',' +
            testState + ',' +
            testPostalCode + ',' +
            'US' + ',' +
            testPhone + ',' +
            testEmail + ',' +
            ' ,' +
            ' ,' +
            testURL  + ',' +
            'soruce' + ',' +
            'campaign' + ',' +
            'medium' + ',' +
            '123123123'  + ',' +
            '' + ',' +
            '1234 **** **** 1234'  + ',' +
            'Visa'  + ',' +
            ' ' + ',' +
            ' ' + ',' +
            processedDate + ',' +
            serviceFee;

            // Trigger campaign error
            String otcc2 = testSession2 + ',' +
            '127.0.0.1' + ',' +
            testFirstName + ',' +
            testLastName + ',' +
            ''  + ',' +
            'one-off' + ',' +
            'CreditCard' + ',' +
            testAmount + ',' +
            testStreet + ',' +
            testCity + ',' +
            testState + ',' +
            testPostalCode + ',' +
            'US' + ',' +
            testPhone + ',' +
            testEmail + ',' +
            ' ,' +
            ' ,' +
            testURL  + ',' +
            'soruce' + ',' +
            'campaign' + ',' +
            'medium' + ',' +
            '123123123'  + ',' +
            '' + ',' +
            '1234 **** **** 1234'  + ',' +
            'Visa'  + ',' +
            ' ' + ',' +
            ' ' + ',' +
            processedDate + ',' +
            serviceFee;

        String[] batchDonations = new List<String>();
        batchDonations.add(otcc1);
        batchDonations.add(otcc2);
        batchDonations.add(otccd);

        String paymentResult = NBDonationBatch.doPost(batchDonations);
        
        Test.stopTest();
        
        System.assert( null != paymentResult );
        
    }
}