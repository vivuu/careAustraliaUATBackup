@isTest
public with sharing class StripeBatchGiftEntryCtrlTest {
    @TestSetup
    private static void testData(){
        Stripe_Batch_Setting__c customerSetting = new Stripe_Batch_Setting__c(Name='StripeSubscriptionBatch', Batch_Size__c=50, Description__c='For StripeSubscriptionBatch');
        insert customerSetting;
        
        list<Contact> conList = new list<Contact>();
        for(Integer i=1; i<=10; i++){
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
        
        list<npe03__Recurring_Donation__c> rdList = new list<npe03__Recurring_Donation__c>();
        for(Integer i=0; i<conList.size(); i++){
            Date startDate=System.Today();
            if(i==1){
                startDate=System.Today();
            }
            rdList.add(new npe03__Recurring_Donation__c(npe03__Organization__c=conList[i].AccountId, npe03__Contact__c=conList[i].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=startDate, npe03__Installment_Period__c='Monthly', Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        }
        
      	rdList.add(new npe03__Recurring_Donation__c(npe03__Organization__c=conList[0].AccountId, npe03__Contact__c=conList[0].Id, npe03__Amount__c=500, npe03__Recurring_Donation_Campaign__c=camp.Id, npsp__CardExpirationMonth__c='09', npsp__CardExpirationYear__c='2024', npsp__CardLast4__c='2424', Card_Number_Masked__c='', Card_Token__c='', Card_Type__c='Visa', npsp__StartDate__c=date.today(), npsp__RecurringType__c='Fixed', npsp__InstallmentFrequency__c=1, npe03__Installment_Period__c='Monthly', npe03__Installments__c=12, Payment_Gateway__c='Stripe', npsp__PaymentMethod__c='Credit Card', npsp__Status__c='Active'));
        insert rdList;
    }
    
    static testMethod void addCustomerTest(){
        list<Campaign> campaignList = [Select Id, Name From Campaign Where Name='2022 CAREGifts'];
        Map<String,Object> param=new Map<String,Object>();
        param.put('firstName','firstName');
        param.put('lastName','lastName');
        param.put('email','test@emailtest.com');
        param.put('MailingStreet','Park View');
        param.put('MailingCity','Sydney');
        param.put('MailingState','New South Wales');
        param.put('MailingCountry','Australia');
        param.put('MailingPostalCode','202022');        
        Test.startTest();
        Contact con=StripeBatchGiftEntryCtrl.addCustomer(JSON.serialize(param));
        String jsonForPaymentRecord='[{"serialNo":1,"paymentMethod":"","checkRef":"","contactId":"'+con.id+'","contactName":"test amit11102022","donationDate":"2022-10-25","amount":"20","campaignId":"'+campaignList[0].Id+'","campaignName":"'+campaignList[0].Name+'","recurringId":"","recurringName":"","contactIdentifier":"rowContact-0","recurringIdentifier":"rowRecurring-0","campaignIdentifier":"rowCampaign-0","cardNumber":"4242424242424242","expiryMonth":"09","expiryYear":"2030","id":"pm_1LrcNDGGWgtqSxG4wi1Hp8yl","status":null,"name":null,"last4":"4242","cardId":null,"brand":"visa","fingerprint":"k3Oq1WWP1nBVr7hR"}]';
        Map<String,object> paramMap=StripeBatchGiftEntryCtrl.createPaymentRecords(jsonForPaymentRecord);
        Test.stopTest();
        System.assertEquals(true, con.id!=null, 'addCustomer method must return contact record');
    }
    
    static testMethod void addCustomerRDTest(){
        list<npe03__Recurring_Donation__c> rdList = [Select Id, Name, npe03__Contact__c, npe03__Contact__r.Name From npe03__Recurring_Donation__c limit 1];
        String jsonForPaymentRecord='[{"serialNo":1,"paymentMethod":"","checkRef":"","contactId":"'+rdList[0].npe03__Contact__c+'","contactName":"'+rdList[0].npe03__Contact__r.Name+'","donationDate":"2022-10-25","amount":"20","campaignId":"","campaignName":"","recurringId":"'+rdList[0].Id+'","recurringName":"'+rdList[0].Name+'","contactIdentifier":"rowContact-0","recurringIdentifier":"rowRecurring-0","campaignIdentifier":"rowCampaign-0","cardNumber":"4242424242424242","expiryMonth":"09","expiryYear":"2030","id":"pm_1LrcNDGGWgtqSxG4wi1Hp8yl","status":null,"name":null,"last4":"4242","cardId":null,"brand":"visa","fingerprint":"k3Oq1WWP1nBVr7hR"}]';
        Test.startTest();
        Map<String,object> paramMap=StripeBatchGiftEntryCtrl.createPaymentRecords(jsonForPaymentRecord);
        Test.stopTest();
        System.assertEquals(true, rdList[0].npe03__Contact__c!=null, 'addCustomer method must return contact record');
    }
    
    static testMethod void getPicklistValuesTest(){
        Test.startTest();
        String resString=StripeBatchGiftEntryCtrl.getPicklistValues('Lead','LeadSource');
        Test.stopTest();
        System.assertEquals(true, resString!=null, 'It should return a jason string');
    }
}