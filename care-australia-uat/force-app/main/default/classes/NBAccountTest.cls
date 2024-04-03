@isTest
public class NBAccountTest {
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
    static String updatedMatchEmail;
    
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
        updatedMatchEmail = 'amatch@match.com';
    }
    
    static testMethod void nbAccount() {
        init();
        Test.startTest();        
                    
        Test.setMock(HttpCalloutMock.class, new NBHttpContactMockTest()); 
        String testAmount = '10.00';
        // Create a record that matches an account by name - direct match
        String matchResponse = NBContact.doPost('111','TestFirstName', 'TestLastName', '','', testAmount,'222 Main St','Chicago','IL','60010','US','', matchEmail,'', 'organisation', 'ACME'); 
        // Create a record that matches an account by matching rules - indirect match
        String matchResponse2 = NBContact.doPost('111','TestFirstName', 'TestLastName', '','', testAmount,'222 Main St','Chicago','IL','60010','US','', matchEmail,'', 'organisation', 'ACME', 2);       
        // Create a record that matches a contact by street
        String matchResponse3 = NBContact.doPost('111','TestFirstName', 'TestLastName', '','', testAmount, '222 Main St','Chicago','IL','60010','US','', updatedMatchEmail, '', 'organisation', 'ACME LLC', 2);  

        /*
        doPost(String sessionId, String firstName, String lastName, String campaign, String paymentMode, Decimal amount, 
                                String street, String city, String state, String postalCode, String country,
                                String phone, String email, String formURL,
                                String contactMode, String organisation) {
        */
 
        Test.stopTest();
        System.debug('TestAccount: ' + testAccount.Id);
        System.debug('matchResponse: ' + matchResponse);
        System.debug('matchResponse2: ' + matchResponse2);
        System.debug('matchResponse3: ' + matchResponse3);                
        
        System.assertNotEquals('ERROR', matchResponse);  
        System.assertNotEquals('ERROR', matchResponse2);  
        System.assertNotEquals('ERROR', matchResponse3);   
        
        System.assertEquals(testAccount.Id, matchResponse);
        // Cannot be test unless duplicate rules on organisation accounts are turned on.
        //System.assertEquals(matchResponse2, matchResponse); 
        System.assertNotEquals(matchResponse2, matchResponse3);

        //Check primary and affiliatons
        Id accountId = testAccount.Id;
        List<Account> primaryContactAccounts = [SELECT npe01__One2OneContact__c from Account where Id = :accountId ];
        List<Contact> accountContacts = [SELECT Id, Email from Contact where Email = :updatedMatchEmail ];
        Id contactId = null;
        String testEmail = null;
        for (Contact contactFound : accountContacts) {
            contactId = contactFound.Id;
            testEmail = contactFound.Email;
            break;
        }
        System.assertNotEquals(null, contactId);
        System.assertNotEquals(matchEmail, testEmail);
        List<npe5__Affiliation__c> affiliations = [SELECT npe5__Primary__c, npe5__Contact__c from npe5__Affiliation__c where npe5__Contact__c = :contactId and npe5__Organization__c = :accountId ];
        boolean foundAff = false;
        for (npe5__Affiliation__c affiliation : affiliations) {
            foundAff = true;
            break;
        }
        System.assertEquals(true, foundAff);

        boolean foundPrimary = false;
        boolean matchedPrimary = false;
        for (Account primaryContact : primaryContactAccounts) {
            foundPrimary = true;
            if ( primaryContact.npe01__One2OneContact__c == contactId ) {
                matchedPrimary = true;
                break;
            }
        }
        System.assertEquals(true, foundPrimary);
        System.assertEquals(true, matchedPrimary);
    }

}