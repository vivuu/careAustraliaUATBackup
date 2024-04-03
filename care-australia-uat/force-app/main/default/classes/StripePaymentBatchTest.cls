@isTest
public class StripePaymentBatchTest {
    @TestSetup
    private static void testData(){
        Stripe_Batch_Setting__c customerSetting = new Stripe_Batch_Setting__c(Name='StripePaymentBatch', Last_Run_At__c = date.today(), Batch_Size__c=50, Description__c='For StripePaymentBatch');
        insert customerSetting;
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(Stripe_Customer_Id__c='cus_MWHbeeJlTnGCgG', FirstName='Test', LastName='Customer1', Email='test@test.com1', npe01__PreferredPhone__c='Mobile', Phone='+61466666611'));
        conList.add(new Contact(FirstName='Test', LastName='Customer2', Email='test@test.com2', npe01__PreferredPhone__c='Mobile', Phone='+61466666622'));
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
        
        list<npe03__Recurring_Donation__c> rdList = new list<npe03__Recurring_Donation__c>();
        for(Integer i=0; i<conList.size(); i++){
            rdList.add(new npe03__Recurring_Donation__c(npe03__Contact__c=conList[i].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=System.Today(), npe03__Installment_Period__c='Monthly', Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        }
        insert rdList;
        
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opp Opportunity', 
                                    StageName='Pledged', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=Date.newInstance(2022, 09, 29), 
                                    Amount=200, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opp Opportunity 2', 
                                    StageName='Pledged', 
                                    npsp__Primary_Contact__c=conList[1].Id,
                                    AccountID=conList[1].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=Date.newInstance(2022, 09, 29), 
                                    Amount=200, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
        //CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', 
        insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id, Stripe_Charge_ID__c = null, Stripe_Payment_Method_Id__c = 'pm_1LqzAHGGWgtqSxG4LYV010Rd',
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(), isGiftEnty__c=true, npe01__Paid__c=false, 
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[1].Id, Stripe_Charge_ID__c = null, Stripe_Payment_Method_Id__c = 'pm_1LqzAHGGWgtqSxG4LYV010Rd',
                                              npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(), isGiftEnty__c=true, npe01__Paid__c=false, 
                                              npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;
    }
        
    @isTest
    public static void testBatchRun(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        StripePaymentBatch ba = new StripePaymentBatch();
        System.schedule('Schedule', '0 0 13 * * ?', ba);
        Test.stopTest();
    }

}