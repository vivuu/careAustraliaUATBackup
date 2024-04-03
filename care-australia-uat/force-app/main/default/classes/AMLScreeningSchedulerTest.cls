@isTest
public class AMLScreeningSchedulerTest {
    @testSetup
	public static void testAMLScreeningScheduler(){
        list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        Id customerRTId = LWCUtility.getCustomerRecordTypeId();
       		List<User> lenderUser=[SELECT Id, Name,ContactId FROM User WHERE isActive=true AND Profile.Name='Lender' AND ContactId!=null LIMIT 2];
       	System.debug('Lender test-->'+lenderUser);
        List<Contact> lenderContacts=new List<Contact>();
        //for(User u: lenderUser)
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        Account a=new Account(RecordTypeId=fspRTId, Name='TestFSP1', CurrencyISOCode='VND', Acronym__c='FI0');
        insert a;
        Account a1=new Account(RecordTypeId=fspRTId, Name='TestFSP2', CurrencyISOCode='VND', Acronym__c='FI2');
        insert a1;
        //List<Account> accList=LWCTestUtility.getFSPAccounts();
        //System.debug('accList-->'+accList);
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
        	/*lenderContacts.add(new Contact(AccountId=a.Id,RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true,
                                         KYC_failed__c=false,KYC_completed__c=true,Email='testLender@example.com',Id=lenderUser[0].ContactId,MobilePhone='+61123456789'));
       lenderContacts.add(new Contact(AccountId=a1.Id,RecordTypeId=customerRTId, FirstName='Test1', LastName = 'Staff',IsLender__c=true,Active__c=true,
                                         KYC_failed__c=true,KYC_completed__c=false,Email='testLender@example.com',Id=lenderUser[1].ContactId,MobilePhone='+61123456789'));*/
        System.debug('Lender contacts-->'+lenderContacts);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult[] sr=Database.update(lenderContacts, dml);
        for(Database.SaveResult s: sr)
            System.debug('From saveresult test KYC-->'+s);
        list<Loan__c> getloans= LWCTestUtility.getBorrowerLoans(LWCTestUtility.getBorrowerRecords(lenderUser));
        List<String> testLenderIds=new List<string>();
        for(Contact c: lenderContacts)
        	testLenderIds.add(c.Id);
        map<String, Lender_Balance__c> lenderBalanceMap = LWCTestUtility.getLenderBalances(lenderContacts);
        List<Transaction__c> transactions=LWCTestUtility.getLoanTransactionList(getloans,testLenderIds);
        List<Transaction__c> transactionsR=LWCTestUtility.getRepaymentTransactionList(getloans,testLenderIds);
        List<Transaction__c> updatetrans=new List<Transaction__c>();
        for(Transaction__c t: transactions)
            updatetrans.add(t);
        
        for(Transaction__c t: transactionsR)
            updatetrans.add(t);
        
        //System.debug('Transactions list-->'+updatetrans);
        List<Repayment_Schedule__c> rslist=new List<Repayment_Schedule__c>();
        for(Loan__c l:getloans)
			rslist.add(new Repayment_Schedule__c(Loan__c=l.Id,Status__c=null,Repayment_Date__c=null,Amount_Due__c=1000000, Due_Date__c=Date.today()));
        insert rslist;
        
        //System.debug('Repayments from AML Test-->'+rslist);
        
    }
        
        @isTest
        public static void positiveTest()
        {
        LWC_AMLScreeningScheduler ctrl = new LWC_AMLScreeningScheduler();
        Test.startTest();
            Loan__c loan=[SELECT Id FROM Loan__c Limit 1];

        String sch = '0 0 14 * * ?'; 
        system.schedule('LWC_AMLScreeningScheduler', sch, ctrl);
            LWC_AMLScreeningScheduler.increasePerformance();
        Test.stopTest();
        }
        
}