@isTest
public class ContactTriggerTest {
    @TestSetup
    private static void testData(){
       // list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
    }
    
    public testmethod static void testInsertPositive(){  
        
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        Id fspStaffRTId = LWCUtility.getFSPStaffRecordTypeId();
        Id borrowerRTId = LWCUtility.getBorrowerRecordTypeId();
        Account newacc =  LWCTestUtility.getFSPAccountRecord();
        List<Account> accNew = [select id from account];
        //list<Contact> conList = [Select Id, Name,FirstName, Care_Borrower_Id__c, FSP_Name__c, FSP_Client_ID__c ,accountid
          //                       From Contact Where RecordTypeId=:fspStaffRTId];
        list<Contact> borrowerContacts = new list<Contact>();
        
      User fspUsr=[SELECT Id, Name, ContactId FROM User WHERE IsActive=TRUE AND Profile.Name = 'FSP Staff' AND ContactId != null LIMIT 1]; 
      Account insAcc = new Account(RecordTypeId=fspRTId, Name='TestFSP123', CurrencyISOCode='VND', Acronym__c='FIF');
        Insert insAcc;
        Account insAcc2 = new Account(RecordTypeId=fspRTId, Name='TestFSP123', CurrencyISOCode='VND', Acronym__c='FIV');
        insert insAcc2;
        Contact newCon=new Contact();
        Test.startTest();
        if(fspUsr!=null)
        {
            newCon =  new Contact(RecordTypeId=fspStaffRTId, FirstName=insAcc.Name, LastName = 'Staffs1', Street__c='Test', Ward__c='Test',Id=fspUsr.ContactId,
                                       District__c='Test', City__c='Test', Country__c='Vietnam', Email=insAcc.Name+'@example.com', AccountId = insAcc.Id);
        	Update newCon;
        }
      	
        Contact fspCon =  new Contact(RecordTypeId=fspStaffRTId, FirstName=insAcc.Name, LastName = 'Staffs2', Street__c='Test', Ward__c='Test',
                                       District__c='Test', City__c='Test', Country__c='Vietnam', Email=insAcc.Name+'@example.com', AccountId = insAcc.Id);
        
        insert fspCon;
        
        System.debug('new con new con-->'+newCon);
        for (Integer i = 1; i <= 5; i++) {
            borrowerContacts.add(new Contact(
                RecordTypeId = borrowerRTId,
                FSP_Name__c = newCon.Id,
                //Published_Name__c = 'TB' + i,
                FSP_Client_ID__c = '0000' + i+30,
                FirstName = newCon.FirstName,
                LastName = 'Borrower' + i,
                City__c = 'Test' + i,
                Country__c = 'Vietnam',
                Gender__c = 'Female',
                Disability__c = 'No',
                Borrower_Type__c = 'Individual'
            ));
        }
         Contact newCon1 =  new Contact(RecordTypeId=borrowerRTId,Care_Borrower_ID__c='tes-0000001', FirstName=insAcc.Name, LastName = 'Staff', Street__c='Test', FSP_Name__c =newCon.Id,
                                        District__c='Test', City__c='Test', Country__c='Vietnam', Email=insAcc.Name+'@example.com');
        Insert newCon1;
         Contact newCon2 =  new Contact(RecordTypeId=borrowerRTId, FirstName='Duplicate', LastName = 'Staffsss', Street__c='Test', FSP_Name__c =newCon.Id,
                                        District__c='Test', City__c='Test', Country__c='Vietnam', Email=insAcc.Name+'@example.com');

         Insert newCon2;
        insert borrowerContacts;
        Contact updateContact=[SELECT Id,Name FROM Contact WHERE RecordTypeId=:fspStaffRTId LIMIT 1];
        //User usr=[SELECT Id,Name,isActive,ContactId FROM User WHERE ContactId=:updateContact.Id AND Name='' LIMIT 1];
        //usr.isActive=false;
        //update usr;
        //Account acc=[SELECT Id FROM Account WHERE Acronym__c='FIV' AND RecordTypeId=:fspRTId LIMIT 1];
       //newCon.AccountId=acc.Id;
        System.debug('FROM TEST CONTACT-->'+updateContact);
        update newCon;
        ContactTriggerHandler.increasePerformance();
        Test.stopTest();
    }
}