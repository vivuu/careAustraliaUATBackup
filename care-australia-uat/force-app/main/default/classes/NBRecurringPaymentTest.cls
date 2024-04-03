@isTest
public class NBRecurringPaymentTest {
        
    static Campaign testCampaign;    
    static npe03__Recurring_Donation__c testMonthly;  
    static npe03__Recurring_Donation__c testActiveMonthly;
    static Decimal testAmount;
    
    static void init() {
        testCampaign = NBTestDataFactory.createCampaign();                       
        testMonthly = NBTestDataFactory.createRecurring(testCampaign);        
        testActiveMonthly = NBTestDataFactory.createActiveRecurring(testCampaign);
        testAmount = 5.00;   
    }
        
	static testMethod void nbPayment() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBHttpPaymentMockTest());  
        System.debug('Monthly payment RG Id ' + testMonthly.RG_Id__c);
        String monthlyPayment = NBPayment.doPost(testMonthly.RG_Id__c, 'Session1', testAmount, 'Credit Card', '123123123', '1234 **** **** 1234', 'Visa', 'test@test.com', 'monthly', '15', '01', '2024');        
        String invalidPayment = NBPayment.doPost('NOTANID', 'Session2', testAmount, 'Credit Card', '123123123', '1234 **** **** 1234', 'Visa', 'test@test.com', 'monthly', '15', '01', '2024');
        String closedPayment = NBPayment.doPost(testActiveMonthly.RG_Id__c, 'Session1', testAmount, 'Credit Card', '123123123', '1234 **** **** 1234', 'Visa', 'test@test.com', 'monthly', '15', '01', '2024');
        Test.stopTest();
        System.assert( null != monthlyPayment );        
        System.assert( null != closedPayment );
        System.assert(monthlyPayment == 'SUCCESS');        
		System.assert(closedPayment == 'ERROR');
        System.assert(invalidPayment == 'ERROR'); 
    }
}