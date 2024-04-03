@isTest
public class NBAccountPhoneTest {
    static Account testAccount;
	static String testFirstName;
	static String testLastName;
	static String testEmail;
	static String testPhone;
	static String testStreet;
    static String testCity;
    static String testState;
    static String testPostalCode;
    static String testSource;
    static String testURL;
    static String matchEmail;
    
    static void init() {
        //Account
        testAccount = NBTestDataFactory.createOrgAccount('ACME');
        testFirstName  = 'First';
        testLastName   = 'Last';
        testEmail      = 'testorg@test.com';
        testPhone 	   = '+61112345670';
        testStreet     = '123 Main Street';
        testCity       = 'Somecity';
        testState      = 'Somestate';
        testPostalCode = 'PCODE';
        testSource     = 'General';
        testURL        = 'https://example.com';
        matchEmail     = 'match@match.com';
    }
    
    static testMethod void nbAccount() {
        init();
        Test.startTest();        
        String testPhoneMobile = '+61412345677'; 
        String testOtherPhone  = '1231231234';
        Test.setMock(HttpCalloutMock.class, new NBHttpContactMockTest());          
        // Create a record that matches an account by name and contact by phone
        String matchResponsePhone = NBContact.doPost('111','TestFirstName', 'TestLastName', '','','10.00','2222 Main St','Chicago','IL','60010','US', testPhone, matchEmail,'', 'organisation', 'ACME'); 
        // Create a new account
        String newResponse = NBContact.doPost('222', testFirstName, testLastName,'','','10.00','333 Main St','Chicago','IL','60010','US', testPhoneMobile, testEmail,'', 'organisation', 'NOT ACME'); 
        // Create a mobile phone matched contact
        String newResponsePhone1   = NBContact.doPost('222', testFirstName, testLastName,'','','10.00','333 Main St','Chicago','IL','60010','US', testPhoneMobile, 'newresponse' + testEmail,'', 'organisation', 'NOT ACME'); 
        
        Test.stopTest();
        
        System.debug('TestAccount: ' + testAccount.Id);        
        System.debug('newResponse: ' + newResponse);
        System.debug('newResponsePhone1: ' + newResponsePhone1);
               
        System.assertNotEquals('ERROR', newResponse);      
        System.assertNotEquals('ERROR', newResponsePhone1);   
              
        System.assertEquals(newResponse, newResponsePhone1);
        System.assertNotEquals(testAccount.Id, newResponse);     
              	
    }

}