@isTest
public class StripeSubscriptionBatchTest {
	@TestSetup
    private static void testData(){
        /*Stripe_Batch_Setting__c customerSetting = new Stripe_Batch_Setting__c(Name='StripeSubscriptionBatch', Batch_Size__c=50, Description__c='For StripeSubscriptionBatch');
        insert customerSetting;
        */
        
        
        list<Contact> conList = new list<Contact>();
        for(Integer i=1; i<=35; i++){
            String str=String.valueOf(i);
            if(i<10){
                str='0'+i;
            }
            String stripeId='cus_MWHbeeJlTnGC'+str;
            conList.add(new Contact(Stripe_Customer_Id__c=stripeId, FirstName='Test', LastName='Customer'+i, Email='test@test.com'+i, npe01__PreferredPhone__c='Mobile', Phone='+614666666'+str));
        }
        insert conList;
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
         
		 //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = conList[0].id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting;
        
        Stripe_Batch_Setting__c sbs = new Stripe_Batch_Setting__c();
        sbs.Name = 'StripeSubscriptionBatch';
        sbs.Batch_Size__c = 50;
        insert sbs;
        
        list<npe03__Recurring_Donation__c> rdList = new list<npe03__Recurring_Donation__c>();
         // Reccuring type=fixed + Installment period=Weekly/Quaterly/yearly/monthly+ installment frequency=1 +start_date.days(15) 
        rdList.add(new npe03__Recurring_Donation__c(Payee_Name__c='Test', npe03__Contact__c=conList[1].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=date.today().addDays(15), npsp__RecurringType__c='Fixed', npsp__InstallmentFrequency__c=1, npe03__Installment_Period__c='Weekly', npe03__Installments__c=12, Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        rdList.add(new npe03__Recurring_Donation__c(Payee_Name__c='Test', npe03__Contact__c=conList[1].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=date.today().addDays(15), npsp__RecurringType__c='Fixed', npsp__InstallmentFrequency__c=1, npe03__Installment_Period__c='Quarterly', npe03__Installments__c=12, Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        rdList.add(new npe03__Recurring_Donation__c(Payee_Name__c='Test', npe03__Contact__c=conList[1].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=date.today().addDays(15), npsp__RecurringType__c='Fixed', npsp__InstallmentFrequency__c=1, npe03__Installment_Period__c='Yearly', npe03__Installments__c=12, Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
      	rdList.add(new npe03__Recurring_Donation__c(Payee_Name__c='Test', npe03__Contact__c=conList[1].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=date.today().addDays(15), npsp__RecurringType__c='Fixed', npsp__InstallmentFrequency__c=1, npe03__Installment_Period__c='Monthly', npe03__Installments__c=12, Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
      	
        insert rdList;
    }
    
    @isTest
    static void testBatchRun(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeSubscriptionBatch ctrl = new StripeSubscriptionBatch();
        System.schedule('sch', '0 0 13 * * ?', ctrl);
        Test.stopTest();
    }
   
    @isTest
    static void createPaymentMethod_test() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripeSubscriptionBatch.createPaymentMethod('bsbasfdaw', '6516510', 'asasd', 'as@gmail.com', 'cusId');
        Test.stopTest();
    }
    
    @isTest
    static void requestBody_test() {
        Test.startTest();
        StripeSubscriptionBatch.requestBody('', 'ket', 'asasd');
        Test.stopTest();
    }
}