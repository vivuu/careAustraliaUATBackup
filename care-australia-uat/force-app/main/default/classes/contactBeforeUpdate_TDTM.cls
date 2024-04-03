global class contactBeforeUpdate_TDTM extends npsp.TDTM_Runnable {
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate){
            
            Map<Id,DateTime> conOldReceivedDateMap = new Map<Id,DateTime>();
            Map<Id,String> conOldCityDateMap = new Map<Id,String>();
            Map<Id,String> conOldStreetDateMap = new Map<Id,String>();
            Map<Id,String> conOldStateDateMap = new Map<Id,String>();
            Map<Id,String> conOldPinCodeDateMap = new Map<Id,String>();
            Map<Id,String> conOldCountryDateMap = new Map<Id,String>();
            Contact contactObj;
            
            for(SObject cOld : oldlist){
                contactObj = (Contact)cOld;
                conOldReceivedDateMap.put(contactObj.Id,contactObj.RTS_Received_Date__c);
                conOldCityDateMap.put(contactObj.Id,contactObj.MailingCity);
                conOldStreetDateMap.put(contactObj.Id,contactObj.MailingStreet);
                conOldStateDateMap.put(contactObj.Id,contactObj.MailingState);
                conOldPinCodeDateMap.put(contactObj.Id,contactObj.MailingPostalCode);
                conOldCountryDateMap.put(contactObj.Id,contactObj.MailingCountry);
            }
            for(SObject c : newlist){
                contactObj = (Contact)c;
                if(contactObj.RTS_Received_Date__c != null && conOldReceivedDateMap.get(contactObj.Id) != contactObj.RTS_Received_Date__c){
                    if(contactObj.RTS_Count__c == null){
                        contactObj.RTS_Count__c = 0;
                        contactObj.RTS_Count__c = contactObj.RTS_Count__c + 1;
                    }else{
                        contactObj.RTS_Count__c = contactObj.RTS_Count__c + 1;
                    }
                    if(contactObj.RTS_Count__c >= 3 && contactObj.Invalid_Address__c == false){
                        contactObj.Invalid_Address__c = true;
                    }                    
                }
                if(conOldCityDateMap.get(contactObj.Id) != contactObj.MailingCity || conOldStreetDateMap.get(contactObj.Id) != contactObj.MailingStreet
                  || conOldStateDateMap.get(contactObj.Id) != contactObj.MailingState || conOldPinCodeDateMap.get(contactObj.Id) != contactObj.MailingPostalCode
                  || conOldCountryDateMap.get(contactObj.Id) != contactObj.MailingCountry){
                    contactObj.Invalid_Address__c = false;
                    contactObj.RTS_Count__c = 0;
                }
                if(contactObj.npsp__Do_Not_Contact__c == true){
                    contactObj.Bequest_Opt_Out__c = true;
                    contactObj.Email_Donor_Updates_Opt_Out__c = true;
                    contactObj.DM_Donor_Updates_Opt_Out__c = true;
                    contactObj.Email_Feb_Appeal_Opt_Out__c = true;
                    contactObj.DM_Feb_Appeal_Opt_Out__c = true;
                    contactObj.Email_Sept_Appeal_Opt_Out__c = true;
                    contactObj.DM_Sept_Appeal_Opt_Out__c = true;
                    contactObj.Email_Tax_Appeal_Opt_Out__c = true;
                    contactObj.DM_Tax_Appeal_Opt_Out__c = true;
                    contactObj.Email_Xmas_Appeal_Opt_Out__c = true;
                    contactObj.DM_Xmas_Appeal_Opt_Out__c = true;
                    contactObj.Email_Follow_up_appeals_Opt_Out__c = true;
                    contactObj.DM_Follow_up_appeals_Opt_Out__c = true;
                    contactObj.Email_CAREgifts_Opt_Out__c = true;
                    contactObj.DM_CAREgifts_Opt_Out__c = true;
                    contactObj.Email_Emergencies_Opt_Out__c = true;
                    contactObj.DM_Emergencies_Opt_Out__c = true;
                    contactObj.Survey_Opt_Out__c = true;
                    //contactObj.DoNotCall = true;
                    contactObj.Communication_Preference_Primary__c = '';
                    contactObj.Communication_Preference_Secondary__c = '';
                    contactObj.Do_Not_Email__c = true;
                    contactObj.Do_Not_Mail__c = true;
                    contactObj.Do_Not_SMS__c = true;
                    contactObj.DM_All_Solicitations_Opt_Out__c = true;
                    contactObj.Email_All_Solicitations_Opt_Out__c = true;
                }
            }
        }
        return dmlWrapper;
    }
}