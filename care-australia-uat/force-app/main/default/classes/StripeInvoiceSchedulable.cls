public class StripeInvoiceSchedulable implements Schedulable {
    String subsId;
    npe03__Recurring_Donation__c rd;
    
    public StripeInvoiceSchedulable(String subsId, npe03__Recurring_Donation__c rd) {
        this.subsId = subsId;
        this.rd = rd;
    }
    
    public void execute(SchedulableContext context) {
        StripeInvoiceQueueable queueable = new StripeInvoiceQueueable(this.subsId, this.rd.Id);
        System.enqueueJob(queueable);
    }
}