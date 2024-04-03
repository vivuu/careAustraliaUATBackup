public class StripeInvoiceQueueable implements Queueable, Database.AllowsCallouts {
    String subsId;
    Id rdId;
    
    public StripeInvoiceQueueable(String subsId, Id rdId) {
        this.subsId = subsId;
        this.rdId = rdId;
    }

    public void execute(QueueableContext context) {
        HttpResponse invoiceResponse = StripeConnection.getSearchInvoice('subscription:\''+ this.subsId +'\'');
        Map<String, Object> invoiceWrapper = (Map<String, Object>) JSON.deserializeUntyped(invoiceResponse.getBody());
        List<Object> invoiceDataList = (List<Object>) invoiceWrapper.get('data');
        Map<String, Object> invoice = (Map<String, Object>) invoiceDataList[0];
        
        String chargeId = String.valueOf(invoice.get('charge'));
        HttpResponse chargeResponse = StripeConnection.getCharge(chargeId);
        Map<String, Object> paymentResponse = (Map<String, Object>) JSON.deserializeUntyped(chargeResponse.getBody());
        Map<String, Object> paymentMethodWrapper = (Map<String, Object>)paymentResponse.get('payment_method_details');
        Map<String, Object> cardWrapper = (Map<String, Object>)paymentMethodWrapper.get('card');
        
        String stripeInvoiceId = (String) invoice.get('id');
        List<SObject> recordsToDelete = new List<SObject>();
        recordsToDelete.addAll([SELECT Id FROM Charge__c WHERE Stripe_Invoice_Id__c = :stripeInvoiceId]);
        recordsToDelete.addAll([SELECT Id FROM Invoice__c WHERE Stripe_Invoice_Id__c = :stripeInvoiceId]);
        if(recordsToDelete.size() > 0) {
            delete recordsToDelete;
        }
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(id = this.rdId, Stripe_Last_Sync_Date__c = datetime.now(), Card_Token__c=(String) cardWrapper.get('fingerprint'));
        update rd;
        
        Opportunity opp = [SELECT Id, (SELECT Id FROM npe01__OppPayment__r) FROM Opportunity WHERE StageName = 'Pledged' AND npe03__Recurring_Donation__c = :this.rdId ORDER BY Created__c ASC][0];
        if(opp.npe01__OppPayment__r != null) {
            npe01__OppPayment__c oppPayment = opp.npe01__OppPayment__r;
            oppPayment.npe01__Paid__c = true;
            oppPayment.CurrencyIsoCode = 'AUD';
            oppPayment.npe01__Payment_Date__c = System.today();
            oppPayment.Payment_Result__c = 'Success';
            oppPayment.Card_Token__c=(String) cardWrapper.get('fingerprint');
            CheckoutUtility.setPaymentDetails(oppPayment, paymentResponse);
            update oppPayment;   
        }
    }
}