@isTest
public class LWC_UpdateConversionRateSchedulerTest {
    private static List<Id> createTransaction(Contact con) {
        List<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        List<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
       	List<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);
        
        Transaction__c trans = new Transaction__c(Loan__c=loanList[0].Id, Lender__c=con.Id, Type__c='Topup', Amount__c=45, Status__c='Completed',Transaction_Date__c=Date.today());
        
        insert trans;
        return new List<Id>{trans.Id};
    }
    
    @TestSetup
    private static void testData(){
        Id profileId = [select id from profile where name='Lender'].Id;
        
        String customerRTId=LWCUtility.getCustomerRecordTypeId();
        Contact fxGain = new Contact(RecordTypeId=customerRTId, FirstName='LWC FX', LastName = 'Lender', IsLender__c=true, Lending_Enabled_Date__c = System.today(), Is_LastLogin_6_Months__c=false);
        insert fxGain;
        
        Contact fxGain1 = new Contact(RecordTypeId=customerRTId, FirstName='LWC FX 1', LastName = 'Lender 1', IsLender__c=true, Is_LastLogin_6_Months__c=true);
        insert fxGain1;
        
        createTransaction(fxGain1);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = fxGain.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        User user1 = new User(alias = 'test1231', email='test1231@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = fxGain1.Id,
                             timezonesidkey='America/Los_Angeles', username='tester1@noemail.com');
        insert user1;
    }
    
    public testmethod static void testFXConversion(){
        LWC_UpdateConversionRateScheduler ctrl = new LWC_UpdateConversionRateScheduler('Php');
        Test.startTest();
        //ctrl.execute(null);
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Currency Check', sch, ctrl);
        LWCUtilityFX.validateStatusCode(404);
        Test.stopTest();
    }
    public testmethod static void testLastLogin(){
        String customerRTId=LWCUtility.getCustomerRecordTypeId();
        LWC_LastLoginScheduler ctrl = new LWC_LastLoginScheduler();
        List<user> users = [SELECT Id, Name, ContactId, LastLoginDate FROM User WHERE Profile.Name = 'Lender' AND IsActive=true AND MobilePhone !=null];
        Contact cont = new Contact();
        for( User u : users ){
            cont.Id = u.ContactId;
        }
        Account acc = new Account(Name='Test');
        INSERT acc;
        cont.AccountId = acc.Id;
        cont.Is_LastLogin_6_Months__c = true;
        Update cont;
        Test.startTest();
        //ctrl.execute(null);
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test LastLogin', sch, ctrl);
        LWCUtilityFX.validateStatusCode(404);
        Test.stopTest();
    }
    public testmethod static void testGetConversionRate(){
        Test.startTest();
        LWCUtilityFX.getConversionRate('USD');
        Test.stopTest();
    }
    
    public testmethod static void testGetConversionRateLCToUSD(){
        Test.startTest();
        map<String, Decimal> result = LWCUtilityFX.getCurrencyConversionMap();
        LWCUtilityFX.getConversionRateLCToUSD('VND', result);
        LWCUtilityFX.getConversionRateLCToUSD('VND', null);
        Test.stopTest();
    }
    
    public testmethod static void testconversionfromLCtoUSD(){
        Test.startTest();
        map<String, Decimal> result = LWCUtilityFX.getCurrencyConversionMap();
        LWCUtilityFX.conversionfromLCtoUSD(11111111, 'VND', result);
        LWCUtilityFX.conversionfromLCtoUSD(11111111, 'VND', null);
        Test.stopTest();
    }
    public testmethod static void testconversionfromLCtoAUD(){
        Test.startTest();
        map<String, Decimal> result = LWCUtilityFX.getCurrencyConversionMap();
        LWCUtilityFX.conversionfromLCtoAUD(11111111, 'VND', result);
        LWCUtilityFX.conversionfromLCtoAUD(11111111, 'VND', null);
        Test.stopTest();
    }
    
    public testmethod static void testconversionfromUSDtoAUD(){
        Test.startTest();
        map<String, Decimal> result = LWCUtilityFX.getCurrencyConversionMap();
        LWCUtilityFX.conversionfromUSDtoAUD(1000, result);
        LWCUtilityFX.conversionfromUSDtoAUD(1000, null);
        Test.stopTest();
    }
}