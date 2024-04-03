@isTest
public class StripeHttpCalloutHelperTest {
	@isTest
    static void doCallout_WhenStripeIdAndBody() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        
        Test.startTest();
        StripeHttpCalloutHelper helper = new StripeHttpCalloutHelper('Stripe_Post_Charges_API');
        helper.doCallout('customer', 'body');
        Test.stopTest();
    }
    
    @isTest
    static void doCallout_WhenStripeId() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        
        Test.startTest();
        StripeHttpCalloutHelper helper = new StripeHttpCalloutHelper('Stripe_Post_Charges_API');
        helper.doCallout('customer', '');
        Test.stopTest();
    }
    
    @isTest
    static void doCalloutForInvoiceSearch_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        
        Test.startTest();
        StripeHttpCalloutHelper helper = new StripeHttpCalloutHelper('Stripe_Post_Charges_API');
        helper.doCalloutForInvoiceSearch('customer: cus_123pksd0932');
        Test.stopTest();
    }
    
    @isTest
    static void doCalloutForCustomerSource_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        
        Test.startTest();
        StripeHttpCalloutHelper helper = new StripeHttpCalloutHelper('Stripe_Post_Charges_API');
        helper.doCalloutForCustomerSource('customer', 'body');
        Test.stopTest();
    }
}