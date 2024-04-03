global class ContactBeforeInsert_TDTM extends npsp.TDTM_Runnable {
 global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert){
            
            Contact contactObj;
            for(SObject c : newlist){
                contactObj = (Contact)c;
                if(contactObj.HIC_ShopifySync__Shopify_Id__c != null){
                    if(contactObj.Shopify_Phone_Number__c != null){
                        string phoneNumber = contactObj.Shopify_Phone_Number__c;
                        string checkPhonestartletter = phoneNumber.substring(0, 2);
                        if(checkPhonestartletter == '04')
                        {
                            contactObj.MobilePhone = contactObj.Shopify_Phone_Number__c.replaceFirst('0','+61');                            
                        }
                        else
                        {
                            if(checkPhonestartletter == '0')
                            {
                                 contactObj.HomePhone = contactObj.Shopify_Phone_Number__c.replaceFirst('0','+61');
                            }
                            else
                            {
                                 contactObj.HomePhone = contactObj.Shopify_Phone_Number__c;
                                 contactObj.MobilePhone = '';
                            }
                           
                        }

                    }
                                     
                }

               
            }
        }
        return dmlWrapper;
    }
}