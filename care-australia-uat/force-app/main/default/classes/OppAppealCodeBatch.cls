global class OppAppealCodeBatch implements Database.Batchable <sObject>
{
	global Database.QueryLocator start(Database.BatchableContext bc) 
	{
       
        // collect the batches of records or objects to be passed to execute
    return Database.getQueryLocator([select	Id,Donation_URL__c,Campaign_code_lookup__c,Primary_Campaign_Code__c from Opportunity where Donation_Source__c='Web' and Donation_URL__c!=null
                                    and CreatedDate >= 2023-01-01T00:00:00.000+0000]);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> records)
    {
        
        // process each batch of records
        List<opportunity> UpdateList=new List<Opportunity>();
       
        for(Opportunity opp: records)
        {
            if(opp.Donation_URL__c.contains('appealcode') && String.isNotEmpty(opp.Donation_URL__c.substringAfterLast('=')))
            {
                
                String appealcode = (opp.Donation_URL__c.substringAfterLast('='));
            
            if(!appealcode.equalsIgnoreCase(opp.Primary_Campaign_Code__c))
            {
            
            for(Campaign camp:[select Id,Campaign_Code__c from Campaign where Campaign_Code__c =:appealcode and IsActive = True LIMIT 1])
            {
            opp.Campaign_code_lookup__c=camp.Id;
                opp.CampaignId = camp.Id;
            
            UpdateList.add(opp);
            }
            }
            }
        }
      
        if(UpdateList.size()>0)
        Database.update(UpdateList,true) ;
    }
    
   global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}