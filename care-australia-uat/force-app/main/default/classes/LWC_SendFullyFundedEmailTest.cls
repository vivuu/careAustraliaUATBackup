@isTest
public class LWC_SendFullyFundedEmailTest
{
    @testSetup private static void testData()
    {
		list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        Id customerRTId = LWCUtility.getCustomerRecordTypeId();
       		List<User> lenderUser=[SELECT Id, Name,ContactId FROM User WHERE isActive=true AND Profile.Name='Lender' AND ContactId!=null LIMIT 2];
       	System.debug('Lender test-->'+lenderUser);
        List<Contact> lenderContacts=new List<Contact>();
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        Account a=new Account(RecordTypeId=fspRTId, Name='TestFSP1', CurrencyISOCode='VND', Acronym__c='FI0');
        insert a;
        Account a1=new Account(RecordTypeId=fspRTId, Name='TestFSP2', CurrencyISOCode='VND', Acronym__c='FI2');
        insert a1;
        if(!lenderUser.isEmpty())
        {
            Integer i=0;
        	for(User u: lenderUser)
        	{
                if(i>0)
                {
                    lenderContacts.add(new Contact(AccountId=a1.Id,RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true,
                                         KYC_failed__c=false,KYC_completed__c=true,Email='testLender@example.com',Id=u.ContactId,MobilePhone='+61123456789'));

                } 
                else
            		lenderContacts.add(new Contact(AccountId=a.Id,RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true,
                                         KYC_failed__c=true,KYC_completed__c=false,Email='testLender@example.com',Id=u.ContactId,MobilePhone='+61123456789'));
                i++;
        	}
        }
		System.debug('Lender contacts-->'+lenderContacts);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult[] sr=Database.update(lenderContacts, dml);
        for(Database.SaveResult s: sr)
            System.debug('From saveresult test fully funded-->'+s);
        list<Loan__c> getloans= LWCTestUtility.getBorrowerLoans(LWCTestUtility.getBorrowerRecords(lenderUser));
        List<String> testLenderIds=new List<string>();
        for(Contact c: lenderContacts)
        	testLenderIds.add(c.Id);
        map<String, Lender_Balance__c> lenderBalanceMap = LWCTestUtility.getLenderBalances(lenderContacts);
        List<Transaction__c> transactions=LWCTestUtility.getLoanTransactionList(getloans,testLenderIds);
        
	}
    
   @isTest
        public static void positiveTest()
        {
        List<String> transIds=new List<String>();
		List<Transaction__c> trans=[SELECT Id FROM Transaction__c];
		for(Transaction__c t:trans)
            transIds.add(t.Id);
         System.debug('TransIds from test-->'+transIds);
        LWC_SendFullyFundedEmail ctrl = new LWC_SendFullyFundedEmail(transIds);
        Test.startTest();
            Database.executeBatch(ctrl,5);
        Test.stopTest();
        }
    
}