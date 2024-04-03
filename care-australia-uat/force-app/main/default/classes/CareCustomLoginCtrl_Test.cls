@isTest 
public  class CareCustomLoginCtrl_Test {
    @TestSetup
    private static void testData(){
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
    }
    Public testmethod static void testPositive(){
        Id fspStaffRTId = LWCUtility.getFSPStaffRecordTypeId();
        Id borrowerRTId = LWCUtility.getBorrowerRecordTypeId();
        List <Account> accNew = [select id from account];
        list<Contact> conList = [Select Id, Name,FirstName, Care_Borrower_Id__c, FSP_Name__c, FSP_Client_ID__c 
                                 From Contact Where RecordTypeId=:fspStaffRTId];
        system.debug('conList-> '+conList);
        Contact cnList=new Contact();
        if(!conList.isEmpty())
        {
            cnList = new Contact(
            RecordTypeId = borrowerRTId,
            FSP_Name__c = conList[0].Id,
            Published_Name__c = 'TB' + '123',
            FSP_Client_ID__c = 'Leave-0000' + '124',
            FirstName = conList[0].FirstName,
            LastName = 'Borrower' + '124',
            City__c = 'Test' + '124',
            Country__c = 'Vietnam',
            Gender__c = 'Female',
            Disability__c = 'No',
            Borrower_Type__c = 'Individual'
        	);
        }
        
        list<User> fspStaffUsers = [SELECT Id, Name, ContactId FROM User 
                                    WHERE IsActive=TRUE AND Profile.Name = 'FSP Staff' AND ContactId != null];
        Test.startTest();
        CareCustomLoginCtrl.updateContact(cnList) ; 
        CareCustomLoginCtrl.getContactbyUserID(null) ; 
        CareCustomLoginCtrl.getContactbyUserID('xyz') ; 
          CareCustomLoginCtrl.getContactbyUserID(fspStaffUsers[0].id) ; 
        Test.stopTest();
    }
}