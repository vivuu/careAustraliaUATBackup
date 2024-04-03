public class LWC_RepaymentScheduleTableFlowAction{

    // Delete Repayment Schedule
    @AuraEnabled
    public static void deleterecords (String loanid ){
        System.debug(' loanid'+loanid);
        
        if( loanid != null && loanid.trim().length()>0 ){
            List<Repayment_Schedule__c> repaymentsTodelete = [SELECT Id, Name FROM Repayment_Schedule__c 
                                                                WHERE Loan__c =:loanid];

            if(repaymentsTodelete != null && repaymentsTodelete.size()>0){
                delete repaymentsTodelete;
            }                                                     
        }
    }

    // Create Repayment Schedule
    @AuraEnabled
    public static List<Repayment_Schedule__c> createrecords (String loanid, Integer loanterms, List<Repayment_Schedule__c> repayments){
        if(loanid != null && loanid.trim().length()>0){
                Loan__c loanRec = [ Select Id, Name, CurrencyIsoCode, Loan_Principal_Disbursed__c 
                                    From Loan__c 
                                    Where Id =: loanid];
            
            if(repayments != null && repayments.size()>0){
                if(loanterms == repayments.size()){
                    Decimal sumOfRepayment=0;
                    for(Repayment_Schedule__c re : repayments){
                        re.Loan__c = loanid;
                        re.CurrencyIsoCode = loanRec.CurrencyIsoCode;
                        re.Amount_Due__c = re.Amount_Due__c;
                        sumOfRepayment+=re.Amount_Due__c;
                        System.debug('@@@ repay Amount due after assignment '+ re.Amount_Due__c);
                        re.Due_Date__c = re.Due_Date__c;
                    }
                    if(loanRec.Loan_Principal_Disbursed__c!=sumOfRepayment){
                        System.debug('@@@ amount are not equal...');
                    }
                    insert repayments;
                    return repayments;
                }else{
                    // throw error
                    System.debug('@@@ loan term is not matching...');
                }
            }
        }
        return null;
    }

    // Get Repayment Schedule
     @AuraEnabled (cacheable= true)
    public static List<Repayment_Schedule__c> getrepayment(String recordID){
        List<Repayment_Schedule__c> repaymentlist= [ SELECT Id, Amount_Due__c, Due_Date__c,Loan__c,Loan_Repayment_Number__c 
                                                     FROM Repayment_Schedule__c
                                                     WHERE Loan__c =: recordID ORDER BY Due_Date__c ASC];
        return repaymentlist;
    }
    
    // Upsert Repayment Schedule
    @AuraEnabled (cacheable= false)
    public static List<Repayment_Schedule__c> updaterecords (String loanid, Integer loanterms, List<Repayment_Schedule__c> repayments){
        List<Repayment_Schedule__c> updatedRepayments = new List<Repayment_Schedule__c>();
       
        System.debug('Upsertrecords loanid'+loanid);
        System.debug('Upsertrecords loanterms'+loanterms);
        System.debug('Upsertrecords repayments'+repayments);
        
        if(loanid != null && loanid.trim().length()>0){
            List<Repayment_Schedule__c> existingRepayments = [ SELECT Id, Amount_Due__c, Due_Date__c,Loan__c,Loan_Repayment_Number__c
                                                               FROM Repayment_Schedule__c
                                                               WHERE Loan__c =: loanid ];
            system.debug('@@@ Existing Repayments : '+ existingRepayments);
            
            Loan__c loanrecord = [ Select Id, Name, CurrencyIsoCode, Loan_Principal_Disbursed__c 
                                   From Loan__c 
                                   Where Id =: loanid];
            
            if(repayments != null && repayments.size()>0){
                for(Repayment_Schedule__c repayment  : repayments){
                    Repayment_Schedule__c res = new Repayment_Schedule__c( Id=repayment.Id,
                                                                           Loan_Repayment_Number__c=repayment.Loan_Repayment_Number__c,
                                                                           Loan__c = loanid,
                                                                           CurrencyIsoCode = loanrecord.CurrencyIsoCode,
                                                                           Amount_Due__c=repayment.Amount_Due__c,
                                                                           Due_Date__c=repayment.Due_Date__c);
                            updatedRepayments.add(res);    
                }
                
                if(updatedRepayments != null && updatedRepayments.size()>0 ){
                    upsert updatedRepayments;
                }
                
            }
            return updatedRepayments;
        }
        return null;
    }
}