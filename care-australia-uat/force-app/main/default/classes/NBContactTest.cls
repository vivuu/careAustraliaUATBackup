@isTest
public class NBContactTest {
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
        String ausResponse   = NBContact.doPost('2222',testFirstName+'aus', testLastName+'aus','','','10.00','3333 Main St','Chicago','ACT','60010','AU', '+61412345678', 'aus' + testEmail,'', '', '');         
        String newResponseNoPhone   = NBContact.doPost('333',testFirstName, testLastName,'','','10.00','444 Main St','Chicago','IL','60010','US', '', 'testEmailaaaa@test.com','','','');                    
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/NBContact/' + testContact.Id;
        System.debug('REQUEST URI: ' + req.requestURI);
        req.httpMethod = 'GET';
    	RestContext.request = req;
        Contact getResponse = NBContact.doGet();
        System.debug('Get Response: ' + getResponse.Id);
        
        //DateTime Conversion
        DateTime testDate = NBContactHelper.transformDate('2023-01-01T00:00:00.000');
        System.assertNotEquals(null, testDate);  
        
        Test.stopTest();
        System.assertNotEquals('ERROR', ausResponse);      
        System.assertNotEquals('ERROR', newResponseNoPhone);
        
        System.assert( null != newResponseNoPhone );
        System.assertEquals(testContact.Id, getResponse.Id);                   
    }

}