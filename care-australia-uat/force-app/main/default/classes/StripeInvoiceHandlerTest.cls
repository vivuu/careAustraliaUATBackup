@isTest
public class StripeInvoiceHandlerTest {
  
    public static testMethod void testhandleCustomer(){
        
        list<Contact> conList = new list<Contact>();
        conList.add(new Contact(FirstName='Test', LastName='Customer', Email='test@test.com', Stripe_customer_id__c = 'cus_MEIO6YQafQq7oj' , npe01__PreferredPhone__c='Mobile', Phone='+61466666666'));
        insert conList;
        
         Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        Id donation_oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId=donation_oppRTId, Name='Test Customer Opportunity', 
                                    StageName='Closed Won', 
                                    npsp__Primary_Contact__c=conList[0].Id,
                                    AccountID=conList[0].AccountId,
                                    CampaignId=camp.Id, 
                                    CloseDate=date.today(), 
                                    Amount=500, 
                                    Type='One-Off Gift',
                                    Donation_Source__c='Web'));
         insert oppList;
                      
/*        stripe_defaults__c rec = new stripe_defaults__c();
        rec.name = 'default_contact';
        rec.value__c = conList[0].id;
        insert rec;
        
        stripe_defaults__c recProd = new stripe_defaults__c();
        recProd.name = 'default_product';
        recProd.value__c = camp.id;
        insert recProd;
 */       
        //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = conList[0].id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting;
        
        List<npe03__Recurring_Donation__c> rdList = new List<npe03__Recurring_Donation__c>();
        rdList.add(new npe03__Recurring_Donation__c(npe03__Organization__c=conList[0].AccountId, npe03__Contact__c=conList[0].Id, stripe_subscription_id__c = 'sub_1Li5pYGGWgtqSxG4QsaC8EvZ', npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=date.newInstance(2022, 10, 17), npsp__RecurringType__c='Open', npsp__InstallmentFrequency__c=1, npe03__Installment_Period__c='Weekly', npe03__Installments__c=12, Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        insert rdList;
        
        Stripe_Batch_Setting__c recBatchSetting = new Stripe_Batch_Setting__c();
        recBatchSetting.Name = 'StripeInvoiceBatch';
        recBatchSetting.Last_Run_At__c = null;
        insert recBatchSetting;

        Test.setMock(HttpCalloutMock.class, new Stripe_MockHttpResponseGenerator(200));
        
        Test.startTest();
        StripeInvoiceHandler.getInvoice();
        Test.stopTest();

    }
    
}