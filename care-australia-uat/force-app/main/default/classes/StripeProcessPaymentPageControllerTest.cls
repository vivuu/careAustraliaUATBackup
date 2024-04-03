@isTest
public class StripeProcessPaymentPageControllerTest {
    static PageReference pageRef = Page.stripeCreditCardPaymentPage;// Replace with final Visualforce page name
    
	@isTest
    static void StripeProcessPaymentPageController_whenWrongId() {
        pageRef.getParameters().put('id', 'wrongId');
        Test.setCurrentPageReference(pageRef);
        
        Test.startTest();
        StripeProcessPaymentPageController cntrl = new StripeProcessPaymentPageController();
        Test.stopTest();
        
        Assert.areEqual(false, cntrl.isVerifiedId, 'isVerifiedId should be false');
    }
    
    @isTest
    static void StripeProcessPaymentPageController_whenWrongContactId() {
        pageRef.getParameters().put('id', '003AD00000Bs9xdYAB');
        Test.setCurrentPageReference(pageRef);
        
        Test.startTest();
        StripeProcessPaymentPageController cntrl = new StripeProcessPaymentPageController();
        Test.stopTest();
        
        Assert.areEqual(false, cntrl.isVerifiedId, 'isVerifiedId should be false');
    }
    
    @isTest
    static void StripeProcessPaymentPageController_whenNoContactFound() {
        List<Contact> contacts = new List<Contact> {
          	new Contact(LastName='Test1', currencyIsoCode='AUD'),
            new Contact(LastName='Test2', currencyIsoCode='AUD')
        };
        insert contacts;
        
        pageRef.getParameters().put('id', contacts[0].Id);
        
        Test.setCurrentPageReference(pageRef);
        
        Test.startTest();
        StripeProcessPaymentPageController cntrl = new StripeProcessPaymentPageController();
        Test.stopTest();
        
        Assert.areEqual(false, cntrl.isVerifiedId, 'isVerifiedId should be false');
    }
    
    @isTest
    static void StripeProcessPaymentPageController_whenContactFound() {
        List<Contact> contacts = new List<Contact> {
          	new Contact(LastName='Test1', currencyIsoCode='AUD')
        };
        insert contacts;
        
        pageRef.getParameters().put('id', contacts[0].Id);
        pageRef.getParameters().put('amount', '100');
        pageRef.getParameters().put('createTokenForRd', 'true');
        
        Test.setCurrentPageReference(pageRef);
        
        Test.startTest();
        StripeProcessPaymentPageController cntrl = new StripeProcessPaymentPageController();
        Test.stopTest();
        
        Stripe_Payment_Configs__mdt metadataRecords = [SELECT Stripe_Publish_Key__c, LWC_domain__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
        
        Assert.areEqual(true, cntrl.isVerifiedId, 'isVerifiedId should be true');
        Assert.areEqual('AUD', cntrl.currencyIsoCode, 'isVerifiedId should be aud');
        Assert.areEqual('100', cntrl.amount, 'amount should be 100');
        Assert.areEqual(metadataRecords.Stripe_Publish_Key__c, cntrl.stripePublishKey, 'stripePublishKey should match the Checkout_config');
        Assert.areEqual(metadataRecords.LWC_domain__c, cntrl.lwcDomain, 'lwcDomain should match the Checkout_config');
    }
}