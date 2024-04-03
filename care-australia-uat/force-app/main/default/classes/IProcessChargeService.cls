public Interface IProcessChargeService {
    void createOpportunityAndUpdatePaymentFromCharge(Map<String, Charge__c> chargeMap, Set<String> customerIds, Map<String, String> declineCodeMap);
    void updateOpportunityAndPaymentFromCharge(Map<String, Charge__c> invoiceChargeMap, Map<String, String> declineCodeMap);
    void updateProcessedCharges(List<Charge__c> processedCharges);
}