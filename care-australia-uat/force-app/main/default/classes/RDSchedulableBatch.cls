/**
* @class             : RDSchedulableBatch
* @description       : Auto cancelling RD when Failed Consecutive Opportunities >=3 and 'On Held Date' is older than 180 days.
*                      Auto Upgrade RD when Auto 'Upgrade Percentage' > 0.
* @created on        : 08-25-2021
* @group             : 
* @last modified on  : 08-30-2021
**/
global class RDSchedulableBatch implements Database.Batchable<sObject>, schedulable {
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,npe03__Amount__c,npe03__Date_Established__c, Auto_Upgrade_Amount__c, Cancellation_Date__c,';
        query+='npsp__Status__c,npsp__ClosedReason__c,Failed_Consecutive_Opportunities__c,On_Held_Limit__c ';
        query+='FROM npe03__Recurring_Donation__c Where npsp__Status__c != \'Cancelled\'';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<npe03__Recurring_Donation__c> scope) {
        if(scope!=null && !scope.isEmpty()) {
            
            DateTime dT = System.now();
            Date todaysDate = date.newinstance(dT.year(), dT.month(), dT.day());
            Decimal upgradeAmount = 0;
            
            List<npe03__Recurring_Donation__c> listRDsToUpdate = new List<npe03__Recurring_Donation__c>();
            
            for(npe03__Recurring_Donation__c rd : scope){
                //7
                if(rd.npsp__Status__c == 'Held' && rd.On_Held_Limit__c < todaysDate){
                    rd.npsp__Status__c = 'Cancelled';
                    rd.npsp__ClosedReason__c = 'Terminated from Held';
                    rd.Cancellation_Date__c = todaysDate;
                    listRDsToUpdate.add(rd);
                }
                //7
                /* if(rd.Failed_Consecutive_Opportunities__c >=3 && rd.npsp__Status__c != 'Cancelled'){
rd.npsp__Status__c = 'Cancelled';
rd.npsp__ClosedReason__c = 'Multi rejections';
rd.Cancellation_Date__c = todaysDate;
listRDsToUpdate.add(rd);
}*/
                //10
                if(rd.Auto_Upgrade_Amount__c > 0 && rd.npsp__Status__c == 'Active' 
                   && rd.npe03__Date_Established__c.month() == todaysDate.month() 
                   && rd.npe03__Date_Established__c.day() == todaysDate.day() 
                   && rd.npe03__Date_Established__c.year() != todaysDate.year()){
                    rd.npe03__Amount__c += rd.Auto_Upgrade_Amount__c;
                    listRDsToUpdate.add(rd);
                }  
            }
            system.debug('listRDsToUpdate'+listRDsToUpdate);
            try{
                if(listRDsToUpdate!=null && !listRDsToUpdate.isEmpty()) {
                    update listRDsToUpdate;  
                }		
            }Catch(exception e){
                system.debug('Exception:'+e.getmessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // finish code
        System.debug('Finished');
    }
     global void execute(SchedulableContext sc) {
        database.executebatch(new RDSchedulableBatch());
    }
    
}