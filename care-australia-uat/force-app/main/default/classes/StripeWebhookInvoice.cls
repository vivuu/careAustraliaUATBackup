@RestResource(urlMapping='/api/webhooks/Invoice')
global class StripeWebhookInvoice {
	@HttpPost
    global static void handleInvoice(){
     	try{
            if(Stripe_Setting__c.getValues('Default').Activation__c){
                RestRequest request = RestContext.request;
                Map<String, Object> jsonWrapper = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
                Map<String, Object> dataWrapper = (Map<String, Object>)jsonWrapper.get('data');
                Map<String, Object> invoiceWrapper = (Map<String, Object>)dataWrapper.get('object');
                Map<String, Object> lineWrapper = (Map<String, Object>)invoiceWrapper.get('lines');
                String invoiceId = String.valueOf(invoiceWrapper.get('id'));
                Invoice__c invoice;
                               
                List<Invoice__c> invoices = [SELECT Id, Stripe_Customer_Id__c, Stripe_Payment_Intent_Id__c, Stripe_Subscription_Id__c FROM Invoice__c WHERE Stripe_Invoice_Id__c =: invoiceId];
                if(invoices.size() > 0) {
                    invoice = invoices[0];
                } else {
                    invoice = new Invoice__c(
                        Stripe_Invoice_Id__c = String.valueOf(invoiceWrapper.get('id')),
                        Stripe_Customer_Id__c = String.valueOf(invoiceWrapper.get('customer')),
                        Stripe_Payment_Intent_Id__c = String.valueOf(invoiceWrapper.get('payment_intent')),
                        Stripe_Subscription_Id__c = String.valueOf(invoiceWrapper.get('subscription'))
                    );
                }
                
                if(invoiceWrapper.containsKey('charge')) {
                    invoice.Stripe_Charge_Id__c = String.valueOf(invoiceWrapper.get('charge'));
                }
                
                if (!lineWrapper.isEmpty()) {
                    List<Object> childDataWrapper = (List<Object>)lineWrapper.get('data');
                    Map<String, Object> metadataWrapper = (Map<String, Object>)((Map<String, Object>)childDataWrapper[0]).get('metadata');
                    if (metadataWrapper.containsKey('salesforce_rd_id')) {
                        invoice.Recurring_Donation_Id__c = String.valueOf(metadataWrapper.get('salesforce_rd_id'));
                        
                        //Following will help to update the invoice on Charge record with the respective RD ID
                        //The case comes up when we create RD from Salesforce flow and charge is created for recurring donation 
                        //But the invoice is not created at the time because subscription is created for respective RD when we run the batch
                        //So the following charge record must be query on the basis of RD ID in metadata and is not processed yet
                        //Update the stripe invoice id on charge and stripe charge id on invoice
                        List<Charge__c> charges = [SELECT Id, Stripe_Charge_Id__c from Charge__c where Recurring_Donation_Id__c =: invoice.Recurring_Donation_Id__c AND Is_Processed__c = false];
                        if(charges.size() > 0) {
                            charges[0].Stripe_Invoice_Id__c = invoice.Stripe_Invoice_Id__c;
                            update charges;
                            
                            invoice.Stripe_Charge_Id__c = charges[0].Stripe_Charge_Id__c;
                        }
                    }
                }
                
                upsert invoice;
                
            }
        } catch(Exception e){
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripeWebhookInvoice', e.getMessage(), 'handleInvoice', e.getStackTraceString());
        }   
    }
}