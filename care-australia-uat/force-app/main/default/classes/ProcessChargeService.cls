public class ProcessChargeService implements IProcessChargeService {
    private static IProcessChargeService service() {
        ProcessChargeServiceImpl processChargeServiceImpl = new ProcessChargeServiceImpl();
        return (IProcessChargeService) processChargeServiceImpl;
    }
    
    //New Opportunity is created in case when payment is a One Off type
    //That means a single time donation has been made on stripe
    //Payment is always created when we create a opportunity on salesforce system
    //We will update the payment linked on this opportunity
    //One opportunity has only one payment
    public static void createOpportunityAndUpdatePaymentFromCharge(Map<String, Charge__c> chargeMap, Set<String> customerIds, Map<String, String> declineCodeMap) {
        service().createOpportunityAndUpdatePaymentFromCharge(chargeMap, customerIds, declineCodeMap);
    }
    
    //Existing Opportunity and Payment will update when a recurring payment has been made
    //That means a subscription type donation has been made on stripe
    //Opportunity always exists when it is a Recurring Donation and it will also have a payment
    //One opportunity has only one payment
    //We will first update the Payment then Opportunity
    public static void updateOpportunityAndPaymentFromCharge(Map<String, Charge__c> invoiceChargeMap, Map<String, String> declineCodeMap) {
        service().updateOpportunityAndPaymentFromCharge(invoiceChargeMap, declineCodeMap);
    }
    
    public static void updateProcessedCharges(List<Charge__c> processedCharges) {
        service().updateProcessedCharges(processedCharges);
    }
}