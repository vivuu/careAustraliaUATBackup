/**
* Name			:		LWC_DataCleanUpScheduler
* Date			:		28/09/2023
* Author		:		Amit Goyal
* Description	:		To send the loan for manager approval if did not happen by automation
						To Release the loans from the lock in case kept in cart for long
*/
global class LWC_DataCleanUpScheduler Implements Database.Batchable<sObject>, Schedulable{
	global void execute(SchedulableContext sc)
    {
        LWC_DataCleanUpScheduler b = new LWC_DataCleanUpScheduler();
        database.executebatch(b, 100);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime dt = System.NOW().addMinutes(-60);
        String query = 'Select Id, Name, Expired__c, (Select Id, Name From Cart_Items__r) From Cart__c Where Last_Transaction_DateTime__c <=: dt';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Cart__c> carts) {
        SavePoint sp = Database.setSavepoint();
        System.debug('Carts---->'+carts);
        map<String, Cart_Items__c> cartItemsMap = new map<String, Cart_Items__c>();
        try {
            for(Cart__c c: carts){
                if(c.Expired__c==true){
                    if(c.Cart_Items__r != null && c.Cart_Items__r.size()>0){
                        cartItemsMap.putAll(c.Cart_Items__r);
                    }
                }
                c.Last_Transaction_DateTime__c=null;
            }
            
            list<Transaction__c> transactions = [Select Id, Name From Transaction__c Where Cart_Items__c IN: cartItemsMap.keyset() AND Added_To_Cart__c=true AND Status__c!='Completed'];
            
            update  carts;
            if(transactions != null && transactions.size()>0){
                delete transactions;
            }
            
            if(cartItemsMap != null && cartItemsMap.size()>0){
                delete cartItemsMap.values();
            }
            
            /*map<String, Cart_Items__c> recordsMap = new map<String, Cart_Items__c>([Select Id, Name From Cart_Items__c Where Cart__r.Expired__c=true]);
            system.debug('### recordsMap size: '+recordsMap.size());
            list<Transaction__c> records = [Select Id, Name From Transaction__c Where Cart_Items__c IN: recordsMap.keyset()];
            system.debug('### records size: '+records.size());
            delete recordsMap.values();*/
        } catch(Exception e) {
            system.debug('### exception: '+e+' - '+e.getStackTraceString());
            Database.rollback(sp);
            System.debug(e.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_DataCleanUpScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=e.getMessage(), 
                                                        StackTrace__c=e.getStackTraceString());
            insert err;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        map<String, Loan__c> recordsMap = new map<String, Loan__c>([SElect Id, Name From Loan__c Where Loan_Proposal_Status__C='Content Approved']);
        LoanTriggerHandler.sendLoanforManagerApproval(recordsMap.keyset());
    }
}