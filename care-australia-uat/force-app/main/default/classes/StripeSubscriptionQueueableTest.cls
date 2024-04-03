@isTest
public class StripeSubscriptionQueueableTest {
    static Charge__c card_ch;
    static list<npe03__Recurring_Donation__c> rdList;
    
    static void createTest() {
        Account acc = new Account(Name='Test acc');
        insert acc;
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(AccountId=acc.Id, FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666', Stripe_Customer_Id__c='cus_OezvOgmGSxROgw', Stripe_Customer_Ids__c='cus_OezvOgmGSxROgw'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        List<Charge__c> charges = new List<Charge__c>();
        
       	card_ch = new Charge__c();
        card_ch.Stripe_Charge_Id__c = 'ch_3NrfvyGGWgtqSxG40U8tXiA7';
        card_ch.Stripe_Charge_Status__c = 'succeeded';
        card_ch.Stripe_Customer_Id__c = 'cus_OezvOgmGSxROgw';
        card_ch.Stripe_Charge_Amount__c = 100;
        card_ch.Method_Type__c = 'card';
        card_ch.Payment_Created_Date__c = System.today();
        card_ch.Card_Last_Digits__c = '4242';
        card_ch.Card_Type__c = 'visa';
        card_ch.Card_Token__c = 'token';
        card_ch.Card_Expiration_Month__c = '01';
        card_ch.Card_Expiration_Year__c = '2024';
        card_ch.Stripe_Payment_Method_Id__c = 'paymentmethod';
        card_ch.Campaign_Id__c = String.valueOf(camp.Id);
        card_ch.Is_Recurring__c = true;
        card_ch.Is_Processed__c = false;
        
        charges.add(card_ch);
        insert charges;
        
        rdList = new list<npe03__Recurring_Donation__c>();
        for(Integer i=0; i<conList.size(); i++){
            rdList.add(new npe03__Recurring_Donation__c(
                npe03__Contact__c=conList[i].Id, 
                npe03__Amount__c=500, 
                npe03__Recurring_Donation_Campaign__c=camp.Id, 
                npsp__CardExpirationMonth__c='09',
                npsp__CardExpirationYear__c='2024', 
                npsp__CardLast4__c='2424', 
                Card_Number_Masked__c='',
                Card_Token__c='', 
                Card_Type__c='Visa', 
                npsp__StartDate__c=System.Today(), 
                npe03__Installment_Period__c='Monthly', 
                Payment_Gateway__c='Stripe', 
                npsp__PaymentMethod__c='Credit Card', 
                npsp__Status__c='Active',
                npsp__InstallmentFrequency__c=2,
                npsp__RecurringType__c='Fixed',
                npe03__Installments__c=2,
                npsp__Day_of_Month__c='1',
                Stripe_payment_method_id__c='paymentmethod'
            ));
            
            rdList.add(new npe03__Recurring_Donation__c(
                npe03__Contact__c=conList[i].Id, 
                npe03__Amount__c=500, 
                npe03__Recurring_Donation_Campaign__c=camp.Id, 
                npsp__CardExpirationMonth__c='09',
                npsp__CardExpirationYear__c='2024', 
                npsp__CardLast4__c='2424', 
                Card_Number_Masked__c='',
                Card_Token__c='', 
                Card_Type__c='Visa', 
                npsp__StartDate__c=System.Today(), 
                npe03__Installment_Period__c='Monthly', 
                Payment_Gateway__c='Stripe', 
                npsp__PaymentMethod__c='Credit Card', 
                npsp__Status__c='Active',
                npsp__RecurringType__c='Open',
                npsp__Day_of_Month__c='1',
                Stripe_payment_method_id__c='paymentmethod'
            ));
        }
        insert rdList;
    }
    
	@isTest
    static void test_execute() {
        createTest();
        Test.setMock(HttpCalloutMock.class, new StripePaymentController_Mocks.PostStripeChargeSuccess());
        
        Test.startTest();
        StripeSubscriptionQueueable que = new StripeSubscriptionQueueable(card_ch, rdList[0]);
        System.enqueueJob(que);
        
        StripeSubscriptionQueueable que1 = new StripeSubscriptionQueueable(card_ch, rdList[1]);
        System.enqueueJob(que1);
        Test.stopTest();
    }
    
    @isTest
    static void test_handleInvoice() {
        createTest();
        Test.setMock(HttpCalloutMock.class, new InvoiceChargeSearchMock());   
        
        Test.startTest();
        StripeSubscriptionQueueable que = new StripeSubscriptionQueueable('cus_qwrfsapwq1', rdList[0], true);
        System.enqueueJob(que);
        Test.stopTest();
    }
    
    @isTest
    static void test_calculateEndDate() {
        String recurringType = 'Fixed';
        Date effectiveDate = Date.newInstance(2022, 01, 05);
        Test.startTest();
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', 1, 'Monthly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', 1, 'Monthly', 
                                        '6', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', null, 'Monthly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', null, 'Monthly', 
                                        '6', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Yearly', 1, 'Yearly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Yearly', null, 'Yearly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Quarterly', 1, 'Quarterly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Quarterly', null, 'Quarterly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Weekly', 1, 'Weekly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Weekly', null, 'Weekly', 
                                        '4', System.today());
        
        recurringType = 'Open';
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', 1, 'Monthly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', 1, 'Monthly', 
                                        '6', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', null, 'Monthly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Monthly', null, 'Monthly', 
                                        '6', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Yearly', 1, 'Yearly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Yearly', null, 'Yearly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Quarterly', 1, 'Quarterly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Quarterly', null, 'Quarterly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Weekly', 1, 'Weekly', 
                                        '4', System.today());
        
        StripeSubscriptionBatchHandler.calculateEndDate(recurringType, 1, 
                                        'Weekly', null, 'Weekly', 
                                        '4', System.today());
        Test.stopTest();
    }
}