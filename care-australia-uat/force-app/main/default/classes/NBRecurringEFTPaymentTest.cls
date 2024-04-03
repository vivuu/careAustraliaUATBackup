@isTest
public class NBRecurringEFTPaymentTest {
        
    static Campaign testCampaign;       
    static npe03__Recurring_Donation__c testMonthlyEFT;   
    static Decimal testAmount;
    
    static void init() {
        testCampaign = NBTestDataFactory.createCampaign();                       
        testMonthlyEFT = NBTestDataFactory.createRecurring(testCampaign);       
        testAmount = 5.00;   
    }
        
	static testMethod void nbPayment() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBHttpPaymentMockTest());  
        System.debug('Monthly payment RG Id ' + testMonthlyEFT.RG_Id__c);        
        String monthlyEFTPayment = NBPayment.doPost(testMonthlyEFT.RG_Id__c, 'Session3', testAmount, 'EFT', '123123123', '12341234', 'Bank of AUS', 'test@test.com', 'monthly', '15', '123-123', 'Test User');        
        Test.stopTest();        
        System.assert( null != monthlyEFTPayment );        
        System.assert(monthlyEFTPayment == 'SUCCESS');		
    }
}