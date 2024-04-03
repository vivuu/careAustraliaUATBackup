@isTest
public class NBTestDataFactory {
    
    public static Account createAccount(String accountName) {
        Account a = new Account();
        a.Name    = accountName;
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        a.RecordTypeId = accountRecordTypeId;
        insert a;
        System.debug('Account Id:' + a.Id);
        return a;
    }
    
    public static Account createOrgAccount(String accountName) {
        Account a = new Account();
        a.Name    = accountName;
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        a.RecordTypeId = accountRecordTypeId;
        insert a;
        System.debug('Account Id:' + a.Id);
        return a;
    }
    
    public static Contact createContact(Id testAccountId, String testFirstName, String testLastName, String testEmail ) {
     	return NBTestDataFactory.createContact(testAccountId, testFirstName, testLastName, testEmail, generateRandomString(10));   
    }
    
    public static Contact createContact(Id testAccountId, String testFirstName, String testLastName, String testEmail, String street ) {
        Contact c   = new Contact();
		c.FirstName = testFirstName;
		c.LastName  = testLastName;
        c.Email     = testEmail;
		c.AccountId = testAccountId;
        c.MailingStreet = street;
		insert c;
        System.debug('Contact Id:' + c.Id);
        return c;
    }
    
    public static Campaign createCampaign() {
        
        Campaign pc = new Campaign();
        pc.Name = 'Parent Campaign ' + generateRandomString(10);
        pc.Campaign_Code__c = '123' + generateRandomString(10);
        pc.Status = 'Active';
        pc.IsActive = true;
        try {
           insert pc;
        }
        catch(Exception e) {
            // Specifically to prevent record lock if running unit tests in parrellel.
            Long startTime = DateTime.now().getTime();
            Long finalTime = DateTime.now().getTime();
            Long millisecondsToWait = 1000;
            while (finalTime - startTime < millisecondsToWait) {
                insert pc;
            }
        }
        
        System.debug('Parent Campaign Id:' + pc.Id);
        
        Campaign cc = new Campaign();
        cc.Name = 'Child Campaign';
        cc.ParentId = pc.Id;
        cc.Campaign_Code__c = '456';
        cc.Status = 'Active';
        cc.IsActive = true;
        insert cc;
        System.debug('Child Campaign Id:' + cc.Id);
       
        return cc;
    }
    
    public static Opportunity createOpportunity(Campaign c) {
        String session = NBTestDataFactory.generateRandomString(10);
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    	Account a = new Account();
        a.Name = 'Test Opportunity Account ' + session;
        a.Alternate_Email__c = 'test' + session + '@test.com';
        a.RecordTypeId = accountRecordTypeId;
        insert a;
        System.debug('Account Id:' + a.Id);
        System.debug('Campaign Id:' + c.Id);
        
        Opportunity o = new Opportunity();
        o.CampaignId = c.Id;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        o.Name = 'Test Opp';
        o.Accountid = a.id;
        o.StageName = 'Pledged';
        o.CloseDate = system.Today()+1;
        insert o;
        System.debug('Opportunity Id:' + o.Id);
        npe01__OppPayment__c payment = new npe01__OppPayment__c();
        payment.npe01__Opportunity__c = o.Id;
        insert payment;
        return o;
    }
    
    public static Opportunity createClosedOpportunity(Campaign c) {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    	Account a = new Account();
        a.Name = 'Test Closed Opportunity Account';
        a.Alternate_Email__c = 'testclosed@test.com';
        a.RecordTypeId = accountRecordTypeId;
        insert a;              
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Closed Opp';
        o.CampaignId = c.Id;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        o.CampaignId = c.Id;
        o.Accountid = a.id;
        o.StageName = 'Closed Won';
        o.CloseDate = system.Today();
        insert o;
        System.debug('Opportunity Closed Id:' + o.Id);
        return o;
    }
    
