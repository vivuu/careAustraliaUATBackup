@isTest
public class StripeConnectionTest {
    static String body = 'body';
    static String stripeId = 'id';
    
	@isTest
    static void postCharge_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postCharge(body);
        Test.stopTest();
    }
    
    @isTest
    static void getCustomer_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.getCustomer(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void postCustomer_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postCustomer(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void postCustomerFuture_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postCustomerFuture(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void postCustomerSource_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postCustomerSource(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void deleteCustomer_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.deleteCustomer(stripeId);
        Test.stopTest();
    }
    
    @isTest
    static void postSubscription_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postSubscription(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void postPaymentMethod_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postPaymentMethod(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void getPaymentMethod_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.getPaymentMethod(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void postProduct_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postProduct(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void postPaymentIntent_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postPaymentIntent(stripeId, body);
        Test.stopTest();
    }
    
    @isTest
    static void postSetupIntent_test() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        Test.startTest();
        StripeConnection.postSetupIntent(stripeId, body);
        Test.stopTest();
    }
}