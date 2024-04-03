public class StripeSubscriptionQueueable implements Queueable, Database.AllowsCallouts{
	Charge__c charge;
    npe03__Recurring_Donation__c rd;
    
    Boolean handleInvoice;
    String customerId;
    
    public StripeSubscriptionQueueable(Charge__c charge, npe03__Recurring_Donation__c rd) {
        this.charge = charge;
        this.rd = rd;
    }
    
    public StripeSubscriptionQueueable(String customerId, npe03__Recurring_Donation__c rd, Boolean handleInvoice) {
        this.customerId = customerId;
        this.rd = rd;
        this.handleInvoice = handleInvoice;
    }
    
    public void execute(QueueableContext context) {
        Campaign cam = [SELECT Id, Name FROM Campaign WHERE Id = :this.rd.npe03__Recurring_Donation_Campaign__c LIMIT 1];
            
        String productId = StripeSubscriptionBatchHandler.createProduct(cam.Name, this.rd.npe03__Recurring_Donation_Campaign__c);
        
        System.debug('cam.Name  -> ' + cam.Name);
        
        System.debug('Product Id from stripe -> ' + productId);
        
        if(this.customerId != null && String.IsEmpty(customerId)) {
            this.customerId = charge.Stripe_Customer_Id__c;
        }
        
        String subsId = StripeSubscriptionBatchHandler.createSubscrition(this.rd.id, this.customerId, this.rd.npe03__Amount__c, this.rd.npsp__InstallmentFrequency__c, this.rd.npe03__Installment_Period__c,
                                                                         this.rd.npsp__RecurringType__c, this.rd.npsp__StartDate__c, this.rd.npe03__Installments__c, productId,
                                                                         this.rd.npe03__Installment_Period__c, this.rd.npsp__Day_of_Month__c, this.rd.Stripe_Subscription_Id__c, this.rd.npsp__Status__c, this.rd.Stripe_payment_method_id__c);
        System.debug('subscription id of RD from charge webhook-> ' + subsId);
        
        if(this.handleInvoice == true) {
            this.rd = new npe03__Recurring_Donation__c(id = this.rd.id, stripe_subscription_id__c = subsId, Stripe_Last_Sync_Date__c = datetime.now(), npsp__Status__c='Active');
            update this.rd;
            
            Stripe_Payment_Configs__mdt metadataRecords = [SELECT Recurring_Donation_Sync_Time__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
            
            Datetime startDateTime = Datetime.now().addMinutes(Integer.valueOf(metadataRecords.Recurring_Donation_Sync_Time__c));
            String cronExp = '0 ' + startDateTime.minute() + ' ' + startDateTime.hour() + ' ' + startDateTime.day() + ' ' + startDateTime.month() + ' ? ' + startDateTime.year();
            System.schedule('Update Recurring donation payments for RD -> ' + this.rd.Id, cronExp, new StripeInvoiceSchedulable(subsId, this.rd));
        }
    }
}