    public static npe01__OppPayment__c createPayment(Campaign c) {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    	Account a = new Account();
        a.Name = 'Test Opportunity Payment Account';
        a.Alternate_Email__c = 'testpayment@test.com';
        a.RecordTypeId = accountRecordTypeId;
        insert a;
              
        Opportunity o = new Opportunity();
        o.Name = 'Test Payment Opp';
        o.CampaignId = c.Id;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        o.CampaignId = c.Id;
        o.Accountid = a.id;
        o.StageName = 'Pledged';
        o.CloseDate = system.Today()+1;
        o.Amount = 6.54;
        insert o;
        
        //Now find the payment        
        npe01__OppPayment__c p;
        Id opportunityId = o.Id;
        p = [SELECT Id, Name FROM npe01__OppPayment__c where npe01__Opportunity__c = :opportunityId];
        
        System.debug('Payment Inserted ' + p.Id + ' ' + p.Name);
        return p;
    }
    
    public static npe03__Recurring_Donation__c createRecurring(Campaign c) {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    	Account a = new Account();
        a.Name = 'Test Recurring Account ' + generateRandomString(10);
        a.Alternate_Email__c = generateRandomString(10) + '@rectest.com';
        a.RecordTypeId = accountRecordTypeId;
        insert a;
        System.debug('Account Id:' + a.Id + ' ' + a.Name + ' ' + a.Alternate_Email__c);
        System.debug('Campaign Id:' + c.Id);
        
        Contact contact = NBTestDataFactory.createContact(a.Id, generateRandomString(10), generateRandomString(10), a.Alternate_Email__c, generateRandomString(10) );
        
        npe03__Recurring_Donation__c rg = new npe03__Recurring_Donation__c();
        rg.Name = 'session test';
        rg.npe03__Amount__c = 8.22;
        rg.npsp__PaymentMethod__c = 'Credit Card';
        rg.npsp__Status__c = 'Cancelled';
        rg.npe03__Recurring_Donation_Campaign__c = c.Id;
        //o.npe03__Organization__c = accountId;
        rg.npe03__Contact__c = contact.Id;
        rg.npsp__InstallmentFrequency__c = 1;
        rg.npe03__Installment_Period__c = 'Months';
        rg.npsp__Day_of_Month__c = '15';
        
        insert rg;
        Id oid = rg.Id;
        npe03__Recurring_Donation__c rgf = [ SELECT RG_Id__c, Name, Id from npe03__Recurring_Donation__c where Id = :oid ];
        System.debug('Recurring RG Id:' + rgf.RG_Id__c);
        return rgf;
    }
    
    public static npe03__Recurring_Donation__c createActiveRecurring(Campaign c) {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    	Account a = new Account();
        a.Name = 'Test Recurring Account Rec';
        a.Alternate_Email__c = 'testEmailRec2@rectest.com';
        a.RecordTypeId = accountRecordTypeId;
        insert a;
        System.debug('Account Id:' + a.Id);
        System.debug('Campaign Id:' + c.Id);
        
        Contact contact = NBTestDataFactory.createContact(a.Id, 'testFirstNameRec2', 'testLastNameRec2', 'testEmailrec2@rectest.com', generateRandomString(10));
        
        npe03__Recurring_Donation__c o = new npe03__Recurring_Donation__c();
        o.Name = 'Test Recurring Closed';
        o.npe03__Amount__c = 8.22;
        o.npsp__PaymentMethod__c = 'Credit Card';
        o.npsp__Status__c = 'Active';
        o.npe03__Recurring_Donation_Campaign__c = c.Id;
        //o.npe03__Organization__c = accountId;
        o.npe03__Contact__c = contact.Id;

        insert o;
        Id oid = o.Id;
        npe03__Recurring_Donation__c rg = [ SELECT RG_Id__c, Name, Id from npe03__Recurring_Donation__c where Id = :oid ];
        System.debug('Recurring RG Id:' + o.RG_Id__c);
        return rg;
    }
    
    public static List<Account> createAccountsWithOpps(Integer numAccts, Integer numOppsPerAcct) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            // For each account just inserted, add opportunities
            for (Integer k=0;k<numOppsPerAcct;k++) {
                opps.add(new Opportunity(Name=acct.Name + ' Opportunity ' + k,
                                       StageName='Prospecting',
                                       CloseDate=System.today().addMonths(1),
                                       AccountId=acct.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;
        
        return accts;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}