@isTest
public class NBContactTest2 {
    static Account testAccount;
    static Contact testContact;
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
    
    static void init() {
        matchEmail  = 'testContact@test.com';
        //Account
        testAccount = NBTestDataFactory.createAccount('TestAccount');
        
        //Contact
        testContact = NBTestDataFactory.createContact(testAccount.Id, 'TestFirstName', 'TestLastName', matchEmail);
        
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
    }
    
    static testMethod void nbContact() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBHttpContactMockTest()); 
        String matchResponse = NBContact.doPost('111','TestFirstName', 'TestLastName', '','','10.00','222 Main St','Chicago','IL','60010','US', '', matchEmail, '', '', ''); 
        String newResponse   = NBContact.doPost('222',testFirstName, testLastName,'','','10.00','333 Main St','Chicago','IL','60010','US', testPhoneM, testEmail,'', '', ''); 
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/NBContact/' + newResponse;
        System.debug('REQUEST URI: ' + req.requestURI);
        req.httpMethod = 'GET';
    	RestContext.request = req;
        Contact contactResponseM = NBContact.doGet();
        System.assert( (null != contactResponseM.HomePhone || null != contactResponseM.MobilePhone ) );   

        Test.stopTest();
        System.assertNotEquals('ERROR', newResponse);
        System.assertNotEquals('ERROR', matchResponse);
        
        System.assertEquals(testContact.Id, matchResponse);
        System.assertNotEquals(testContact.Id, newResponse);
    }

}