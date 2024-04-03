@isTest
public class UserTriggerTest 
{
    @isTest
        public static void positiveTest()
        {
        List<String> contactIds=new List<String>();
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        Id borrowerRTId = LWCUtility.getBorrowerRecordTypeId();
        Id fspBRTId=LWCUtility.getFSPBorrowerRecordTypeId();
        Id fspStaffRTId = LWCUtility.getFSPStaffRecordTypeId();
            List<Contact> borrowerContacts=new List<Contact>();
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
            
         for(User u: fspStaffUsers)
         {
             contactIds.add(u.ContactId);
         }
        list<Account> fspAccounts = new list<Account>();
        	for(Integer i=0; i<contactIds.size(); i++)
            {
            	if(i<=9){ fspAccounts.add(new Account(RecordTypeId=fspRTId, Name='TestFSP'+i, CurrencyISOCode='VND', Acronym__c='FO'+i)); }
        	}
        	insert fspAccounts;
        
        	list<Account> fspBorrowerAccounts = new list<Account>();
        	for(Account a: fspAccounts)
            {
            	fspBorrowerAccounts.add(new Account(RecordTypeId=fspBRTId, Name= a.Name, ParentId=a.Id));
        	}
        	insert fspBorrowerAccounts;
            list<Contact> fspContacts=new list<Contact>();
        	for(Integer i=0; i<fspAccounts.size(); i++)
            {
			        	fspContacts.add(new Contact(AccountId=fspAccounts[i].Id,RecordTypeId=fspStaffRTId, FirstName='Test1', LastName = 'Staff',Active__c=true,
                                         Email='testLender@example.com',Id=contactIds[i],MobilePhone='+61123456789'));
       		 }
            Database.DMLOptions dml = new Database.DMLOptions(); 
        	dml.DuplicateRuleHeader.AllowSave = true;
        	Database.SaveResult[] sr=Database.update(fspContacts, dml);
        	for(Database.SaveResult s: sr)
            	System.debug('From saveresult test UserTriggerTest-->'+s);
			for(Integer i=0; i<contactIds.size(); i++)
            {
                if(i<=9)
                {
                 borrowerContacts.add(new Contact(RecordTypeId=borrowerRTId, FSP_Name__c=contactIds[i], Published_Name__c='TB'+i, 
                                             FSP_Client_ID__c='FSP-0000'+i, FirstName='Borrower'+i, LastName='Borrower'+i, City__c='Test'+i, 
                                             Country__c='Vietnam', Gender__c='Female', Disability__c='No', Borrower_Type__c='Individual'));   
                }
            }
        		insert borrowerContacts;  
            
           List<Loan__c> getloans= LWCTestUtility.getBorrowerLoans(borrowerContacts);
            
        Test.startTest();
        UserTriggerHandler.handleBefore(fspStaffUsers);
        UserTriggerHandler.handleAfterInsert(fspStaffUsers);
        Test.stopTest();
        }
}