@isTest
public class StripeCustomerBatchTest {
	@TestSetup
    private static void testData(){
        Stripe_Batch_Setting__c customerSetting = new Stripe_Batch_Setting__c(Name='StripeCustomerBatch', Batch_Size__c=50, Description__c='For StripeCustomerBatch');
        insert customerSetting;
        
        list<Contact> conList = new list<Contact>();
        for(Integer i=1; i<=50; i++){
            String str=String.valueOf(i);
            if(i<10){
                str='0'+i;
            }
            String stripeId=null;
            if(i==1){
                //stripeId='cus_MWHbeeJlTnGCgG';
            }
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
        
        list<npe03__Recurring_Donation__c> rdList = new list<npe03__Recurring_Donation__c>();
        for(Integer i=0; i<conList.size(); i++){
            rdList.add(new npe03__Recurring_Donation__c(npe03__Organization__c=conList[i].AccountId, npe03__Contact__c=conList[i].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=System.Today(), npe03__Installment_Period__c='Monthly', Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        }
        insert rdList;
        
        /*Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opportunity', StageName='Pledged', npsp__Primary_Contact__c=conList[0].Id, AccountID=conList[0].AccountId, CampaignId=camp.Id, CloseDate=System.today().addDays(7), Amount=500, Type='One-Off Gift', Donation_Source__c='Telemarketing'));
        insert oppList;
        
        list<npe01__OppPayment__c> payments = new list<npe01__OppPayment__c>();
        payments.add(new npe01__OppPayment__c(npe01__Opportunity__c=oppList[0].Id, npe01__Payment_Amount__c=500, npe01__Payment_Date__c=System.Today(), npe01__Payment_Method__c='Credit Card', npe01__Scheduled_Date__c=System.Today()));
        insert payments;*/
    }
    
    public static testMethod void testBatchRun(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        //StripeCustomerBatch ba= new StripeCustomerBatch();
        //Id jobid= Database.executeBatch(ba,5);
        StripeCustomerBatch ctrl = new StripeCustomerBatch();
        ctrl.execute(null);
        Test.stopTest();
    }
}