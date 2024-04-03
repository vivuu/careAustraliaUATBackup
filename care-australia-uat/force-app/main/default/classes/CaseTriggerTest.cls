@IsTest
public class CaseTriggerTest {
	@testSetup
    public static void testData(){
        Account acc = new Account(Name='Test Account', Email__c='testaccount@test.com');
        insert acc;
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
    }
    
    public static testmethod void testCase4WebForAccount(){
        Id donationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Case cs = new Case(Subject='Test Donation', Origin='Web', Priority='Medium', RecordTypeId=donationRTId, Status='New', SuppliedEmail='testaccount@test.com', SuppliedName='Test Account');
        Test.startTest();
        insert cs;
        Test.stopTest();
    }
    
    public static testmethod void testCase4WebInsert(){
        Id donationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Case cs = new Case(Subject='Test Donation', Origin='Web', Priority='Medium', RecordTypeId=donationRTId, Status='New', SuppliedEmail='test@test.com', SuppliedName='Test Customer');
        Test.startTest();
        insert cs;
        Test.stopTest();
    }
    
    public static testmethod void testCase4WebLeadInsert(){
        Id donationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Case cs = new Case(Subject='Test Donation', Origin='Web', Priority='Medium', RecordTypeId=donationRTId, Status='New', SuppliedEmail='testlead@test.com', SuppliedName='Test Customer');
        Test.startTest();
        insert cs;
        Test.stopTest();
    }
    
    public static testmethod void testCase4EmailWithRTInsert(){
        Id donationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Case cs = new Case(Subject='Test Donation', Origin='Email', Priority='Medium', RecordTypeId=donationRTId, Status='New', SuppliedEmail='test@test.com', SuppliedName='Test Customer');
        Test.startTest();
        insert cs;
        Test.stopTest();
    }
    
    public static testmethod void testCase4EmailWithTypeInsert(){
        Case cs = new Case(Subject='Test Donation', Origin='Email', Priority='Medium', Type='Complaints', Status='New', 
                           SuppliedEmail='testfortype@test.com', SuppliedName='Test Customer');
        Test.startTest();
        insert cs;
        Test.stopTest();
    }
}