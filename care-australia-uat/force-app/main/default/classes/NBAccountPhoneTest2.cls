@isTest
public class NBAccountPhoneTest2 {
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
        
        // Create a other phone matched contact
        String matchResponsePhone2 = NBContact.doPost('111', testFirstName, testLastName, '','','10.00','2222 Main St','Chicago','IL','60010','US', testPhone, 'matchresponsephone' + matchEmail,'', 'organisation', 'NOT ACME'); 
        
        String newResponse2 = NBContact.doPost('333', testFirstName, testLastName,'','','10.00','333 Main St','Chicago','IL','60010','US', testOtherPhone, 'newresponseother' + testEmail,'', 'organisation', 'NOT ACME'); 
        
        String matchResponseOther2 = NBContact.doPost('333', testFirstName, testLastName,'','','10.00','333 Main St','Chicago','IL','60010','US', testOtherPhone, 'matchresponseother' + testEmail,'', 'organisation', 'NOT ACME');          
        
        Test.stopTest();
        String lookupEmail = 'matchresponseother' + testEmail;
        System.debug('Lookup Email: ' + lookupEmail);
        Contact contactResponseOtherPhone;
        List<Contact> foundContacts = [SELECT Id, AccountId, Email, OtherPhone FROM Contact where Email = :lookupEmail];                
        for (Contact currentContact : foundContacts) {
            System.debug('Found Contact: ' + currentContact.Id);
            contactResponseOtherPhone = currentContact;
            break;
        }
        
        System.debug('matchResponsePhone2: ' + matchResponsePhone2);
        System.debug('newResponse2: ' + matchResponsePhone2);
        System.debug('matchResponseOther2: ' + matchResponsePhone2);                
               
        System.assertNotEquals('ERROR', matchResponsePhone2);   
        System.assertNotEquals('ERROR', newResponse2);   
        System.assertNotEquals('ERROR', matchResponsePhone2); 
        System.assertNotEquals(null, contactResponseOtherPhone.OtherPhone);
        
        System.assertEquals(contactResponseOtherPhone.OtherPhone, testOtherPhone);  
        System.assertEquals(newResponse2, matchResponseOther2);
              	
    }

}