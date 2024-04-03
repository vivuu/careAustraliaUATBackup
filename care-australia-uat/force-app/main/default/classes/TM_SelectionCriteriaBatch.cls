global class TM_SelectionCriteriaBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name ,MobilePhone,Upgrade_Maximum_Attempts__c,npo02__NumberOfClosedOpps__c,CreatedDate,Upgrade_action_summary__c,Telemarketing_Selection_Criteria__c,Deceased_Inactive_Criteria__c, Phone_Common_Criteria__c,MailingCountry,npo02__LargestAmount__c,Largest_Gift_Date__c,npo02__TotalOppAmount__c,npo02__LastCloseDate__c,SolicitCode_Common_Criteria__c FROM Contact';
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
            Map<Id,String> RecDonPayTypeMap = new Map<Id,String>();
            Map<Id,String> RecDonInstPeriodMap = new Map<Id,String>();
            Map<Id,Date> RecDonCreatedDateMap = new Map<Id,Date>();
            Map<Id,String> OppMap = new Map<Id,String>();
            Map<Id,Decimal> OppPaymentNumberMap = new Map<Id,Decimal>();
            Map<Id,Decimal> OppPaymentAmountMap = new Map<Id,Decimal>();
            Map<Id,Decimal> OppConsecutivePayMap = new Map<Id,Decimal>();
            Map<Id,Date> OppLastPaymentDateMap = new Map<Id,Date>();
            Map<Id,String> campMemResultMap = new Map<Id,String>();
            Map<Id,String> campActionTypeMap = new Map<Id,String>();
            Map<Id,Date> campActionDateMap = new Map<Id,Date>();
            Map<Id,String> campCallTypeMap = new Map<Id,String>();
            Map<Id,String> campStatusMap = new Map<Id,String>();
            Map<Id,String> constituencyMap = new Map<Id,String>();
            Map<Id,Decimal> totalBouncedMap = new Map<Id,Decimal>();
            Map<Id,Date> lastBouncedDateMap = new Map<Id,Date>();
            Map<Id,Date> RDAmendmentDateMap = new Map<Id,Date>();
            
            for(Contact con : conList){
                conid.add(con.Id);
            }
            
            List<Opportunity> oppList = [select id,name,npsp__Primary_Contact__c,RecordType.Name,npe01__Number_of_Payments__c,Number_of_Consecutive_payments__c,
                                         npe01__Payments_Made__c,Last_Payment_Date__c,Total_Bounced_Payments__c,Last_Bounced_Date__c  from Opportunity where npsp__Primary_Contact__c IN : conid];
            List<npe03__Recurring_Donation__c> recDonList = [select id,name,npe03__Contact__c,npsp__Status__c,Cancellation_Date__c,
                                                             npe03__Last_Payment_Date__c,npsp__ClosedReason__c,npsp__PaymentMethod__c,npe03__Installment_Period__c,CreatedDate,Amendment_Date__c
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
            
            if(!recDonList.isEmpty()){
                for(npe03__Recurring_Donation__c rec : recDonList){
                    RecDonMap.put(rec.npe03__Contact__c,rec.npsp__Status__c);
                    RecDonCancelledMap.put(rec.npe03__Contact__c,rec.Cancellation_Date__c);
                    RecLastDonDateMap.put(rec.npe03__Contact__c, rec.npe03__Last_Payment_Date__c);
                    RecDonStatusReasonMap.put(rec.npe03__Contact__c,rec.npsp__ClosedReason__c);
                    RecDonPayTypeMap.put(rec.npe03__Contact__c, rec.npsp__PaymentMethod__c);
                    RecDonInstPeriodMap.put(rec.npe03__Contact__c, rec.npe03__Installment_Period__c);
                    DateTime dT = rec.CreatedDate;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    RecDonCreatedDateMap.put(rec.npe03__Contact__c, myDate);
                    if(rec.Amendment_Date__c != null){
                        RDAmendmentDateMap.put(rec.npe03__Contact__c,rec.Amendment_Date__c);
                    }
                }
            }
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    oppid.add(opp.Id);
                    OppMap.put(opp.npsp__Primary_Contact__c,opp.RecordType.Name);
                    OppPaymentNumberMap.put(opp.npsp__Primary_Contact__c, opp.npe01__Number_of_Payments__c);
                    OppPaymentAmountMap.put(opp.npsp__Primary_Contact__c,opp.npe01__Payments_Made__c);
                    if(opp.Last_Payment_Date__c != null){
                        OppLastPaymentDateMap.put(opp.npsp__Primary_Contact__c,opp.Last_Payment_Date__c);
                    }
                    totalBouncedMap.put(opp.npsp__Primary_Contact__c,opp.Total_Bounced_Payments__c);
                    lastBouncedDateMap.put(opp.npsp__Primary_Contact__c,opp.Last_Bounced_Date__c);
                    if(opp.Number_of_Consecutive_payments__c != null){
                        OppConsecutivePayMap.put(opp.npsp__Primary_Contact__c, opp.Number_of_Consecutive_payments__c);
                    }
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
                //if(con.MobilePhone == '+61123456789'){
                    if(con.Phone_Common_Criteria__c == 'true' && con.MailingCountry == 'Australia'){
                        if(OppMap.get(con.Id) == 'Recurring Donation' && RecDonMap.get(con.Id) == 'Held' && (RecDonPayTypeMap.get(con.id) == 'Credit Card' || RecDonPayTypeMap.get(con.id) == 'Direct Debit')
                           && RecDonInstPeriodMap.get(con.Id) == 'Monthly' && dt.daysBetween(RecDonCreatedDateMap.get(con.Id)) > 182){
                               if(OppLastPaymentDateMap.get(con.Id) != null && OppLastPaymentDateMap.get(con.Id).daysBetween(dt) <= 60){
                                   if(OppConsecutivePayMap.get(con.Id) >= 6){
                                       //Inclusion
                                       string values = 'Upgrades;';
                                       con.Telemarketing_Selection_Criteria__c = values;
                                       inclusionList.add(con);
                                   }
                               }
                           }
                    }
                    if(con.SolicitCode_Common_Criteria__c == 'True' || con.Deceased_Inactive_Criteria__c == 'True'){
                        strValueToRemove = 'Upgrades';
                    }else if(RDAmendmentDateMap.get(con.Id) != null && RDAmendmentDateMap.get(con.Id).daysBetween(dt) < 365){
                        strValueToRemove = 'Upgrades';
                    }else if(campActionTypeMap.get(con.Id) != null && campStatusMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campStatusMap.get(con.Id) == 'Sent'){
                        strValueToRemove = 'Upgrades';
                    }else if(campActionTypeMap.get(con.Id) != null && campCallTypeMap.get(con.Id) != null && campMemResultMap.get(con.Id) != null && campActionDateMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campCallTypeMap.get(con.Id) == 'Upgrades' && (campMemResultMap.get(con.Id) == 'Refusal' || campMemResultMap.get(con.Id) == 'Instant Refusal') && campActionDateMap.get(con.Id).daysBetween(dt) < 365){
                        strValueToRemove = 'Upgrades';
                    }else if(campActionTypeMap.get(con.Id) != null && campCallTypeMap.get(con.Id) != null && campMemResultMap.get(con.Id) != null && campActionDateMap.get(con.Id) != null && campActionTypeMap.get(con.Id) == 'Telemarketing' && campCallTypeMap.get(con.Id) == 'Reactivates' && (campMemResultMap.get(con.Id) == 'Donation' || campMemResultMap.get(con.Id) == 'Increase Gift') && campActionDateMap.get(con.Id).daysBetween(dt) < 365){
                        strValueToRemove = 'Upgrades';
                    }else if(constituencyMap.get(con.Id) != null && constituencyMap.get(con.Id) == 'Major Donor' || constituencyMap.get(con.Id) == 'Corporate' || constituencyMap.get(con.Id) == 'Trust & Foundation' || constituencyMap.get(con.Id) == 'Middle Donor'){
                        strValueToRemove = 'Upgrades';
                    }else if(con.Upgrade_action_summary__c >= 3 || con.Upgrade_Maximum_Attempts__c >= 3){
                        strValueToRemove = 'Upgrades';
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
                                con.Upgrade_Exclusion__c = true;
                                exclusionList.add(con);
                            }
                        }
                    }
                //}
            }
            Map<Id,Boolean> ExcludeMap = new Map<Id,Boolean>();
            for(Contact con : exclusionList){
                ExcludeMap.put(con.Id,con.Upgrade_Exclusion__c);
            }
            for(Contact c : inclusionList){
                if(ExcludeMap.get(c.Id) == true){
                    system.debug('Does Not Include in Inclusion!!');
                }else{
                    UpdateList.add(c);
                }
            }
            if(exclusionList.size()>0){
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