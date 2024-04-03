@IsTest
public class LinkContactCtrlTest {
	@testSetup
    public static void testData(){
        Account acc = new Account(Name='Test Account', Email__c='testaccount@test.com');
        insert acc;
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
    }
    
    public static testmethod void testFetContactsForCase(){
        Id donationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Case cs = new Case(Subject='Test Donation', Origin='Web', Priority='Medium', RecordTypeId=donationRTId, Status='New', SuppliedEmail='testaccount@test.com', SuppliedName='Test Account');
        insert cs;
        Test.startTest();
        	LinkContactCtrl.getContactsForCase(cs.Id);
        Test.stopTest();
    }
    
    public static testmethod void testGetContactsForTask(){
        List<Contact> conList = [Select Id, Name From Contact Where Name='Test Customer' limit 1];
        Task tsk = new Task(CallObject='6b6bda6f-911f-4ad0-8350-57e1c2e79982', Subject='6b6bda6f-911f-4ad0-8350-57e1c2e79982 Inbound CareTestChat', Type='Call', CallerPhone__c='+61466666666', WhoId=conList[0].Id, Status='Completed', Priority='Normal');
        insert tsk;
        Test.startTest();
        	LinkContactCtrl.getContactsForTask(tsk.Id);
        Test.stopTest();
    }
    
    public static testmethod void testUpdateTask(){
        List<Contact> conList = [Select Id, Name From Contact Where Name='Test Customer' limit 1];
        Task tsk = new Task(CallObject='6b6bda6f-911f-4ad0-8350-57e1c2e79982', Subject='6b6bda6f-911f-4ad0-8350-57e1c2e79982 Inbound CareTestChat', Type='Call', CallerPhone__c='+61466666666', WhoId=conList[0].Id, Status='Completed', Priority='Normal');
        insert tsk;
        Test.startTest();
        	LinkContactCtrl.updatetask(tsk.Id, conList[0].Id);
        Test.stopTest();
    }
}