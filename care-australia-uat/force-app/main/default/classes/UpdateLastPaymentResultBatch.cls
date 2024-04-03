global class UpdateLastPaymentResultBatch implements Database.Batchable<sObject>,schedulable {
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, npe01__Opportunity__r.npe03__Recurring_Donation__c,npe01__Opportunity__r.npe03__Recurring_Donation__r.Last_Payment_Result__c,';
        query += 'npe01__Opportunity__r.npsp__Primary_Contact__c,npe01__Opportunity__r.npsp__Primary_Contact__r.Last_Payment_Result__c, Payment_Result__c,';
        query += ' RG_Processing_Batch__c FROM npe01__OppPayment__c where RG_Processing_Batch__r.LastModifiedDate = Today and ';
        query += ' RG_Processing_Batch__r.Batch_Status__c = \'Completed\' and npe01__Opportunity__r.npe03__Recurring_Donation__c != Null ';
        query += ' and Payment_Result__c != \'Not Processed\' and Payment_Result__c != \'Processing\'';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<npe01__OppPayment__c> scope) {
        if(scope!=null && !scope.isEmpty()) {
            Set<Id> primaryContactSuccessIdSet = new Set<Id>();
            Set<Id> rgSuccessIdSet = new Set<Id>();
            Set<Id> primaryContactFailSoftIdSet = new Set<Id>();
            Set<Id> rgFailSoftIdSet = new Set<Id>();
            Set<Id> primaryContactFailHardIdSet = new Set<Id>();
            Set<Id> rgFailHardIdSet = new Set<Id>();
            
            List<Contact> contactListToUpdate = new List<Contact>();
            List<npe03__Recurring_Donation__c> rgListToUpdate = new List<npe03__Recurring_Donation__c>();
            
            for (npe01__OppPayment__c oppPay : scope ){
                if(oppPay.Payment_Result__c == 'Success'){
                    primaryContactSuccessIdSet.add(oppPay.npe01__Opportunity__r.npsp__Primary_Contact__c);
                    rgSuccessIdSet.add(oppPay.npe01__Opportunity__r.npe03__Recurring_Donation__c);
                }else if(oppPay.Payment_Result__c == 'Fail Soft'){
                    primaryContactFailSoftIdSet.add(oppPay.npe01__Opportunity__r.npsp__Primary_Contact__c);
                    rgFailSoftIdSet.add(oppPay.npe01__Opportunity__r.npe03__Recurring_Donation__c);
                }else if(oppPay.Payment_Result__c == 'Fail Hard'){
                    primaryContactFailHardIdSet.add(oppPay.npe01__Opportunity__r.npsp__Primary_Contact__c);
                    rgFailHardIdSet.add(oppPay.npe01__Opportunity__r.npe03__Recurring_Donation__c);
                }
            }
            if( primaryContactSuccessIdSet!=null && !primaryContactSuccessIdSet.isEmpty()) {
                List<Contact> primaryContactSuccessList = [Select Id,Last_Payment_Result__c From Contact Where Id IN: primaryContactSuccessIdSet];
                for (Contact con : primaryContactSuccessList ){
                    con.Last_Payment_Result__c = 'Success';
                    contactListToUpdate.add(con);
                }
            }
            
            if( rgSuccessIdSet!=null && !rgSuccessIdSet.isEmpty()) {
                List<npe03__Recurring_Donation__c> rgSuccessList = [Select Id,Last_Payment_Result__c From npe03__Recurring_Donation__c Where Id IN: rgSuccessIdSet ];
                for (npe03__Recurring_Donation__c rg : rgSuccessList ){
                    rg.Last_Payment_Result__c = 'Success';
                    rgListToUpdate.add(rg);
                }
            }
            
            if( primaryContactFailSoftIdSet!=null && !primaryContactFailSoftIdSet.isEmpty()) {    
                List<Contact> primaryContactFailSoftList =[Select Id,Last_Payment_Result__c From Contact Where Id IN: primaryContactFailSoftIdSet ];
                for (Contact con : primaryContactFailSoftList ){
                    if(!(primaryContactSuccessIdSet.Contains(con.Id))){
                        con.Last_Payment_Result__c = 'Fail Soft';
                        contactListToUpdate.add(con);
                    }   
                }
            }
            
            if( rgFailSoftIdSet!=null && !rgFailSoftIdSet.isEmpty()) {
                List<npe03__Recurring_Donation__c> rgFailSoftList = [Select Id,Last_Payment_Result__c From npe03__Recurring_Donation__c Where Id IN: rgFailSoftIdSet ];
                for (npe03__Recurring_Donation__c rg : rgFailSoftList ){
                    if(!(rgSuccessIdSet.Contains(rg.Id))){
                        rg.Last_Payment_Result__c = 'Fail Soft';
                        rgListToUpdate.add(rg);
                    }   
                }
            }
            
            if( primaryContactFailHardIdSet!=null && !primaryContactFailHardIdSet.isEmpty()) {
                List<Contact> primaryContactFailHardList = [Select Id,Last_Payment_Result__c From Contact Where Id IN: primaryContactFailHardIdSet ];
                for (Contact con : primaryContactFailHardList ){
                    if(!(primaryContactSuccessIdSet.Contains(con.Id))  && !(primaryContactFailSoftIdSet.Contains(con.Id))){
                        con.Last_Payment_Result__c = 'Fail Hard';
                        contactListToUpdate.add(con);
                    }   
                }                
            }
            
            if( rgFailHardIdSet!=null && !rgFailHardIdSet.isEmpty()) {
                List<npe03__Recurring_Donation__c> rgFailHardList = [Select Id,Last_Payment_Result__c From npe03__Recurring_Donation__c Where Id IN: rgFailHardIdSet ];
                for (npe03__Recurring_Donation__c rg : rgFailHardList ){
                    if(!(rgSuccessIdSet.Contains(rg.Id)) && !(rgFailSoftIdSet.Contains(rg.Id))){
                        rg.Last_Payment_Result__c = 'Fail Hard';
                        rgListToUpdate.add(rg);
                    }   
                }
            }
            
            System.debug('contactListToUpdate****'+contactListToUpdate.size());
            System.debug('rgListToUpdate****'+rgListToUpdate.size());
            
            if( contactListToUpdate!=null && !contactListToUpdate.isEmpty()) {
                database.update(contactListToUpdate);
            }
            if( rgListToUpdate!=null && !rgListToUpdate.isEmpty()) {
                database.update(rgListToUpdate);
            }
            
            
            
        }
        
    }
    global void finish(Database.BatchableContext bc) {
        // finish code
        System.debug('Finished');
    }
    global void execute(SchedulableContext sc) {
        database.executebatch(new UpdateLastPaymentResultBatch(),50);
    }
}