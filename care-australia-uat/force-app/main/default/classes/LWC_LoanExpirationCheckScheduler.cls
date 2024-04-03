/**
* Name			:		LWC_LoanExpirationCheckScheduler
* Date			:		15/07/2023
* Author		:		Amit Goyal
* Description	:		
*/
global class LWC_LoanExpirationCheckScheduler Implements Database.Batchable<sObject>, Schedulable{
	global void execute(SchedulableContext sc)
    {
        LWC_LoanExpirationCheckScheduler b = new LWC_LoanExpirationCheckScheduler();
        database.executebatch(b, 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date dt = System.Today();
        String query = 'Select Id, Name, (Select Id, Name, Type__c, Transaction_Date__c, Status__c, Lender__c, Amount__c From Transactions__r Where Status__c=\'Completed\') From Loan__c Where Expected_Funded_Date__c <=: dt';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Loan__c> loans) {
        SavePoint sp = Database.setSavepoint();
        try {
            map<String, Loan__c> loansMap = new map<String, Loan__c>(loans);
            list<Transaction__c> repaymentTransactions = new list<Transaction__c>();
            for(Loan__c l: loans){
                system.debug('### Loan Name: '+l.Name);
                l.Stage__c='Expired';
                l.Expired_Date__c=System.Today();
                if(l.Transactions__r != null && l.Transactions__r.size()>0){
                    for(Transaction__c trans: l.Transactions__r){
                        if(trans.Type__c=='Loan'){
                            //Create a new reverse transaction for repayment.
                            repaymentTransactions.add(new Transaction__c(Loan__c=l.Id, Lender__c=trans.Lender__c, 
                                                                         Transaction_Date__c=System.Today(), Amount__c=trans.Amount__c, 
                                                                         Type__c='Expired Loan', Status__c='Held', CurrencyIsoCode='AUD'));
                        }
                        
                        if(trans.Type__c=='Voucher'){
                            // Generate a voucher and send to the lender
                        }
                    }
                }
            }
            
            update loans;
            
            if(repaymentTransactions != null && repaymentTransactions.size()>0){
                insert repaymentTransactions;
            }
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_CalculateFSPBalance_8EMScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=e.getMessage(), 
                                                        StackTrace__c=e.getStackTraceString());
            insert err;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}