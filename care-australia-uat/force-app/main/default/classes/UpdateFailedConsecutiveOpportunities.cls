public class UpdateFailedConsecutiveOpportunities implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        //String query = 'SELECT Id, Failed_Consecutive_Opportunities__c, npsp__Status__c, (SELECT Id, Name, LastModifiedDate, StageName FROM npe03__Donations__r ORDER BY LastModifiedDate DESC LIMIT 4) FROM npe03__Recurring_Donation__c WHERE npsp__Status__c IN (\'Active\', \'Held\')';
        
        String query = 'SELECT Id, Test_Failed_Consecutive_Opportunities__c, npsp__Status__c, (SELECT Id, Name, LastModifiedDate, StageName FROM npe03__Donations__r ORDER BY createddate DESC LIMIT 4) FROM npe03__Recurring_Donation__c WHERE npsp__Status__c IN (\'Active\', \'Held\')';
        
      // String query = 'SELECT Id, Test_Failed_Consecutive_Opportunities__c, npsp__Status__c, (SELECT Id, Name, LastModifiedDate, StageName FROM npe03__Donations__r ORDER BY createddate DESC LIMIT 4) FROM npe03__Recurring_Donation__c WHERE id IN (\'a099D00000N9LewQAF\')';
        
        //Test_Failed_Consecutive_Opportunities
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        List<npe03__Recurring_Donation__c> lstRDToUpdate = new List<npe03__Recurring_Donation__c>();
        
        for (npe03__Recurring_Donation__c eachRD : (List<npe03__Recurring_Donation__c>) scope) {
            System.debug('Recurring Donations>>>>>>'+scope);
            if (eachRD.npe03__Donations__r.size() == 4 &&
                eachRD.npe03__Donations__r[1].StageName == 'Closed Lost' &&
                eachRD.npe03__Donations__r[2].StageName == 'Closed Lost' &&
                eachRD.npe03__Donations__r[3].StageName == 'Closed Lost') {
                    system.debug('true::::');
                npe03__Recurring_Donation__c newRD = new npe03__Recurring_Donation__c(
                    Id = eachRD.Id,
                    //Failed_Consecutive_Opportunities__c = 3,
                    Test_Failed_Consecutive_Opportunities__c=3
                );
                lstRDToUpdate.add(newRD);
            }
        }
        
        update lstRDToUpdate;
        system.debug('lstRDToUpdate:::'+lstRDToUpdate);
    }
    
    public void finish(Database.BatchableContext context) {
        // Optional post-processing logic
    }
}