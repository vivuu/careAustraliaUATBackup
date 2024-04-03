global class TM_DeclineSelectionCriteriaBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name ,MobilePhone,Decline_action_summary__c, Phone_Common_Criteria__c,MailingCountry,npo02__LargestAmount__c,Largest_Gift_Date__c,npo02__TotalOppAmount__c,npo02__LastCloseDate__c,SolicitCode_Common_Criteria__c,Deceased_Inactive_Criteria__c,Telemarketing_Selection_Criteria__c,Decline_Exclusion__c FROM Contact';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        if(conList!=null && !conList.isEmpty()) {
            
            Set<Id> conid = new Set<Id>();
            Set<Id> campid = new Set<Id>();
            Set<Id> oppid = new Set<Id>();
            List<Contact> inclusionList = new List<Contact>();
            List<Contact> exclusionList = new List<Contact>();
            List<Contact> UpdateList = new List<Contact>();
            Map<Id,String> RecDonMap = new Map<Id,String>();
            Map<Id,String> RecDonStatusReasonMap = new Map<Id,String>();
            Map<Id,Date> RecDonCancelledMap = new Map<Id,Date>();
            Map<Id,Date> RecLastDonDateMap = new Map<Id,Date>();
            Map<Id,String> OppMap = new Map<Id,String>();
            Map<Id,Decimal> OppPaymentNumberMap = new Map<Id,Decimal>();
            Map<Id,Decimal> OppPaymentAmountMap = new Map<Id,Decimal>();
            Map<Id,Date> OppLastPaymentDateMap = new Map<Id,Date>();
            Map<Id,String> campMemResultMap = new Map<Id,String>();
            Map<Id,String> campActionTypeMap = new Map<Id,String>();
            Map<Id,Date> campActionDateMap = new Map<Id,Date>();
            Map<Id,String> campCallTypeMap = new Map<Id,String>();
            Map<Id,String> campStatusMap = new Map<Id,String>();
            Map<Id,String> constituencyMap = new Map<Id,String>();
            Map<Id,Decimal> totalBouncedMap = new Map<Id,Decimal>();
            Map<Id,Date> lastBouncedDateMap = new Map<Id,Date>();
            
            for(Contact con : conList){
                conid.add(con.Id);
            }
            
            List<Opportunity> oppList = [select id,name,npsp__Primary_Contact__c,RecordType.Name,npe01__Number_of_Payments__c,Bounced_Payments__c,
                                         npe01__Payments_Made__c,Last_Payment_Date__c  from Opportunity where npsp__Primary_Contact__c IN : conid];
            List<npe03__Recurring_Donation__c> recDonList = [select id,name,npe03__Contact__c,npsp__Status__c,Cancellation_Date__c,npe03__Last_Payment_Date__c,npsp__ClosedReason__c
                                                             from npe03__Recurring_Donation__c where npe03__Contact__c IN : conid];
            List<CampaignMember> campMemList = [select id,name,ContactId,CampaignId,Telemarketing_Result__c,Action_Date__c,Call_Type__c,Status,Action_Type_2__c from CampaignMember where ContactId IN : conid];
            List<Donor_Constituency__c> donorConList = [select id,name,Constituency_Type__c,Contact__c from Donor_Constituency__c where Contact__c In : conid];
            
            if(!campMemList.isEmpty()){
                for(CampaignMember cam : campMemList){
                    campid.add(cam.CampaignId);
                }
            }
            
            if(!donorConList.isEmpty()){
                for(Donor_Constituency__c don : donorConList){
                    constituencyMap.put(don.Contact__c , don.Constituency_Type__c);
                }
            }
            
            List<Campaign> camp = [select id,name,Telemarketing__c,Status from Campaign where id In : campid];
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
                    oppid.add(opp.Id);
                    OppMap.put(opp.npsp__Primary_Contact__c,opp.RecordType.Name);
                    OppPaymentNumberMap.put(opp.npsp__Primary_Contact__c, opp.npe01__Number_of_Payments__c);
                    OppPaymentAmountMap.put(opp.npsp__Primary_Contact__c,opp.npe01__Payments_Made__c);
                    OppLastPaymentDateMap.put(opp.npsp__Primary_Contact__c,opp.Last_Payment_Date__c);
                    totalBouncedMap.put(opp.npsp__Primary_Contact__c,opp.Bounced_Payments__c);
                    //lastBouncedDateMap.put(opp.npsp__Primary_Contact__c,opp.Last_Bounced_Date__c);
                }
            }
            if(!campMemList.isEmpty()){
                for(CampaignMember cm : campMemList){
                    campMemResultMap.put(cm.ContactId,cm.Telemarketing_Result__c);
                    campActionTypeMap.put(cm.ContactId, cm.Action_Type_2__c);
                    campStatusMap.put(cm.ContactId, cm.Status);
                    campCallTypeMap.put(cm.ContactId,cm.Call_Type__c);
                    campActionDateMap.put(cm.ContactId,cm.Action_Date__c);
                }
            }
            
            for(Contact con : conList) {
                Date dt = System.today();
                String strValueToRemove;
                //if(con.MobilePhone == '+61123456788'){
                    if(con.Phone_Common_Criteria__c == 'true' && con.MailingCountry == 'Australia'){
                        if(OppMap.get(con.Id) == 'Recurring Donation' && (RecDonMap.get(con.Id) == 'Held' || RecDonMap.get(con.Id) == 'Active')){
                            if(totalBouncedMap.get(con.Id) >= 2){
                                //Inclusion
                                string values = 'Declines;';
                                con.Telemarketing_Selection_Criteria__c = values;
                                inclusionList.add(con);
                            }
                        }
                    }
                    if(con.SolicitCode_Common_Criteria__c == 'True' || con.Deceased_Inactive_Criteria__c == 'True'){
                        strValueToRemove = 'Declines';
                        system.debug('1');
                    }else if(constituencyMap.get(con.Id) != null && constituencyMap.get(con.Id) == 'Major Donor' || constituencyMap.get(con.Id) == 'Corporate'|| constituencyMap.get(con.Id) == 'Trust & Foundation'|| constituencyMap.get(con.Id) == 'Middle Donor'){
                        strValueToRemove = 'Declines';
                        system.debug('2');
                    }else if(campActionTypeMap.get(con.Id) != null && campStatusMap.get(con.Id) != null && campCallTypeMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campStatusMap.get(con.Id) == 'Sent' && campCallTypeMap.get(con.Id) == 'Rejections'){
                        strValueToRemove = 'Declines';
                        system.debug('3');
                    }else if(campActionTypeMap.get(con.Id) != null && campCallTypeMap.get(con.Id) != null && campMemResultMap.get(con.Id) != null && campActionDateMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campCallTypeMap.get(con.Id) == 'Rejections' && campMemResultMap.get(con.Id) == 'Payment Details Updated' && campActionDateMap.get(con.Id).daysBetween(dt) < 30){
                        strValueToRemove = 'Declines';
                        system.debug('4');
                    }else if(campActionTypeMap.get(con.Id) != null && campCallTypeMap.get(con.Id) != null && campMemResultMap.get(con.Id) != null && campActionDateMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campCallTypeMap.get(con.Id) == 'Rejections' && campMemResultMap.get(con.Id) == 'Payment Details Confirmed' && campActionDateMap.get(con.Id).daysBetween(dt) < 91){
                        strValueToRemove = 'Declines';
                        system.debug('5');
                    }else if(campCallTypeMap.get(con.Id) != null && campMemResultMap.get(con.Id) != null && campActionDateMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campCallTypeMap.get(con.Id) == 'Rejections' && (campMemResultMap.get(con.Id) == 'Refusal' || campMemResultMap.get(con.Id) == 'Instant Refusal') && campActionDateMap.get(con.Id).daysBetween(dt) < 60){
                        strValueToRemove = 'Declines';
                        system.debug('6');
                    }else if(campCallTypeMap.get(con.Id) != null && campMemResultMap.get(con.Id) != null && campActionDateMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campCallTypeMap.get(con.Id) == 'Rejections' && campMemResultMap.get(con.Id) == 'Voicemail Message Left' && campActionDateMap.get(con.Id).daysBetween(dt) < 91){
                        strValueToRemove = 'Declines';
                        system.debug('7');
                    }else if(con.Decline_action_summary__c >= 3){
                        strValueToRemove = 'Declines';
                        system.debug('8');
                    }else{
                        strValueToRemove = null;
                    }
                    if(strValueToRemove != null){
                        system.debug('Contact Added for Exclusion=='+con.Id+' Name=='+con.Name + 'TELE Select=='+con.Telemarketing_Selection_Criteria__c);
                        if(con.Telemarketing_Selection_Criteria__c != null){
                            system.debug('Inside 1***');
                            string strPickListValue = con.Telemarketing_Selection_Criteria__c;
                            List<string> lstPicklistValues = strPickListValue.split(';');
                            if(lstPicklistValues.contains(strValueToRemove)){
                                system.debug('Inside 2***');
                                lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                                con.Telemarketing_Selection_Criteria__c = String.join(lstPicklistValues,';');
                                con.Decline_Exclusion__c = true;
                                exclusionList.add(con);
                                system.debug('exclusionList size inside=='+exclusionList.size());
                            }
                        }
                    }
               // }
            }
            Map<Id,Boolean> ExcludeMap = new Map<Id,Boolean>();
            for(Contact con : exclusionList){
                ExcludeMap.put(con.Id,con.Decline_Exclusion__c);
            }
            for(Contact c : inclusionList){
                if(ExcludeMap.get(c.Id) == true){
                    system.debug('Does Not Include in Inclusion!!');
                }else{
                    UpdateList.add(c);
                }
            }
            system.debug('exclusionList size=='+exclusionList.size());
            if(exclusionList.size()>0){
                system.debug('exclusionList=='+exclusionList);
                update exclusionList;
            }
            if(UpdateList.size()>0){
                update UpdateList;
            }
        }
    }   
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}