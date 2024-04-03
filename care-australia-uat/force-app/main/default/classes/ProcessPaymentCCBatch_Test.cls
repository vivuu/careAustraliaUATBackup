@istest
public class ProcessPaymentCCBatch_Test  {
    @testSetup 
    public static void setup() {
        BamboraAPI__c bamboraSettings = new BamboraAPI__c();
        bamboraSettings.Name = 'Bambora';
        bamboraSettings.Merchant_ID__c = 'test';
        bamboraSettings.Username__c = 'Test';
        bamboraSettings.Password__c = 'Test';
        bamboraSettings.Cash_Account_Number__c = 'Test';
        bamboraSettings.RG_Account_Number__c = 'Test';
        bamboraSettings.Batch_API__c = 'https://demo.ippayments.com.au/interface/api/batch.asmx';
        bamboraSettings.Payment_API__c = 'https://demo.ippayments.com.au/interface/api/dts.asmx';
        bamboraSettings.TokeniseCC_API__c = 'https://demo.ippayments.com.au/interface/api/sipp.asmx';
        insert bamboraSettings;
        
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Amount__c = 50;
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__PaymentMethod__c = 'Credit Card';
        rd.Card_Token__c ='123456';
        rd.Card_Number_Masked__c = '123456780000';
        rd.Card_Type__c = 'Visa';
        rd.npsp__StartDate__c = Date.newInstance(2021, 9, 30);
        rd.npe03__Date_Established__c = Date.newInstance(2021, 9, 30);
        insert rd;
        
        
    }
    @isTest 
    public static void testmethod1(){
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Card_Token__c,npsp__Card_Expiration_Month__c,npsp__Card_Expiration_Year__c FROM npe01__OppPayment__c];
        system.debug(paymentList);
        for(npe01__OppPayment__c payment : paymentList){
            payment.npe01__Payment_Method__c = 'Credit Card';
            payment.Card_Token__c = '123456';
            payment.npsp__Card_Expiration_Month__c = '11';
            payment.npsp__Card_Expiration_Year__c = '25';
        }
        update paymentList;
        system.debug(paymentList);
        system.debug([SELECT Id, Name, npe01__Opportunity__c, Donor_Name__c, npe01__Opportunity__r.npe03__Recurring_Donation__c, 
                      npe01__Check_Reference_Number__c, npe01__Custom_Payment_Field__c, npe01__Paid__c, npe01__Payment_Amount__c, 
                      npe01__Payment_Date__c, npe01__Payment_Method__c, npe01__Scheduled_Date__c, npe01__Written_Off__c, npsp__Payment_Acknowledged_Date__c,
                      Payment_Status__c, npsp__Batch_Number__c, Receipted_On__c, Card_Token__c, Card_Number_Masked__c, Card_Type__c, Payee_Name__c, Payment_Result__c, 
                      Response_Code__c, npsp__Card_Expiration_Month__c, npsp__Card_Expiration_Year__c FROM npe01__OppPayment__c 
                      where npe01__Opportunity__r.npe03__Recurring_Donation__c != Null and Payment_Result__c = 'Not Processed' and 
                      npe01__Scheduled_Date__c <= today and npe01__Paid__c= false and npe01__Payment_Method__c ='Credit Card' and 
                      npe01__Written_Off__c = false and Card_Token__c != null]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraSubmitBatchTrnFileMock(200,0));
        ProcessPaymentCCBatch ppccb = new ProcessPaymentCCBatch();
        Database.executeBatch(ppccb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod2(){
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,npe01__Written_Off__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Card_Token__c,npsp__Card_Expiration_Month__c,npsp__Card_Expiration_Year__c FROM npe01__OppPayment__c];
        system.debug(paymentList);
        for(npe01__OppPayment__c payment : paymentList){
            payment.npe01__Payment_Method__c = 'Credit Card';
            payment.Card_Token__c = '123456';
            payment.npsp__Card_Expiration_Month__c = '11';
            payment.npsp__Card_Expiration_Year__c = '25';
        }
        update paymentList;
        system.debug(paymentList);
        system.debug(paymentList[0].npe01__Opportunity__r.npe03__Recurring_Donation__c);
        system.debug([SELECT Id, Name, npe01__Opportunity__c, Donor_Name__c, npe01__Opportunity__r.npe03__Recurring_Donation__c, 
                      npe01__Check_Reference_Number__c, npe01__Custom_Payment_Field__c, npe01__Paid__c, npe01__Payment_Amount__c, 
                      npe01__Payment_Date__c, npe01__Payment_Method__c, npe01__Scheduled_Date__c, npe01__Written_Off__c, npsp__Payment_Acknowledged_Date__c,
                      Payment_Status__c, npsp__Batch_Number__c, Receipted_On__c, Card_Token__c, Card_Number_Masked__c, Card_Type__c, Payee_Name__c, Payment_Result__c, 
                      Response_Code__c, npsp__Card_Expiration_Month__c, npsp__Card_Expiration_Year__c FROM npe01__OppPayment__c 
                      where npe01__Opportunity__r.npe03__Recurring_Donation__c != Null and Payment_Result__c = 'Not Processed' and 
                      npe01__Scheduled_Date__c <= today and npe01__Paid__c= false and npe01__Payment_Method__c ='Credit Card' and 
                      npe01__Written_Off__c = false and Card_Token__c != null]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraSubmitBatchTrnFileMock(200,8));
        ProcessPaymentCCBatch ppccb = new ProcessPaymentCCBatch();
        Database.executeBatch(ppccb);
        Test.stopTest();
    }
    
}