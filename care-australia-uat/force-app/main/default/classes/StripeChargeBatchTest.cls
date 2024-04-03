@isTest
public class StripeChargeBatchTest {
	@testSetup
    static void createTestData() {
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
        
        Charge__c card_ch = new Charge__c();
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
        
        Charge__c direct_ch = new Charge__c();
        direct_ch.Stripe_Charge_Id__c = 'ch_3NrfvyGGWgtqSxG40U8tXiA8';
        direct_ch.Stripe_Charge_Status__c = 'succeeded';
        direct_ch.Stripe_Customer_Id__c = 'cus_OezvOgmGSxROgw';
        direct_ch.Stripe_Charge_Amount__c = 100;
        direct_ch.Method_Type__c = 'au_becs_debit';
        direct_ch.Payment_Created_Date__c = System.today();
        direct_ch.Account_Last_Digits__c = '4242';
        direct_ch.Account_Token__c = 'token';
        direct_ch.Account_BSB__c = '01';
        direct_ch.Card_Expiration_Year__c = '2024';
        direct_ch.Stripe_Payment_Method_Id__c = 'paymentmethod';
        direct_ch.Campaign_Id__c = String.valueOf(camp.Id);
        direct_ch.Is_Recurring__c = false;
        direct_ch.Is_Processed__c = false;
        
        charges.add(direct_ch);
        
        Charge__c invoice_ch = new Charge__c();
        invoice_ch.Stripe_Charge_Id__c = 'ch_3NrfvyGGWgtqSxG40U8tXiA9';
        invoice_ch.Stripe_Charge_Status__c = 'succeeded';
        invoice_ch.Stripe_Customer_Id__c = 'cus_OezvOgmGSxROgw';
        invoice_ch.Stripe_Charge_Amount__c = 100;
        invoice_ch.Method_Type__c = 'card';
        invoice_ch.Payment_Created_Date__c = System.today();
        invoice_ch.Card_Last_Digits__c = '4242';
        invoice_ch.Card_Type__c = 'visa';
        invoice_ch.Card_Token__c = 'token';
        invoice_ch.Card_Expiration_Month__c = '01';
        invoice_ch.Card_Expiration_Year__c = '2024';
        invoice_ch.Stripe_Payment_Method_Id__c = 'paymentmethod';
        invoice_ch.Campaign_Id__c = String.valueOf(camp.Id);
        invoice_ch.Is_Recurring__c = true;
        invoice_ch.Is_Processed__c = false;
        invoice_ch.Stripe_Invoice_Id__c = 'in_3NrfvyGGWgtqSxG40U8tXiA9';
        
        charges.add(invoice_ch);
        
        insert charges;
        
        Invoice__c invoice = new Invoice__c();
        invoice.Stripe_Charge_Id__c = invoice_ch.Stripe_Charge_Id__c;
        invoice.Stripe_Customer_Id__c = invoice_ch.Stripe_Customer_Id__c;
        invoice.Stripe_Invoice_Id__c = invoice_ch.Stripe_Invoice_Id__c;
        invoice.Stripe_Payment_Intent_Id__c = invoice_ch.Stripe_Payment_Intent_Id__c;
        invoice.Stripe_Subscription_Id__c = 'subsId';
        insert invoice;
        
        insert new npe03__Recurring_Donation__c(
            npe03__Contact__c=conList[0].Id, 
            npe03__Amount__c=500,
            npe03__Recurring_Donation_Campaign__c=camp.Id, 
            npsp__CardExpirationMonth__c='09', 
            npsp__CardExpirationYear__c='2024', 
            npsp__CardLast4__c='2424', 
            Card_Number_Masked__c='',
            Card_Token__c='', 
            Card_Type__c='Visa',
            npsp__StartDate__c=date.today().addDays(15), 
            npsp__RecurringType__c='Fixed', 
            npsp__InstallmentFrequency__c=1, 
            npe03__Installment_Period__c='Weekly', 
            npe03__Installments__c=12, 
            Payment_Gateway__c='Stripe', 
            npsp__PaymentMethod__c='Credit Card',
            npsp__Status__c='Active',
            Stripe_Subscription_Id__c = 'subsId'
        );
        
        Stripe_Setting__c recSetting = new Stripe_Setting__c();
        recSetting.Name= 'Default';
        recSetting.Default_Contact__c = conList[0].id;
        recSetting.Default_Campaign__c = camp.id;
        recSetting.Activation__c = True;
        insert recSetting;
        
        Stripe_Charge_Settings__c mc = new Stripe_Charge_Settings__c();
        mc.Name= 'Default';
        mc.Type_of_donation_source__c = 'credit card';
        insert mc;
    }
    
    @isTest
    static void runBatch_StripeCharge() {
        Contact con = [SELECT Id FROM Contact];
        Id[] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = con.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        StripeChargeBatch batch = new StripeChargeBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}