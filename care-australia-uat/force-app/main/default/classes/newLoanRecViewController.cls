public class newLoanRecViewController {
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeId(String LoanId) 
    {
        Loan__c l=[SELECT Id,RecordTypeId FROM Loan__c WHERE Id= :LoanId LIMIT 1];
        System.debug('RecordType Id-->'+l.RecordTypeId);
        return l.RecordTypeId;
    }
}