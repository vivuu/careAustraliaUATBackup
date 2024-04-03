@isTest
public class NBContactPhoneTest {
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
        
        
        String testPhone1 = '+610412345678';
        String testPhone2 = '+61412345677';
        String testPhone3 = '+04123123123';
               
        String phone1 = NBContact.doPost('111',testFirstName+'p1', testLastName,'','','10.00','224 Main St','Chicago','ACT','60010','AU', testPhone1, 'testEmailp1@test.com','','','');  
        String phone2 = NBContact.doPost('222',testFirstName+'p2', testLastName,'','','10.00','224 Main St','Chicago','ACT','60010','AU', testPhone2, 'testEmailp2@test.com','','','');  
        String phone3 = NBContact.doPost('333',testFirstName+'p3', testLastName,'','','10.00','224 Main St','Chicago','ACT','60010','AU', testPhone2, 'testEmailp3@test.com','','','');                
        
        Test.stopTest();               
        System.assert(null != phone1);
        System.assert(null != phone2);
        System.assert(null != phone3);
    }

}