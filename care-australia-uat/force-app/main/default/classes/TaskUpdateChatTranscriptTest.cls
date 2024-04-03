@IsTest
public class TaskUpdateChatTranscriptTest {
	@testSetup
    public static void testData(){
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
        Task tsk = new Task(CallObject='6b6bda6f-911f-4ad0-8350-57e1c2e79982', Subject='6b6bda6f-911f-4ad0-8350-57e1c2e79982 Inbound CareTestChat', Type='Chat', WhoId=conList[0].Id, Status='Completed', Priority='Normal', Description='test description');
        insert tsk;
    }
    
    public static testmethod void testupdateChatTranscript(){
        list<Task> tskList = [Select Id, Subject, Type, CallObject From Task];
        Test.startTest();
        TaskUpdateChatTranscript.updateChatTranscript(tskList[0].Id);
        Test.stopTest();
        tskList = [Select Id, Subject, Type, CallObject, Chat_Transcript_URL__c, Description From Task Where Id=:tskList[0].Id];
        system.assert(tskList[0].Chat_Transcript_URL__c != null);
        system.assert(tskList[0].Description != null);
    }
    
    public static testmethod void testHandledException(){
        list<Task> tskList = [Select Id, Subject, Type, CallObject, Description From Task];
        Test.startTest();
        TaskUpdateChatTranscript.updateChatTranscript('');
        Test.stopTest();
    }
    
    public static testmethod void testGetTask(){
        list<Task> tskList = [Select Id, Subject, Type, CallObject, Description From Task];
        Test.startTest();
        TaskUpdateChatTranscript.getTask(tskList[0].Id);
        Test.stopTest();
    }
    
    public static testmethod void testupdateCallType(){
        list<Task> tskList = [Select Id, Subject, Type, CallObject From Task];
        Test.startTest();
        TaskUpdateChatTranscript.updateCall(tskList[0].Id, 'Donation');
        Test.stopTest();
        tskList = [Select Id, CallType__c From Task Where Id=:tskList[0].Id];
        system.assertEquals(tskList[0].CallType__c, 'Donation');
    }
    
    public static testmethod void testSendEmail(){
        list<Task> tskList = [Select Id, Subject, Type, CallObject From Task];
        Test.startTest();
        TaskUpdateChatTranscript.sendEmail('test subject', 'test body', 'test@test.com', tskList[0].Id);
        Test.stopTest();
    }
}