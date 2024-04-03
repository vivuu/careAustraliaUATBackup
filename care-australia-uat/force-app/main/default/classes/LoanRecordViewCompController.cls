public with sharing class LoanRecordViewCompController {
    @AuraEnabled(cacheable=true)
    public static List<Repayment_Schedule__c> getRelatedRepaymentSchedules(Id recordId) {
        if(recordId != null){
            return [SELECT Id,Name,Loan__c,Loan_Repayment_Number__c,Amount_Due__c,Due_Date__c,Status__c,
                    Principal_Repaid__c,Repayment_Date__c
                    FROM Repayment_Schedule__c
                    WHERE Loan__c =: recordId 
                    Order By Loan_Repayment_Number__c];
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Loan__c getLoanDetails(Id recordId) {
        if(recordId != null){
            return [SELECT Id,Name,Loan_Proposal_Status__c,RecordType.Name
                    FROM Loan__c
                    WHERE Id =: recordId LIMIT 1];
        }
        return null;
    }
}