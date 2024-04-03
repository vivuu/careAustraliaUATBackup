@isTest
public class StripeInvoiceSchedulableTest {
    @testSetup
    static void createData() {
        Account acc = new Account(Name='Test acc');
        insert acc;
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(AccountId=acc.Id, FirstName='Test', LastName='Customer', Email='test@test.com', npe01__PreferredPhone__c='Mobile', Phone='+61466666666', Stripe_Customer_Id__c='cus_OezvOgmGSxROgw', Stripe_Customer_Ids__c='cus_OezvOgmGSxROgw'));
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        list<npe03__Recurring_Donation__c> rdList = new list<npe03__Recurring_Donation__c>();
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
        }
        insert rdList;
    }
    
    @isTest
    static void execute_test() {
        Test.setMock(HttpCalloutMock.class, new InvoiceChargeSearchMock());        
        
        npe03__Recurring_Donation__c rd = [SELECT Id FROM npe03__Recurring_Donation__c LIMIT 1];
        
        Test.startTest();
        Datetime startDateTime = Datetime.now().addMinutes(2);
        String cronExp = '0 ' + startDateTime.minute() + ' ' + startDateTime.hour() + ' ' + startDateTime.day() + ' ' + startDateTime.month() + ' ? ' + startDateTime.year();
        System.schedule('Update Recurring donation payments for RD -> ' + rd.Id, cronExp, new StripeInvoiceSchedulable('sub_1NyaKdGGWgtqSxG4QLsvkbeZ', rd));
        Test.stopTest();
    }
}