global class accountBeforeUpdate_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            Account acc;
            Map<Id,DateTime> conOldReceivedDateMap = new Map<Id,DateTime>();
            Map<Id,String> conOldCityDateMap = new Map<Id,String>();
            Map<Id,String> conOldStreetDateMap = new Map<Id,String>();
            Map<Id,String> conOldStateDateMap = new Map<Id,String>();
            Map<Id,String> conOldPinCodeDateMap = new Map<Id,String>();
            Map<Id,String> conOldCountryDateMap = new Map<Id,String>();
            
            for (SObject obj : newlist) {
                acc = (Account)obj;
                
                //contactObj = (Contact)c;
                if(acc.RTS_Received_Date__c != null && conOldReceivedDateMap.get(acc.Id) != acc.RTS_Received_Date__c){
                    if(acc.RTS_Count__c == null){
                        acc.RTS_Count__c = 0;
                        acc.RTS_Count__c = acc.RTS_Count__c + 1;
                    }else{
                        acc.RTS_Count__c = acc.RTS_Count__c + 1;
                    }
                    if(acc.RTS_Count__c >= 3 && acc.Invalid_Address__c == false){
                        acc.Invalid_Address__c = true;
                    }                    
                }
                if(conOldCityDateMap.get(acc.Id) != acc.ShippingCity || conOldStreetDateMap.get(acc.Id) != acc.ShippingStreet
                   || conOldStateDateMap.get(acc.Id) != acc.ShippingState || conOldPinCodeDateMap.get(acc.Id) != acc.ShippingPostalCode
                   || conOldCountryDateMap.get(acc.Id) != acc.ShippingCountry){
                       acc.Invalid_Address__c = false;
                       acc.RTS_Count__c = 0;
                   }
                
                if(acc.Do_Not_Contact__c == true){
                    acc.Email_Donor_Updates_Opt_Out__c = true;
                    acc.DM_Donor_Updates_Opt_Out__c = true;
                    acc.Email_Feb_Appeal_Opt_Out__c = true;
                    acc.DM_Feb_Appeal_Opt_Out__c = true;
                    acc.Email_Sept_Appeal_Opt_Out__c = true;
                    acc.DM_Sept_Appeal_Opt_Out__c = true;
                    acc.Email_Tax_Appeal_Opt_Out__c = true;
                    acc.DM_Tax_Appeal_Opt_Out__c = true;
                    acc.Email_Xmas_Appeal_Opt_Out__c = true;
                    acc.DM_Xmas_Appeal_Opt_Out__c = true;
                    acc.Email_Follow_up_appeals_Opt_Out__c = true;
                    acc.DM_Follow_up_appeals_Opt_Out__c = true;
                    acc.Email_CAREgifts_Opt_Out__c = true;
                    acc.DM_CAREgifts_Opt_Out__c = true;
                    acc.Email_Emergencies_Opt_Out__c = true;
                    acc.DM_Emergencies_Opt_Out__c = true;
                    acc.Do_Not_Call__c = true;
                    acc.Do_Not_Email__c = true;
                    acc.Do_Not_Mail__c = true;
                    acc.Do_Not_SMS__c = true;
                    acc.Survey_Opt_Out__c = true;
                    acc.Email_All_Solicitations_Opt_Out__c = true;
                    acc.Bequest_Opt_Out__c = true;
                    acc.DM_All_Solicitations_Opt_Out__c = true;
                    
                    
                }
            }
            
        }
        return dmlWrapper;
    }
}