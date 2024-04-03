public class StripeChargeBatch implements Database.Batchable<sObject> {
    String query;
    List<Charge__c> processedCharges = new List<Charge__c>();
    
    public StripeChargeBatch() {
        query = 'SELECT Id, Name, Is_Processed__c, Stripe_Charge_Id__c, Stripe_Payment_Intent_Id__c, Stripe_Charge_Status__c, ';
        query += 'Stripe_Customer_Id__c, Stripe_Invoice_Id__c, Stripe_Charge_Amount__c, Method_Type__c, Payment_Created_Date__c, ';
        query += 'Card_Last_Digits__c, Card_Type__c, Card_Token__c, Card_Expiration_Month__c, Card_Expiration_Year__c, ';
        query += 'Stripe_Payment_Method_Id__c, Failure_Code__c, Outcome_Reason__c, Campaign_Id__c, Is_Recurring__c, Donation_Source__c, ';
        query += 'Account_Token__c, Account_BSB__c, Account_Last_Digits__c, Opportunity_Id__c, Recurring_Donation_Id__c, ';
        query += 'RD_Installment_Every__c, RD_Installment_Period__c, RD_Installment_Effective_Date__c, RD_Installment_Day_Of_Month__c ';
        query += 'FROM Charge__c WHERE Is_Processed__c = false';
    } 
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Charge__c> charges) {
        try {
            System.debug('charges -> ' + charges);
            if(Stripe_Setting__c.getInstance('Default').Activation__c) { 
                Map<String, String> declineCodeMap = new Map<String, String>();
                for (Stripe_Decline_Code__mdt dc: [Select Id, DeveloperName, PAYMENT_RESULT__c From Stripe_Decline_Code__mdt]) {
                    declineCodeMap.put(dc.DeveloperName, dc.PAYMENT_RESULT__c);
                }
                
                Map<String, Charge__c> onePayChargesMap = new Map<String, Charge__c>();
                Map<String, Charge__c> invoiceChargeMap = new Map<String, Charge__c>();
                Set<String> customerIds = new Set<String>();
                
                for (Charge__c charge : charges) { 
                    if (charge.Stripe_Invoice_Id__c == null) {
                        onePayChargesMap.put(charge.Stripe_Charge_Id__c, charge);
                        List<String> splitCustomerId = charge.Stripe_Customer_Id__c.split('_');//Split the customer id for SOSL
                        customerIds.add('*' + splitCustomerId[1] + '*'); //to be considered in SOSL query as wildcard character
                    } else {
                        invoiceChargeMap.put(charge.Stripe_Invoice_Id__c, charge);
                    }
                }
                
                System.debug('onePayChargesMap -> ' + onePayChargesMap);
                System.debug('invoiceChargeMap -> ' + invoiceChargeMap);
                
                if (onePayChargesMap.size() > 0) {
                    ProcessChargeService.createOpportunityAndUpdatePaymentFromCharge(onePayChargesMap, customerIds, declineCodeMap);
                    processedCharges.addAll(onePayChargesMap.values());
                }
                
                if (invoiceChargeMap.size() > 0) {
                    ProcessChargeService.updateOpportunityAndPaymentFromCharge(invoiceChargeMap, declineCodeMap);
                    processedCharges.addAll(invoiceChargeMap.values());
                }
                
                if (processedCharges.size() > 0) {
                    System.debug('Processed charges to is processed true');
                    ProcessChargeService.updateProcessedCharges(processedCharges);
                }
            }
        } catch (Exception e) {
            ApexLogCreator.createApexLog('StripeChargeBatch', e.getMessage(), 'StripeChargeBatch', e.getStackTraceString());
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        if (processedCharges.size() > 0) { 
            System.debug('Delete processed charges');
        	//delete processedCharges;
        }
    }
}