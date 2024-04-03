/**
* Class Name: StripeSubscriptionBatch
* Auhtor: Gerent Team
* Description: sync recurring donation with subscription in stripe
* Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
* */
Global class StripeSubscriptionBatch implements Database.Batchable<sobject>, Schedulable, Database.AllowsCallouts {
    private String query;
    
    global Stripe_Batch_Setting__c custoSettingVal;
    
    DateTime todayTime = DateTime.now();
    list<String> paymentMethods = new list<String>();
    
    DateTime lastBatchRunTime;
    
    global StripeSubscriptionBatch(){
        // Query to get the specific recurring donations imported by telemarketers on daily basis
        if(Label.Stripe_Payment_Methods != null && Label.Stripe_Payment_Methods.trim().length()>0){
            if(Label.Stripe_Payment_Methods.contains(';')){
                paymentMethods=Label.Stripe_Payment_Methods.split(';');
            }else{
                paymentMethods.add(Label.Stripe_Payment_Methods);
            }
        }else{
            paymentMethods.add('Credit Card');
        }
        
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeSubscriptionBatch');
        lastBatchRunTime = custoSettingVal.Last_Run_DateTime__c != null ? custoSettingVal.Last_Run_DateTime__c : todayTime.addDays(-1);
        
        if (custoSettingVal != null) {
            query = 'SELECT id, Name, Stripe_Subscription_Id__c, npe03__Contact__c, npe03__Contact__r.Name, npe03__Contact__r.Stripe_Customer_Id__c,';
            query += ' npe03__Contact__r.FirstName, npe03__Contact__r.LastName, npe03__Contact__r.Phone, npe03__Contact__r.Email,';
            query += ' npe03__Contact__r.npe01__Preferred_Email__c, npe03__Contact__r.npe01__PreferredPhone__c, npe03__Contact__r.HomePhone,';
            query += ' npe03__Contact__r.npe01__WorkPhone__c, npe03__Contact__r.OtherPhone,  npe03__Contact__r.npe01__WorkEmail__c,';
            query += ' npe03__Contact__r.npe01__AlternateEmail__c, npe03__Amount__c, npe03__Installment_Period__c, npsp__RecurringType__c,';
            query += ' npsp__StartDate__c, npe03__Installments__c, npsp__Day_of_Month__c, npsp__InstallmentFrequency__c, npsp__Status__c,';
            query += ' npe03__Recurring_Donation_Campaign__c, npe03__Recurring_Donation_Campaign__r.stripe_product_id__c, Stripe_Price_Id__c,';
            query += ' npe03__Recurring_Donation_Campaign__r.Name, Account_BSB__c, Account_Number__c,  npsp__PaymentMethod__c, npsp__EndDate__c, Stripe_Last_Sync_Date__c, LastModifiedDate, Stripe_payment_method_id__c';
            query += ' FROM npe03__Recurring_Donation__c';
            query += ' WHERE Payment_Gateway__c= \'Stripe\' AND npsp__PaymentMethod__c IN: paymentMethods AND npe03__Recurring_Donation_Campaign__c != null AND LastModifiedDate >=: lastBatchRunTime';
            //query += ' AND Id = \'a099D00000N8mh6QAB\' '; //LastModifiedDate >: lastBatchRunTime
            //query += ' WHERE Payment_Gateway__c= \'Stripe\' AND npsp__PaymentMethod__c=\'Credit Card\'';
            //query += ' AND (LastModifiedDate =: dt OR Stripe_Last_Sync_Date__c = null OR Stripe_Last_Sync_Date__c <: dt)';
            query += ' ORDER BY LastModifiedDate'; 
        }
        //system.debug('### query: ' + query);
    }
    
    global database.QueryLocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<npe03__Recurring_Donation__c> scope){
        //system.debug('Testing Test ' + scope.size());
        try{
            if(Stripe_Setting__c.getValues('Default').Activation__c){
                // to update the stripe_product_id on Campaign record
                map<String, Campaign> campaignMap = new map<String, Campaign>();
                // to update stripe_subscription_id on recurring donations
                map<String, npe03__Recurring_Donation__c> recurringDonationMap = new map<String, npe03__Recurring_Donation__c>();
                for(npe03__Recurring_Donation__c s: scope){
                    system.debug('### check the batch records - name: '+s.Name);
                    if(s.npe03__Contact__r.Stripe_Customer_Id__c != null){
                        String productId;
                        if(s.npe03__Recurring_Donation_Campaign__r.stripe_product_id__c == null && !campaignMap.containsKey(s.npe03__Recurring_Donation_Campaign__c)){
                            // create product in stripe for campaign
                            productId = StripeSubscriptionBatchHandler.createProduct(s.npe03__Recurring_Donation_Campaign__r.Name, s.npe03__Recurring_Donation_Campaign__r.id);
                            // update campaign with stripe_product_id
                            campaignMap.put(s.npe03__Recurring_Donation_Campaign__c, new Campaign(Id = s.npe03__Recurring_Donation_Campaign__c, stripe_product_id__c = productId));
                        } else {
                            productId = s.npe03__Recurring_Donation_Campaign__r.stripe_product_id__c;
                        }
                        
                        System.debug('Stripe ID' + s.Stripe_Subscription_Id__c);
                        if(String.isEmpty(s.Stripe_payment_method_id__c) && s.npsp__PaymentMethod__c == 'Direct Debit'){
                            StripeSubscriptionBatch.ResponseWrapper pmResponse = createPaymentMethod(s.Account_BSB__c, s.Account_Number__c, s.npe03__Contact__r.Name, s.npe03__Contact__r.email, s.npe03__Contact__r.Stripe_customer_id__c);
                            s.Stripe_payment_method_id__c = pmResponse.id;
                        }
                        String subsId = StripeSubscriptionBatchHandler.createSubscrition(s.id, s.npe03__Contact__r.Stripe_Customer_Id__c, s.npe03__Amount__c, s.npsp__InstallmentFrequency__c, s.npe03__Installment_Period__c,
                                                                                         s.npsp__RecurringType__c, s.npsp__StartDate__c, s.npe03__Installments__c, productId,
                                                                                         s.npe03__Installment_Period__c, s.npsp__Day_of_Month__c, s.Stripe_Subscription_Id__c,  s.npsp__Status__c, s.Stripe_payment_method_id__c);
                        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(id = s.id, stripe_subscription_id__c = subsId,  Stripe_Last_Sync_Date__c = datetime.now(), Stripe_payment_method_id__c = s.Stripe_payment_method_id__c);
                        recurringDonationMap.put(rd.id, rd);
                        
                        /*If the start date for RD is today
                        if(s.npsp__StartDate__c <= date.today()){
                            //if(productId != null && productId.trim().length()>0) this condition is removed as not seem required
                        } 
                    	else if(s.npsp__StartDate__c > date.today()){
                            // Create future dated RD in stripe
                            // If RD's campaign exist in stripe
                            if(productId != null && productId.trim().length()>0){
                            String subsId = StripeSubscriptionBatchHandler.createSubscriptionSchedule(s.id,
                            s.npe03__Contact__r.stripe_customer_id__c,
                            s.npsp__StartDate__c, 
                            s.npsp__EndDate__c, 
                            s.Stripe_Price_Id__c, 
                            productId, 
                            s.npe03__Installment_Period__c, 
                            s.npe03__Amount__c,
                            s.Stripe_Subscription_Id__c,
                            s.npsp__Day_of_Month__c);
                            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(id = s.id, stripe_subscription_id__c = subsId,  Stripe_Last_Sync_Date__c = datetime.now());
                            recurringDonationMap.put(rd.Id, rd);
                            }
                            }*/
                    } else {
                        system.debug('### Customer does not exist.');
                    }
                }
                if(!campaignMap.isEmpty()){
                    update campaignMap.values();    
                }
                if(!recurringDonationMap.isEmpty()){
                    update recurringDonationMap.values();    
                }   
            }
        }catch(Exception e){
            //log error in salesforce
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripeSubscriptionBatch', e.getMessage(), 'StripeSubscriptionBatch', e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, CompletedDate FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeSubscriptionBatch');
        custoSettingVal.Last_Run_DateTime__c = a.CompletedDate;
        update custoSettingVal;   
        //StripeInvoiceHandler.getInvoice();
    }
    
    //Schedulable 
    global void execute(SchedulableContext SC) {
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeSubscriptionBatch');
        integer batchSize = integer.valueof(custoSettingVal.Batch_Size__c);
        Database.executeBatch(new StripeSubscriptionBatch(), batchSize);
    }
    
    public static String requestBody(String body, String key, String value){
        if( key.trim().length() > 0 && key != null){
            body += '&' + key + '=' + value;
        }
        return body;
    }
    
    public static StripeSubscriptionBatch.ResponseWrapper createPaymentMethod(string bsb_number, string account_number, string name, String email,String stripeCustomerId){
        //Api to create a payment method
        String body ='';
        String body2 = '';
        ResponseWrapper response = new ResponseWrapper();
        body = requestBody(body, 'type','au_becs_debit');
        body = requestBody(body, 'au_becs_debit[bsb_number]',bsb_number.substring(0, 3)+bsb_number.substring(4, 7));
        body = requestBody(body, 'au_becs_debit[account_number]',account_number);
        body = requestBody(body, 'billing_details[name]',name);
        if(email != null){
            body = requestBody(body, 'billing_details[email]',email);    
        }
        
        system.debug(body);
        
        HttpResponse responseJson =  StripeConnection.postPaymentMethod(Null, body);
        if(responseJson.getStatusCode() < 200 || responseJson.getStatusCode() > 299){
            //ApexLogCreator.createApexLog('StripeSubscriptionBatch', responseJson.getBody(), 'StripeSubscriptionBatch', responseJson.getStatus());
        }
        System.debug(responseJson.getBody());
        system.debug('responseJson');
        StripeSubscriptionBatch.ResponseWrapper rw = (StripeSubscriptionBatch.ResponseWrapper) System.JSON.deserialize (responseJson.getBody(), StripeSubscriptionBatch.ResponseWrapper.class);
        body2 = requestBody(body2, 'customer', stripeCustomerId);
        String API = rw.id+'/attach';
        HttpResponse responseJson1 =  StripeConnection.postPaymentMethod(API, body2);
        return rw;
    }
    
    public class ResponseWrapper{
        public String id;   
    }
    
    public class StripeAPIException extends Exception {}
}