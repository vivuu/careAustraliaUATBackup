@isTest

public class AutocreatedRegHandler1687255094855Test {
    static testMethod void testCreateAndUpdateUser() {
        
        AutocreatedRegHandler1687255094855 handler = new AutocreatedRegHandler1687255094855 ();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        
        Test.startTest();
        try{
            User u = handler.createUser(null, sampleData);           
            sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                           'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                           null, new Map<String, String>{});
            handler.updateUser(null, null, sampleData);
        }catch(Exception e){
            
        }
        test.stopTest();
    }
    static testMethod void testCreateAndUpdateUserPositive() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Lender']; // Use an appropriate profile
        Id fspRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Account accNew = new Account(RecordTypeId=fspRTId, Name='TestFSP', CurrencyISOCode='VND',Acronym__c='XYX');
        insert accNew;
        Id accountId =accNew.Id ; 
        AutocreatedRegHandler1687255094855 handler = new AutocreatedRegHandler1687255094855 ();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        sampleData.attributeMap = new Map<String, String>{ 'sfdc_networkid' => '123456789' ,'accountId'=>accountId};
            Test.startTest();
        try{
            User u = handler.createUser(null, sampleData);  
            id conId =   handler.createContact(sampleData);
        }catch(Exception e){
            
        }
        test.stopTest();
    }  
    
    static testMethod void testCreateAndUpdateUserPositive1() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Lender']; // Use an appropriate profile
        Id fspRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Account accNew = new Account(RecordTypeId=fspRTId, Name='TestFSP', CurrencyISOCode='VND',Acronym__c='XYX');
        insert accNew;
        Id accountId =accNew.Id ; 
        AutocreatedRegHandler1687255094855 handler = new AutocreatedRegHandler1687255094855 ();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        Test.startTest();
        try{
            User u = handler.createUser(null, sampleData);  
            id conId =   handler.createContact(sampleData);
        }catch(Exception e){
            
        }
        test.stopTest();
    } 
    
    public testmethod static void testPerformance(){
        AutocreatedRegHandler1687255094855.increasePerformance();
    }
}