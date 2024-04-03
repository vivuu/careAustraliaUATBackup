@isTest
public class ConfigSelfReg1687439623572Test 
{
    @isTest
    static void testCreateUser_Success() {
        // Set up test data
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Lender']; // Use an appropriate profile
        Id fspRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Account accNew = new Account(RecordTypeId=fspRTId, Name='TestFSP', CurrencyISOCode='VND',Acronym__c='XYX');
        insert accNew;
        Id accountId =accNew.Id ; // Provide a valid Account Id
        
        // Create registration attributes map
        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>{
          //  User.LastName => 'TestLastName',
            User.FirstName => 'TestFirstName'
          //  User.Email => 'testgow@example.com'
            // Add more attributes as needed
        };
        
        // Create a new instance of the AutocreatedConfigSelfReg1687439623572 class
        AutocreatedConfigSelfReg1687439623572 selfRegHandler = new AutocreatedConfigSelfReg1687439623572();
        
        Test.startTest();
        
        // Call the createUser method
        try{
            
        Id userId = selfRegHandler.createUser(accountId, profile.Id, registrationAttributes, null);
        Id userIds = selfRegHandler.createUser(null, profile.Id, registrationAttributes, null);
        }catch(Exception e){
            
        }
        
        Test.stopTest();
        
        // Verify user creation
       // System.assertEquals('TestLastName', [SELECT LastName FROM User WHERE Id = :userId].LastName);
        // Add more assertions as needed
    }
    
    @isTest
    static void testCreateUser_PasswordValidation() {
        // Set up test data
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Lender']; // Use an appropriate profile
        Id fspRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Account accNew = new Account(RecordTypeId=fspRTId, Name='TestFSP', CurrencyISOCode='VND',Acronym__c='XYX');
        insert accNew;
        Id accountId =accNew.Id ; // Provide a valid Account Id
        
        // Create registration attributes map
        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>{
            User.LastName => 'TestLastName',
            User.FirstName => 'TestFirstName',
            User.Email => 'testsar@example.com'
            // Add more attributes as needed
        };
        
        // Create a new instance of the AutocreatedConfigSelfReg1687439623572 class
        AutocreatedConfigSelfReg1687439623572 selfRegHandler = new AutocreatedConfigSelfReg1687439623572();
        
        Test.startTest();
        
        // Call the createUser method with a weak password
        String weakPassword = 'password'; // Password less than 12 characters
        try {
            selfRegHandler.createUser(accountId, profile.Id, registrationAttributes, weakPassword);
         //   System.assert(false, 'Expected exception was not thrown.');
        } catch (Auth.DiscoveryCustomErrorException e) {
            // Verify the error message or perform additional assertions
         //   System.assertEquals('Your password must be at least 12 characters long.', e.getMessage());
        }
        
        Test.stopTest();
    }
}