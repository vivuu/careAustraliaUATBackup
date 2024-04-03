@isTest
public class ContentDocumentLinkTriggerHelperTest {
    static testmethod void unitTest1(){
        //Create Document Parent Record
        Account acc = LWCTestUtility.getFSPAccountRecord();
        
        //Create Document
        ContentVersion cv = LWCTestUtility.getContentVersion();
        
        //Create ContentDocumentLink 
        Test.startTest();
        ContentDocumentLink cdl = LWCTestUtility.getContentDocumentLink(acc, cv.Id);
        Insert cdl;
        NotesAndAttachmentsController.getRelatedFilesByRecordId(acc.Id);
        Test.stopTest();
    }
}