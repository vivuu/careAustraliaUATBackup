/**
 * Class Name: StripeCustomerBatch
 * Auhtor: Gerent Team
 * Description: sync contact with customers in stripe
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */
global class StripeCustomerBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    global Stripe_Batch_Setting__c custoSettingVal;
    DateTime todayTime = DateTime.now();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String Query;
        
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeCustomerBatch');
        DateTime lastBatchRunTime = custoSettingVal.Last_Run_DateTime__c != null ? custoSettingVal.Last_Run_DateTime__c : todayTime.addDays(-1);
        
        if (custoSettingVal != null) {
            Query = 'SELECT id, Stripe_Customer_Id__c, FirstName, MiddleName, LastName, Email, Phone, npe01__HomeEmail__c,';
            Query += ' npe01__WorkEmail__c, npe01__AlternateEmail__c,';
            Query += ' (SELECT id, stripe_subscription_id__c from R00N80000002bOmREAU WHERE Payment_Gateway__c = \'Stripe\' LIMIT 1) rg FROM Contact';
            Query += ' WHERE LastModifiedDate >=: lastBatchRunTime';
            Query += ' ORDER BY CreatedDate DESC';
        }
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List <contact> scope) {
        try{
            if(Stripe_Setting__c.getValues('Default').Activation__c){
             	StripeCustomerBatchHandler.CreateUpdateCustomer(scope);   
            }
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripeCustomerBatchHandler', e.getMessage(), 'StripeCustomerBatchHandler', e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, CompletedDate FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeCustomerBatch');
        custoSettingVal.Last_Run_DateTime__c = a.CompletedDate;
        update custoSettingVal;        
    }

    //Schedulable 
    global void execute(SchedulableContext SC) {
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeCustomerBatch');
        integer batchSize = integer.valueof(custoSettingVal.Batch_Size__c);
        Database.executeBatch(new StripeCustomerBatch(), batchSize);
    }
}