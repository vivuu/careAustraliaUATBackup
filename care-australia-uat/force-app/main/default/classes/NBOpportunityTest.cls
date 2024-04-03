@isTest
public class NBOpportunityTest {
    static Account testAccount;
    static Account testOrgAccount;
    static Contact testContact;
    static Opportunity testOpportunity;
    static Opportunity testReccuringOpp;
    static Campaign testCampaign;
    static String testSessionId;
    static String testSessionId2;
    static String testSessionId3;
    static Decimal testAmount;
    
    static void init() {
        testAccount = NBTestDataFactory.createAccount('TestAccount');
        testOrgAccount = NBTestDataFactory.createOrgAccount('ACME');
        testContact = NBTestDataFactory.createContact(testAccount.Id, 'TestFirstName', 'TestLastName', 'test@test.com');
        testCampaign = NBTestDataFactory.createCampaign();
        testOpportunity = NBTestDataFactory.createOpportunity(testCampaign);
        testSessionId = 'SessionTest000';
        testSessionId2 = 'SessionTest001';
        testSessionId3 = 'SessionTest002';
        testAmount = 5.00;
    }
    
    //String contact, Decimal amount, String session, String campaign, String paymentMethod, String paymentMode, String formURL
    static testMethod void nbOpportunity() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBHttpOpportunityMockTest()); 
        // Golden path
        String newOpportunityN = NBOpportunity.doPut(testContact.Id, testAmount, testSessionId, testCampaign.Campaign_Code__c, 'Card', 'onetime', 'http://form.com', testContact.Email, testContact.FirstName, testContact.LastName, 'source', 'campaign', 'medium', '2023-06-01T00:00:00.000', '2.2'); 
        String newOpportunity = NBOpportunity.doPost(testContact.Id, testAmount, testSessionId, testCampaign.Campaign_Code__c, 'Card', 'onetime', 'http://form.com', testContact.Email, testContact.FirstName, testContact.LastName, 'source', 'campaign', 'medium'); 
        // Update Amount
        String newOpportunityUpdate = NBOpportunity.doPost(testContact.Id, 10.00, testSessionId, testCampaign.Campaign_Code__c, 'Card', 'onetime', 'http://form.com', testContact.Email, testContact.FirstName, testContact.LastName, '', '', ''); 
        // Duplicate via session Id - the user came back to the browser within the same session
        String duplicateOpportunity = NBOpportunity.doPost(testContact.Id, testAmount, testSessionId, testCampaign.Campaign_Code__c, 'Card', 'onetime', 'http://form.com', testContact.Email, testContact.FirstName, testContact.LastName, '', '', ''); 
        // A second golden path
        String newOpportunity2 = NBOpportunity.doPost(testOrgAccount.Id, testAmount, testSessionId2 + 'org', testCampaign.Campaign_Code__c, 'Card', 'onetime', 'http://form.com', 'testOrgContact@email.com', 'testContact.FirstName', 'testContact.LastName', '', '', '');
        // An org
        String newOpportunityOrg = NBOpportunity.doPost(testContact.Id, testAmount, testSessionId2, testCampaign.Campaign_Code__c, 'Card', 'onetime', 'http://form.com', testContact.Email, testContact.FirstName, testContact.LastName, '', '', '');
      
        // Golden path recurring
        String newRecurring = NBOpportunity.doPost(testContact.Id, testAmount, testSessionId3, testCampaign.Campaign_Code__c, 'Card', 'monthly', 'http://form.com', testContact.Email, testContact.FirstName, testContact.LastName, '', '', '');
        // Fould recurring
        String foundRecurring = NBOpportunity.doPost(testContact.Id, testAmount, testSessionId3, testCampaign.Campaign_Code__c, 'Card', 'monthly', 'http://form.com', testContact.Email, testContact.FirstName, testContact.LastName, '', '', '');
        
        String newRecurringOrg = NBOpportunity.doPost(testOrgAccount.Id, testAmount, testSessionId3 + 'org', testCampaign.Campaign_Code__c, 'Card', 'monthly', 'http://form.com', 'testOrgContact@email.com', 'testContact.FirstName', 'testContact.LastName', '', '', '');
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/NBOpportunity/' + testSessionId;
        req.httpMethod = 'GET';
    	RestContext.request = req;
        String foundOpportunityPaymentName = NBOpportunity.doGet();
        req.requestURI = '/services/NBOpportunity/' + 'NA';
        String notFoundOpportunityPaymentName = NBOpportunity.doGet();
        req.requestURI = '/services/NBOpportunity/' + testSessionId3;
        String foundRecurringGet = NBOpportunity.doGet();
        
        List<npe03__Recurring_Donation__c> oRGResult = [SELECT Id FROM npe03__Recurring_Donation__c WHERE RG_Id__c = :newRecurring];
        Id recurringId;
        if ( null != oRGResult ) {
            for (npe03__Recurring_Donation__c oRGFound : oRGResult) {
                // Get the Opportunity Payment Number for return.
                recurringId = oRGFound.Id;                                  
                break;
            }  
        }
        System.debug('Finding Opportunity From ' + recurringId);
        List<Opportunity> orResult = [SELECT Id, Name, StageName, npe03__Recurring_Donation__c FROM Opportunity WHERE npe03__Recurring_Donation__c = :recurringId];
        if ( null != orResult ) {
            for (Opportunity orFound : orResult) {     
                System.debug('Opportunity Found ' + orFound + ' ' + orFound.npe03__Recurring_Donation__c);
                testReccuringOpp = orFound;
            }
        }
        Test.stopTest();
        
        System.assert( null != newOpportunity );
        System.assert( null != newOpportunity2 );
        System.assert( null != testReccuringOpp );
        
        //Did we find the opportunity Id?
        System.assert( null != foundOpportunityPaymentName );        
        
        // The web service returns the payment name. Find the payment name of the testOpportunity to compare.
        // Golden path test              
        System.assertEquals(newOpportunity, foundOpportunityPaymentName);
        System.assertEquals(newOpportunity, newOpportunityUpdate);
        
        // The web service returns the payment name. Find the payment name of the testOpportunity to compare.
        // Duplicate test                
        System.assertEquals(newOpportunity, duplicateOpportunity);
        
        // 2 Golden paths are different and not creating duplicates.
        System.assertNotEquals(newOpportunity2, newOpportunity);
        
        // Did we find the recurring Id?
        System.assert( null != newRecurring );
        System.assert( null != newOpportunityOrg );
        System.assert( null != newRecurringOrg );
        System.assertEquals(foundRecurringGet, newRecurring);
        System.assertEquals(foundRecurringGet, foundRecurring);
        System.assert(null == notFoundOpportunityPaymentName);
        System.assert( 'Pledged' == testReccuringOpp.StageName );
    }

}