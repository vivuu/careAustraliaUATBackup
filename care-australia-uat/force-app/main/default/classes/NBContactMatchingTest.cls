@isTest
public class NBContactMatchingTest {
    static Account testAccount;
    static Contact testContact;
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
        matchEmail  = 'testContact@test.com';
        //Account
        testAccount = NBTestDataFactory.createAccount('TestAccount');
        
        //Contact
        testContact = NBTestDataFactory.createContact(testAccount.Id, 'TestFirstName', 'TestLastName', matchEmail);
        
        testFirstName  = 'First';
        testLastName   = 'Last';
        testEmail      = 'test@test.com';
        testPhone 	   = '+61112345678';
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
        String matchStreet = NBContact.doPost('222', 'TestFirstName', 'TestLastName','','','10.00', testContact.MailingStreet,'Chicago','IL','60010','US', '', 'testEmailbbb@test.com','','',''); 
        
        String testPhone1 = '+610412345678';
        String testPhone2 = '+61412345677';
        String testPhone3 = '0412312312';        
        
        String matchp1   = NBContact.doPost('888',testFirstName+'pm', testLastName,'','','10.00','223 Main St','Chicago','IL','60010','US', testPhone1, 'testEmailp1@test.com','','',''); 
        String matchp2   = NBContact.doPost('999',testFirstName+'pm', testLastName,'','','10.00','224 Main St','Chicago','IL','60010','US', testPhone1, 'testEmailp2@test.com','','','');   
        
        String ausp2     = NBContact.doPost('000',testFirstName+'pm3', testLastName,'','','10.00','225 Main St','Chicago','ACT','60010','AU', testPhone3, 'testEmailp3@test.com','','','');  
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/NBContact/' + testContact.Id;
        req.httpMethod = 'GET';
    	RestContext.request = req;       
        Contact getResponse = NBContact.doGet();
        System.debug('Get Response: ' + getResponse.Id);
                
        req.requestURI = '/services/NBContact/' + ausp2;
        req.httpMethod = 'GET';
    	RestContext.request = req;       
        Contact getResponseAUSp2 = NBContact.doGet();
        System.debug('Get Response AUS p2: ' + getResponseAUSp2.Id);    
        System.debug('Get Response AUS mobile: ' + getResponseAUSp2.MobilePhone);
        System.debug('Get Response AUS home: ' + getResponseAUSp2.HomePhone);    
        
        Test.stopTest();    
        
        System.assertNotEquals('ERROR', ausp2);
        System.assertEquals('+61412312312', getResponseAUSp2.MobilePhone);
        System.assertEquals(testContact.Id, getResponse.Id);
        System.assertEquals(testContact.Id, matchStreet);
        
        System.assertEquals(matchp1, matchp2);
    }

}