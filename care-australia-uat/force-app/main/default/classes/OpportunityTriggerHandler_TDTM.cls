global class OpportunityTriggerHandler_TDTM extends npsp.TDTM_RunnableMutable  {
    global override void run(List<SObject> listNew, List<SObject> listOld,
                             npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
                             npsp.TDTM_Runnable.DmlWrapper dmlWrapper) 
    {
        // cast new contacts
        List<Opportunity> newRecords = (List<Opportunity>) listNew;
        System.debug(listNew.size());
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert||triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            // create collection to hold Account IDs
            Set<Id> accountIds = new Set<Id>();
            Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
            //To get Default Campaign Name from Custom Label 
            String Campaign_Name = System.Label.Shopify_Default_Campaign_Name;
            Campaign campCatalogue = [Select Id from Campaign where Name= :Campaign_Name LIMIT 1];
            if(campCatalogue != null){
                // iterate over new records to collect Account IDs
                for(Opportunity newRecord : newRecords) {
                    system.debug('oppContactsId##### ::::'+newRecord.ContactId );
                    if(newRecord.RecordTypeId==Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('CARE Gift').getRecordTypeId()){
                        System.debug('+++'+newRecord.RecordTypeId);
                        if(newRecord.CampaignId==null)
                        {
                            newRecord.CampaignId = campCatalogue.Id;
                        }
                        
                        System.debug('newRecord.HIC_ShopifySync__Payment_Status__c+++'+newRecord.HIC_ShopifySync__Payment_Status__c);
                        if (newRecord.HIC_ShopifySync__Payment_Status__c=='Paid')
                        {
                            newRecord.StageName='Closed Won';
                            newRecord.Donation_Source__c = 'Shopify';
                            if(newRecord.Shopify_Shipping_Details__c !=null)
                            {
 
                                String Shopify_Shipping_Details = newRecord.Shopify_Shipping_Details__c;
                                List<String> strList = Shopify_Shipping_Details.split(',');
                                for (String str : strList)
                                {
                                    if(str.contains('code='))
                                    {
                                        String[] strArray = str.split('=');
                                        string shipping_code = strArray[0].trim();
                                         system.debug('shipping_code:'+ shipping_code);
                                        if(shipping_code.equals('code'))
                                        {
                                            if(strArray[1].trim()!=null)
                                            {
                                                newRecord.Shipping_Cost_Accepted__c = True;
                                                newRecord.Shopify_Shipping_Code__c = strArray[1].trim();
                                            }
                                                
                                        }
                                        	
                                    }  
                                    if(str.contains('price='))
                                    {
                                        String[] strPriceArray = str.split('=');
                                        string shipping_price = strPriceArray[0].trim();
                                        if(shipping_price.equals('price'))
                                        {
                                            if(strPriceArray[1].trim()!=null)
                                            {
                                                newRecord.Shipping_Cost__c = Decimal.valueOf(strPriceArray[1].trim());
                                            }
                                           
                                                
                                        }
                                        	
                                    }
                                }

                            }
                           
                        }
                            
                        if(newRecord.AccountId!=null){
                            system.debug('AccountId ::::'+newRecord.AccountId);
                            List<Opportunity> opplst = oppMap.get(newRecord.AccountId);
                            system.debug('opplst ::::'+opplst);
                            if(opplst == null)
                                opplst = new List<Opportunity>();
                            opplst.add(newRecord);
                            oppMap.put(newRecord.AccountId,opplst);
                            accountIds.add(newRecord.AccountId);
                            system.debug('AccountIdSet ::::'+accountIds);
                            system.debug('oppMap##### ::::'+oppMap);
                            
                        }
                    }            
                }
                
                
                // retrieve those accounts
                
                if(accountIds != null){
                    //Map<Id, Contact> contMap = getContacts(accountIds);
                    Map<Id, Contact> contMap = new Map<Id, Contact>(); 
                    for(Contact con:[SELECT Id,AccountId FROM Contact WHERE AccountId IN :accountIds]){
                        If(con.AccountId!=null){
                            contMap.put(con.AccountId, con);
                        }
                    }
                    system.debug('contMap ::::'+contMap);
                    for(Id acc:accountIds){
                        for(Opportunity op:oppMap.get(acc)){
                            If((contMap.get(acc))!=null) {
                                if(op.npsp__Primary_Contact__c == null){
                                    op.npsp__Primary_Contact__c = (contMap.get(acc)).Id;
                                }
                                
                                
                            }
                            System.debug('***'+op.npsp__Primary_Contact__c);
                        }
                        system.debug('oppMap.get(acc) ::::'+oppMap.get(acc))  ;
                    }  
                    
                }
            }
            
        }
    }
}