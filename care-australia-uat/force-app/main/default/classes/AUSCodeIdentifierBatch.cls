global class AUSCodeIdentifierBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query ='SELECT Id, npsp__Primary_Contact__c FROM Opportunity where npsp__Primary_Contact__c !=null';
        //String query = 'SELECT npe01__Opportunity__r.npsp__Primary_Contact__c,AUS_CODE__c FROM npe01__OppPayment__c where npe01__Opportunity__r.npsp__Primary_Contact__c!=null and AUS_Code__c!= null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> allOppLst) {
        Set<Id> allPRContacts= new Set<ID>();
        Opportunity newOpp = new Opportunity();
        
        for(Opportunity eachOpp:allOppLst)
        {            
            allPRContacts.add(eachOpp.npsp__Primary_Contact__c);
        }
        List<npe01__OppPayment__c> allPayAUSLst= [SELECT npe01__Opportunity__r.npsp__Primary_Contact__c,AUS_CODE__c FROM npe01__OppPayment__c where npe01__Opportunity__r.npsp__Primary_Contact__c IN :allPRContacts and AUS_Code__c!= null];

        Set<Id> onlyPay779AUS = new Set<Id>();
        List<Id> allPay779AUS = new List<Id>();
        List<Id> allNonPay779AUS = new List<Id>();
        // process each batch of records default size is 200
        for(npe01__OppPayment__c eachRec : allPayAUSLst) {        
            if(eachRec.AUS_CODE__c!='AUS779')//if a payment's auscode not 779 add contact Id
                allNonPay779AUS.add(eachRec.npe01__Opportunity__r.npsp__Primary_Contact__c);
            else
                allPay779AUS.add(eachRec.npe01__Opportunity__r.npsp__Primary_Contact__c);
        }
        
        for(Id eachId:allPay779AUS)
        {
            System.debug(allNonPay779AUS.contains(eachId)+'>>>>>>>>>>>>>>>'+eachId);
            if(!allNonPay779AUS.contains(eachId))
            {
                onlyPay779AUS.add(eachId); 
            }
            
        }
        try {
            List<Contact> conToUpLst = new List<Contact>();
            
            System.debug('Only 797 Records>>>>'+onlyPay779AUS.size());
            for(Id eachConId:onlyPay779AUS )
            {
                Contact conToUpdate = new Contact();
                conToUpdate.Id=eachConId;
                conToUpdate.Emergency_Care_Gift__c=true;
                conToUpLst.add(conToUpdate);
            }
            if(conToUpLst.size()>0)
            UPDATE conToUpLst;
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}