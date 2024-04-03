@istest
public class ProcessPaymentDDBatch_Test  {
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
        rd.npsp__PaymentMethod__c = 'Direct Debit';
        rd.Account_Number__c ='123456';
        rd.Account_BSB__c = '123-456';
        rd.Financial_Institution__c = 'CITI';
        rd.Payee_Name__c = 'Test Payee';
        rd.npsp__StartDate__c = Date.newInstance(2021, 9, 30);
        rd.npe03__Date_Established__c = Date.newInstance(2021, 9, 30);
        insert rd;
        
        
    }
    @isTest 
    public static void testmethod1(){
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Account_BSB__c, Account_Number__c, Financial_Institution__c , Payee_Name__c FROM npe01__OppPayment__c];
        system.debug(paymentList);
        for(npe01__OppPayment__c payment : paymentList){
            payment.npe01__Payment_Method__c = 'Direct Debit';
            payment.Account_Number__c ='123456';
            payment.Account_BSB__c = '123-456';
        }
        update paymentList;
        system.debug(paymentList);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraSubmitBatchTrnFileMock(200,0));
        ProcessPaymentDDBatch ppDDb = new ProcessPaymentDDBatch();
        Database.executeBatch(ppDDb);
        Test.stopTest();
    }
    @isTest 
    public static void testmethod2(){
        list<npe01__OppPayment__c> paymentList = [select id, npe01__Opportunity__r.npe03__Recurring_Donation__c,Payment_Result__c,npe01__Scheduled_Date__c,
                                                  npe01__Paid__c,npe01__Payment_Method__c,Account_BSB__c, Account_Number__c, Financial_Institution__c , Payee_Name__c FROM npe01__OppPayment__c];
        system.debug(paymentList);
        for(npe01__OppPayment__c payment : paymentList){
            payment.npe01__Payment_Method__c = 'Direct Debit';
            payment.Account_Number__c ='123456';
            payment.Account_BSB__c = '123-456';
        }
        update paymentList;
        system.debug(paymentList);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BamboraSubmitBatchTrnFileMock(200,8));
        ProcessPaymentDDBatch ppDDb = new ProcessPaymentDDBatch();
        Database.executeBatch(ppDDb);
        Test.stopTest();
    }
    
}