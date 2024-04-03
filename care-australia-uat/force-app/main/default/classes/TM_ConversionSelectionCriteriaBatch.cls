global class TM_ConversionSelectionCriteriaBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name,Conversion_action_summary__c,Conversion_Maximum_Attempts__c,MobilePhone, Phone_Common_Criteria__c,MailingCountry,npo02__LargestAmount__c,Largest_Gift_Date__c,npo02__TotalOppAmount__c,npo02__LastCloseDate__c,SolicitCode_Common_Criteria__c,Deceased_Inactive_Criteria__c,Telemarketing_Selection_Criteria__c,Decline_Exclusion__c,Conversion_Exclusion__c FROM Contact';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        
        if(conList!=null && !conList.isEmpty()) {
            
            Set<Id> conid = new Set<Id>();
            Set<Id> campid = new Set<Id>();
            List<Contact> inclusionList = new List<Contact>();
            List<Contact> exclusionList = new List<Contact>();
            List<Contact> UpdateList = new List<Contact>();
            Map<Id,String> RecDonMap = new Map<Id,String>();
            Map<Id,String> RecDonStatusReasonMap = new Map<Id,String>();
            Map<Id,Date> RecDonCancelledMap = new Map<Id,Date>();
            Map<Id,Date> RecLastDonDateMap = new Map<Id,Date>();
            Map<Id,String> OppMap = new Map<Id,String>();
            Map<Id,Date> OppLastPaymentDateMap = new Map<Id,Date>();
            Map<Id,String> campMemResultMap = new Map<Id,String>();
            Map<Id,String> campActionTypeMap = new Map<Id,String>();
            Map<Id,Date> campActionDateMap = new Map<Id,Date>();
            Map<Id,String> campCallTypeMap = new Map<Id,String>();
            Map<Id,String> campStatusMap = new Map<Id,String>();
            Map<Id,String> constituencyMap = new Map<Id,String>();
            
            for(Contact con : conList){
                conid.add(con.Id);
            }
            
            List<Opportunity> oppList = [select id,name,npsp__Primary_Contact__c,RecordType.Name,Last_Payment_Date__c from Opportunity where npsp__Primary_Contact__c IN : conid];
            List<npe03__Recurring_Donation__c> recDonList = [select id,name,npe03__Contact__c,npsp__Status__c,Cancellation_Date__c,npe03__Last_Payment_Date__c,npsp__ClosedReason__c
                                                             from npe03__Recurring_Donation__c where npe03__Contact__c IN : conid];
            
            List<CampaignMember> campMemList = [select id,name,ContactId,CampaignId,Telemarketing_Result__c,Action_Date__c,Action_Type_2__c,Call_Type__c,Status from CampaignMember where ContactId IN : conid];
            
            List<Donor_Constituency__c> donorConList = [select id,name,Constituency_Type__c,Contact__c from Donor_Constituency__c where Contact__c In : conid];
            
            if(!campMemList.isEmpty()){
                for(CampaignMember cam : campMemList){
                    campid.add(cam.CampaignId);
                    campMemResultMap.put(cam.ContactId,cam.Telemarketing_Result__c);
                    campActionTypeMap.put(cam.ContactId, cam.Action_Type_2__c);
                    campStatusMap.put(cam.ContactId, cam.Status);
                    campCallTypeMap.put(cam.ContactId,cam.Call_Type__c);
                    campActionDateMap.put(cam.ContactId,cam.Action_Date__c);
                }
                List<Campaign> camp = [select id,name,Telemarketing__c,Status from Campaign where id In : campid];
            }
            
            if(!donorConList.isEmpty()){
                for(Donor_Constituency__c don : donorConList){
                    constituencyMap.put(don.Contact__c , don.Constituency_Type__c);
                }
            }
            
            if(!recDonList.isEmpty()){
                for(npe03__Recurring_Donation__c rec : recDonList){
                    RecDonMap.put(rec.npe03__Contact__c,rec.npsp__Status__c);
                    RecDonCancelledMap.put(rec.npe03__Contact__c,rec.Cancellation_Date__c);
                    RecLastDonDateMap.put(rec.npe03__Contact__c, rec.npe03__Last_Payment_Date__c);
                    RecDonStatusReasonMap.put(rec.npe03__Contact__c,rec.npsp__ClosedReason__c);
                }
            }
            
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    if(opp.npsp__Primary_Contact__c != null){
                        OppMap.put(opp.npsp__Primary_Contact__c,opp.RecordType.Name);
                        if(opp.Last_Payment_Date__c != null){
                            OppLastPaymentDateMap.put(opp.npsp__Primary_Contact__c,opp.Last_Payment_Date__c);
                        }
                    }
                }
            }
            
            for(Contact con : conList) {
                //if(con.MobilePhone == '+61123456788'){
                    Date dt = System.today();
                    String strValueToRemove;
                    if(con.Phone_Common_Criteria__c == 'true' && con.MailingCountry == 'Australia'){
                        if(con.npo02__TotalOppAmount__c >= 50 && con.npo02__LastCloseDate__c.daysBetween(dt) <= 365 && OppMap.get(con.Id) != 'Recurring Donation'){
                            //Inclusion
                            string values = 'Digital Lead Conversion;';
                            con.Telemarketing_Selection_Criteria__c = values;
                            inclusionList.add(con);
                            system.debug('Contact Added for Inclusion=='+con.Id+' Name=='+con.Name + 'TELE Select=='+con.Telemarketing_Selection_Criteria__c);
                        }
                    }
                    if(con.SolicitCode_Common_Criteria__c == 'True'){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('1');
                    }else if(con.Deceased_Inactive_Criteria__c == 'True'){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('2');
                    }else if((OppLastPaymentDateMap.get(con.Id) != null && OppMap.get(con.Id) != null && OppLastPaymentDateMap.get(con.Id).daysBetween(dt) > 1095 && OppMap.get(con.Id) == 'Recurring Donation')){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('3');
                    }else if((constituencyMap.get(con.Id) != null && constituencyMap.get(con.Id) == 'Major Donor' || constituencyMap.get(con.Id) == 'Corporate'|| constituencyMap.get(con.Id) == 'Trust & Foundation'|| constituencyMap.get(con.Id) == 'Middle Donor')){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('4');
                    }else if((con.npo02__LargestAmount__c != null && con.Largest_Gift_Date__c != null && con.npo02__LargestAmount__c >= 250 && con.Largest_Gift_Date__c.daysBetween(dt) < 730)){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('5');
                    }else if(((RecDonMap.get(con.Id) != null && OppMap.get(con.Id) != null && RecDonMap.get(con.Id) == 'Active' || RecDonMap.get(con.Id) == 'Held') && OppMap.get(con.Id) == 'Recurring Donation')){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('6');
                    }else if((campActionTypeMap.get(con.Id) != null && campStatusMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campStatusMap.get(con.Id) == 'Sent')){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('7');
                    }else if((campActionTypeMap.get(con.Id) != null && campCallTypeMap.get(con.Id)!= null && campMemResultMap.get(con.Id)!= null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campCallTypeMap.get(con.Id) == 'C2C' && (campMemResultMap.get(con.Id) == 'Refusal' || campMemResultMap.get(con.Id) == 'Instant Refusal')) ){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('8');
                    }else if(con.Conversion_action_summary__c >= 3 || con.Conversion_Maximum_Attempts__c >=3){
                        strValueToRemove = 'Digital Lead Conversion';
                        system.debug('9');
                    }else{
                        strValueToRemove = null;
                    }
                    if(strValueToRemove != null){
                        system.debug('Contact Added for Exclusion=='+con.Id+' Name=='+con.Name + 'TELE Select=='+con.Telemarketing_Selection_Criteria__c);
                        if(con.Telemarketing_Selection_Criteria__c != null){
                            string strPickListValue = con.Telemarketing_Selection_Criteria__c;
                            List<string> lstPicklistValues = strPickListValue.split(';');
                            if(lstPicklistValues.contains(strValueToRemove)){
                                lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                                con.Telemarketing_Selection_Criteria__c = String.join(lstPicklistValues,';');
                                con.Conversion_Exclusion__c = true;
                                exclusionList.add(con);
                            }
                        }
                    }
                }
           // }
           
            Map<Id,Boolean> ExcludeMap = new Map<Id,Boolean>();
            if(!exclusionList.isEmpty()){
                for(Contact con : exclusionList){
                    ExcludeMap.put(con.Id,con.Conversion_Exclusion__c);
                }
            }
            if(inclusionList.size()>0){
                for(Contact c : inclusionList){
                    if(ExcludeMap.get(c.Id) == true){
                        system.debug('Does Not Include in Inclusion!!');
                    }else{
                        UpdateList.add(c);
                    }
                }
            }
            if(exclusionList.size()>0){
                try {
                    update exclusionList;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
            if(UpdateList.size()>0){
                try {
                    update UpdateList;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}