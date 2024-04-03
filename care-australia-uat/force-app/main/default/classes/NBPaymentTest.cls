@isTest
public class NBPaymentTest {
    
    static npe01__OppPayment__c testPayment;
    static Campaign testCampaign;
    static Opportunity testOpportunity;
    static Opportunity testPPOpportunity;   
    static Decimal testAmount;
    
    static void init() {
        testCampaign = NBTestDataFactory.createCampaign();
        testPayment = NBTestDataFactory.createPayment(testCampaign);
        testOpportunity = NBTestDataFactory.createOpportunity(testCampaign);
        testPPOpportunity = NBTestDataFactory.createOpportunity(testCampaign);        
        testAmount = 5.00;   
    }
    
    //(String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode) {
	static testMethod void nbPayment() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBHttpPaymentMockTest()); 
        
        // Get the Opportunity Payment Number for return.
        String newPaymentName;
        Id testOpportunityId = testOpportunity.Id;
        List<npe01__OppPayment__c> pResult = [select Id, Name from npe01__OppPayment__c where npe01__Opportunity__c = :testOpportunityId];            
        if ( null != pResult ) {
            for (npe01__OppPayment__c pFound : pResult) {     
                System.debug('Payment Found ' + pFound.Name);
                newPaymentName = pFound.Name;
            }
        }
        else {
            System.debug('Payment NOT Found ' + testOpportunity.Id);
        }
        
        String newPayment = NBPayment.doPost(newPaymentName, testOpportunity.Name, testAmount, 'Credit Card', '123123123', '1234 **** **** 1234', 'Visa', 'test@test.com', 'onetime', '', '01', '2030'); 
        String newPPPaymentName;
        pResult = [select Id, Name from npe01__OppPayment__c where npe01__Opportunity__c = :testPPOpportunity.Id];            
        if ( null != pResult ) {
            for (npe01__OppPayment__c pFound : pResult) {     
                System.debug('Payment Found ' + pFound.Name);
                newPPPaymentName = pFound.Name;
            }
        }
        String newPPPayment = NBPayment.doPost(newPPPaymentName, testPPOpportunity.Name, testAmount, 'paypal', '123123123', '', '', 'testpp@test.com', 'onetime', '', '01', '2030');         
        String closedPayment = NBPayment.doPost(newPaymentName, testOpportunity.Name, testAmount, 'Credit Card', '123123123', '1234 **** **** 1234', 'Visa', 'test@test.com', 'onetime', '', '01', '2030');
        String noOpportunity = NBPayment.doPost('NOTANID', testOpportunity.Name, testAmount, 'Credit Card', '123123123', '1234 **** **** 1234', 'Visa', 'test@test.com', 'onetime', '', '01', '2030');
        String badOpportunity = NBPayment.doPost(newPayment, testOpportunity.Name, testAmount, 'Credit Card', '123123123', '1234 **** **** 1234', 'Visa', 'test@test.com', 'onetime', '', '01', '2030');
        
        Test.stopTest();
        
        System.assert( null != newPayment );
        System.assert( null != newPPPayment );
        System.assert(newPayment == 'SUCCESS');
		System.assert(closedPayment == 'ERROR');
        System.assert(noOpportunity == 'ERROR');
        System.assert(badOpportunity == 'ERROR');
    }
}