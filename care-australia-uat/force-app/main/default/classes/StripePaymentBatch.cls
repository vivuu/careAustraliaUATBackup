/**
 * Class Name: StripePaymentBatch
 * Auhtor: Gerent Team
 * Description: sync payments with Stripe
 * Modification Details: Amit Goyal - 04/10/2022 - Initial version created
 * */
global class StripePaymentBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
	global Stripe_Batch_Setting__c custoSettingVal;
    Date dt=System.Today();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String Query;
        Date batchRunDate;
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripePaymentBatch');
        if (custoSettingVal != null) {
            batchRunDate = custoSettingVal.Last_Run_At__c != null ? custoSettingVal.Last_Run_At__c : dt;
            //batchRunDate=batchRunDate.addDays(+1);
            Query = 'SELECT id, npe01__Payment_Amount__c, npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c, npe01__Opportunity__c, npsp__Card_Expiration_Month__c, npsp__Card_Expiration_Year__c,';
            Query += ' npsp__Card_Last_4__c, Card_Number_Masked__c, Card_Token__c, Stripe_Payment_Method_Id__c';
            Query += ' FROM npe01__OppPayment__c';
            Query += ' WHERE npe01__Payment_Date__c =: batchRunDate AND Stripe_Charge_ID__c = null AND npe01__Payment_Method__c=\'Credit Card\' AND npe01__Paid__c=false AND isGiftEnty__c=true';
            Query += ' ORDER BY CreatedDate DESC';
            //OppPayment
        }
        system.debug(dt);
        system.debug(Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<npe01__OppPayment__c> scope) {
        try{
            System.debug(scope);
            StripePaymentBatchHandler.createPayment(scope);
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            //ApexLogCreator.createApexLog('StripePaymentBatch', e.getMessage(), 'StripePaymentBatch', e.getStackTraceString());
            ApexLogCreator.createApexLog('StripePaymentBatchHandler', e.getMessage(), 'StripePaymentBatchHandler', e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, CompletedDate FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripePaymentBatch');
        custoSettingVal.Last_Run_At__c = a.CompletedDate.Date();
        update custoSettingVal;
    }
    
    //Schedulable 
    global void execute(SchedulableContext SC) {
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripePaymentBatch');
        integer batchSize = integer.valueof(custoSettingVal.Batch_Size__c);
       // Database.executeBatch(new StripeCustomerBatch(), batchSize);
         Database.executeBatch(new StripePaymentBatch(), batchSize);
    }
}