global class UpdateContactRGCount implements Database.Batchable<sObject> {
    String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,RG_Count__c,Total_RG_Gifts__c,Total_RG_Gifts_Two_Years_Ago_FY__c,Total_RG_Gifts_This_year_FY__c,Total_RG_Gifts_Last_year_FY__c from Contact ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        
        if(scope!=null && !scope.isEmpty()) {
            system.debug('scope@@@@@@'+scope);
            Map<Id, AggregateResult> contactAgg = new Map<Id, AggregateResult>(
                [SELECT COUNT(Id) countCon,Sum(npe03__Paid_Amount__c) totalRG, npe03__Contact__c Id FROM npe03__Recurring_Donation__c 
                 where npsp__Status__c ='Active' and npe03__Contact__c IN: scope GROUP BY npe03__Contact__c ]
            );
            system.debug('contactAgg@@@@@@'+contactAgg);
           /* Map<Id, AggregateResult> contactAggThisFY = new Map<Id, AggregateResult>(
                [SELECT Sum(Amount) RGThisFY,npsp__Primary_Contact__c Id  FROM Opportunity 
                 where CloseDate  = THIS_FISCAL_YEAR and StageName='Closed Won' and npe03__Recurring_Donation__r.npsp__Status__c ='Active' and 
                 npsp__Primary_Contact__c in:scope GROUP BY npsp__Primary_Contact__c]
            );*/
            Map<Id, AggregateResult> contactAggThisFY = new Map<Id, AggregateResult>();
            for(AggregateResult aggResult:[SELECT Sum(Amount) RGThisFY,npsp__Primary_Contact__c Id  FROM Opportunity 
                 where CloseDate  = THIS_FISCAL_YEAR and StageName='Closed Won' and npe03__Recurring_Donation__r.npsp__Status__c ='Active' and 
                 npsp__Primary_Contact__c in:scope and npsp__Primary_Contact__c!=null GROUP BY npsp__Primary_Contact__c]){
 					String conId = String.valueOf(aggResult.get('Id'));
                     contactAggThisFY.put(conId,aggResult);
          
 //do you logic here
}
            system.debug('contactAggThisFY@@@@@@'+contactAggThisFY);
            /*Map<Id, AggregateResult> contactAggLastFY = new Map<Id, AggregateResult>(
                [SELECT Sum(Amount) RGLastFY,npsp__Primary_Contact__c Id  FROM Opportunity 
                 where CloseDate  = LAST_FISCAL_YEAR and StageName='Closed Won' and npe03__Recurring_Donation__r.npsp__Status__c ='Active' and 
                 npsp__Primary_Contact__c in:scope GROUP BY npsp__Primary_Contact__c]
            );*/
             Map<Id, AggregateResult> contactAggLastFY = new Map<Id, AggregateResult>();
            for(AggregateResult aggResult:[SELECT Sum(Amount) RGLastFY,npsp__Primary_Contact__c Id  FROM Opportunity 
                 where CloseDate  = LAST_FISCAL_YEAR and StageName='Closed Won' and npe03__Recurring_Donation__r.npsp__Status__c ='Active' and 
                 npsp__Primary_Contact__c in:scope and npsp__Primary_Contact__c!=null GROUP BY npsp__Primary_Contact__c]){
 					String conId = String.valueOf(aggResult.get('Id'));
                     contactAggLastFY.put(conId,aggResult);
          
 //do you logic here
}
            
             //system.debug('contactAggLastFY@@@@@@'+contactAgg);
             
             system.debug('contactAggLastFY@@@@@@'+contactAggLastFY);
            for(Contact con: scope) {
                con.RG_Count__c = contactAgg.containsKey(con.Id)?(Decimal)contactAgg.get(con.Id).get('countCon'):0;
                con.Total_RG_Gifts__c = contactAgg.containsKey(con.Id)?(Decimal)contactAgg.get(con.Id).get('totalRG'):0;
                con.Total_RG_Gifts_This_year_FY__c = contactAggThisFY.containsKey(con.Id)?(Decimal)contactAggThisFY.get(con.Id).get('RGThisFY'):0; 
                con.Total_RG_Gifts_Last_year_FY__c = contactAggLastFY.containsKey(con.Id)?(Decimal)contactAggLastFY.get(con.Id).get('RGLastFY'):0;
              /*System.debug('con.Total_RG_Gifts_Two_Years_Ago_FY__c>>>>>>'+con.Total_RG_Gifts_Two_Years_Ago_FY__c);
                System.debug('con.Total_RG_Gifts__c>>>>>>'+con.Total_RG_Gifts__c);
                System.debug('con.Total_RG_Gifts_This_year_FY__c>>>>>>'+con.Total_RG_Gifts_This_year_FY__c);
                System.debug('con.Total_RG_Gifts_Last_year_FY__c>>>>>>'+con.Total_RG_Gifts_Last_year_FY__c);*/
                if(con?.Total_RG_Gifts_Two_Years_Ago_FY__c!=null && con?.Total_RG_Gifts__c!=null)
                con.Total_RG_Gifts_Two_Years_Ago_FY__c = con.Total_RG_Gifts__c - (con.Total_RG_Gifts_This_year_FY__c + con.Total_RG_Gifts_Last_year_FY__c);
            }
            update scope;
        }
    }
    global void finish(Database.BatchableContext bc) {
        // finish code
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }
}