global class camMemberAfterInsertUpdate_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate || triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){
            Date dt = System.today();
            Set<Id> conid = new Set<Id>();
            Set<Id> campid = new Set<Id>();
            Map<Id,String> telemarketingResultMap = new Map<Id,String>();
            Map<Id,String> actionTypeMap = new Map<Id,String>();
            Map<Id,String> callTypeMap = new Map<Id,String>();
            Map<Id,Date> actionDateMap = new Map<Id,Date>();
            Map<Id,Boolean> campBolMap = new Map<Id,Boolean>();
            CampaignMember camObj;
            
            for(SObject cNew : newlist){
                camObj = (CampaignMember)cNew;
                campid.add(camObj.Id);
                conid.add(camObj.ContactId);
                telemarketingResultMap.put(camObj.ContactId, camObj.Telemarketing_Result__c);
                actionTypeMap.put(camObj.ContactId, camObj.Action_Type_2__c);
                callTypeMap.put(camObj.ContactId, camObj.Call_Type__c);
                actionDateMap.put(camObj.ContactId, camObj.Action_Date__c);
                campBolMap.put(camObj.ContactId,camObj.Action_Summary__c);
            }
            
            List<Contact> conList = [select id,name,Upgrade_Maximum_Attempts__c,Reactivate_Maximum_Attempts__c,Conversion_action_summary__c,Reactivate_action_summary__c,Upgrade_action_summary__c,Decline_action_summary__c,Conversion_Maximum_Attempts__c from Contact where id in : conid];
            List<Contact> conUpdtList = new List<Contact>();
            List<CampaignMember> campUpdtList = new List<CampaignMember>();
            
            for(Contact con : conList){
                
                //Conversion Actions Summary
                
                if(actionTypeMap.get(con.Id) != null && callTypeMap.get(con.Id) != null && telemarketingResultMap.get(con.Id) != null && actionDateMap.get(con.Id) != null &&
                   actionTypeMap.get(con.Id) == 'Telemarketing' && callTypeMap.get(con.Id) == 'C2C' 
                   && (telemarketingResultMap.get(con.Id) == 'Refusal' || telemarketingResultMap.get(con.Id) == 'Instant Refusal') 
                   && actionDateMap.get(con.Id).daysBetween(dt) < 1460){
                       if(con.Conversion_action_summary__c == null){
                           con.Conversion_action_summary__c = 1;
                           //cNew.Action_Summary__c = true;
                       }else{
                           con.Conversion_action_summary__c = con.Conversion_action_summary__c + 1;
                           //cNew.Action_Summary__c = true;
                       }
                       conUpdtList.add(con);
                       //campList.add(cNew);
                   }
                if(actionTypeMap.get(con.Id) != null && callTypeMap.get(con.Id) != null && telemarketingResultMap.get(con.Id) != null && actionDateMap.get(con.Id) != null &&
                   actionTypeMap.get(con.Id) == 'Telemarketing' && callTypeMap.get(con.Id) == 'C2C' 
                   && telemarketingResultMap.get(con.Id) == 'Maximum Attempts'
                   && actionDateMap.get(con.Id).daysBetween(dt) < 730 /*&& cNew.Maximum_Attempts__c == false*/){
                       if(con.Conversion_Maximum_Attempts__c == null){
                           con.Conversion_Maximum_Attempts__c = 1;
                           //cNew.Maximum_Attempts__c = true;
                       }else{
                           con.Conversion_Maximum_Attempts__c = con.Conversion_Maximum_Attempts__c + 1;
                           //cNew.Maximum_Attempts__c = true;
                       }
                       conUpdtList.add(con);
                       //campList.add(cNew);
                   }
                
                // Rejection Action Summary
                
                if(actionTypeMap.get(con.Id) != null && callTypeMap.get(con.Id) != null && telemarketingResultMap.get(con.Id) != null && actionDateMap.get(con.Id) != null &&
                   actionTypeMap.get(con.Id) == 'Telemarketing' && callTypeMap.get(con.Id) == 'Reactivates' 
                   && (telemarketingResultMap.get(con.Id) == 'Refusal' || telemarketingResultMap.get(con.Id) == 'Instant Refusal') 
                   && actionDateMap.get(con.Id).daysBetween(dt) < 1095 /*&& cNew.Action_Summary__c == false*/){
                       if(con.Reactivate_action_summary__c == null){
                           con.Reactivate_action_summary__c = 1;
                           //cNew.Action_Summary__c = true;
                       }else{
                           con.Reactivate_action_summary__c = con.Reactivate_action_summary__c + 1;
                           //cNew.Action_Summary__c = true;
                       }
                       conUpdtList.add(con);
                       //campList.add(cNew);
                   }
                if(actionTypeMap.get(con.Id) != null && callTypeMap.get(con.Id) != null && telemarketingResultMap.get(con.Id) != null && actionDateMap.get(con.Id) != null &&
                   actionTypeMap.get(con.Id) == 'Telemarketing' && callTypeMap.get(con.Id) == 'Reactivates' 
                   && telemarketingResultMap.get(con.Id) == 'Maximum Attempts' 
                   && actionDateMap.get(con.Id).daysBetween(dt) < 182 /*&& cNew.Maximum_Attempts__c == false*/){
                       if(con.Reactivate_Maximum_Attempts__c == null){
                           con.Reactivate_Maximum_Attempts__c = 1;
                           //cNew.Maximum_Attempts__c = true;
                       }else{
                           con.Reactivate_Maximum_Attempts__c = con.Reactivate_Maximum_Attempts__c + 1;
                           //cNew.Maximum_Attempts__c = true;
                       }
                       conUpdtList.add(con);
                       //campList.add(cNew);
                   }
                
                //Decline Action Summary
                
                if(actionTypeMap.get(con.Id) != null && callTypeMap.get(con.Id) != null && telemarketingResultMap.get(con.Id) != null && actionDateMap.get(con.Id) != null &&
                   actionTypeMap.get(con.Id) == 'Telemarketing' && callTypeMap.get(con.Id) == 'Rejections' 
                   && telemarketingResultMap.get(con.Id) == 'Maximum Attempts' 
                   && actionDateMap.get(con.Id).daysBetween(dt) < 91 /*&& cNew.Action_Summary__c == false*/){
                       if(con.Decline_action_summary__c == null){
                           con.Decline_action_summary__c = 1;
                           //cNew.Maximum_Attempts__c = true;
                       }else{
                           con.Decline_action_summary__c = con.Decline_action_summary__c + 1;
                           //cNew.Maximum_Attempts__c = true;
                       }
                       conUpdtList.add(con);
                       //campList.add(cNew);
                   }
                //Upgrades Action Summary
                
                if(actionTypeMap.get(con.Id) != null && callTypeMap.get(con.Id) != null && telemarketingResultMap.get(con.Id) != null && actionDateMap.get(con.Id) != null &&
                   actionTypeMap.get(con.Id) == 'Telemarketing' && callTypeMap.get(con.Id) == 'Upgrades' 
                   && (telemarketingResultMap.get(con.Id) == 'Refusal' || telemarketingResultMap.get(con.Id) == 'Instant Refusal') 
                   && actionDateMap.get(con.Id).daysBetween(dt) < 1460 /*&& cNew.Action_Summary__c == false*/){
                       if(con.Upgrade_action_summary__c == null){
                           con.Upgrade_action_summary__c = 1;
                           //cNew.Action_Summary__c = true;
                       }else{
                           con.Upgrade_action_summary__c = con.Upgrade_action_summary__c + 1;
                           //cNew.Action_Summary__c = true;
                       }
                       conList.add(con);
                       //campList.add(cNew);
                   }
                
                if(actionTypeMap.get(con.Id) != null && callTypeMap.get(con.Id) != null && telemarketingResultMap.get(con.Id) != null && actionDateMap.get(con.Id) != null &&
                   actionTypeMap.get(con.Id) == 'Telemarketing' && callTypeMap.get(con.Id) == 'Upgrades' 
                   && telemarketingResultMap.get(con.Id) == 'Maximum Attempts' 
                   && actionDateMap.get(con.Id).daysBetween(dt) < 182 /*&& cNew.Maximum_Attempts__c == false*/){
                       if(con.Reactivate_Maximum_Attempts__c == null){
                           con.Upgrade_Maximum_Attempts__c = 1;
                           //cNew.Maximum_Attempts__c = true;
                       }else{
                           con.Upgrade_Maximum_Attempts__c = con.Upgrade_Maximum_Attempts__c + 1;
                           //cNew.Maximum_Attempts__c = true;
                       }
                       conUpdtList.add(con);
                       //campList.add(cNew);
                   }
            }
            if(!conUpdtList.isEmpty()){
                update conUpdtList;
            }
        }
        return dmlWrapper;
    }
}