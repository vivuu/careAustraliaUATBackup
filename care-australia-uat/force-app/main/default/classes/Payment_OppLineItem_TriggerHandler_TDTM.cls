global class Payment_OppLineItem_TriggerHandler_TDTM extends npsp.TDTM_RunnableMutable  {
    global override void run(List<SObject> listNew, List<SObject> listOld,
                             npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
                             npsp.TDTM_Runnable.DmlWrapper dmlWrapper){
                                 if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate || triggerAction == npsp.TDTM_Runnable.Action.AfterInsert)
                                 {           
                                     //cast payment
                                     npe01__OppPayment__c paymentObj;
                                     Set<Id> payoppId = new Set<Id>();
                                     Map<Id,npe01__OppPayment__c> oppPaymentMap = new Map<Id,npe01__OppPayment__c>();
                                     for(SObject payNew : listNew){
                                         paymentObj = (npe01__OppPayment__c) payNew;
                                         payoppId.add(paymentObj.npe01__Opportunity__c);
                                         oppPaymentMap.put(paymentObj.npe01__Opportunity__c,paymentObj);
                                     }
                                     List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
                                     Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CARE Gift').getRecordTypeId();
                                     List<Opportunity> oppList = [select Id,name,RecordTypeId,Care_Gift_Receipt_Number__c,(select id,Product2Id from OpportunityLineItems ) from Opportunity where Id =: payoppId AND RecordTypeId=: devRecordTypeId];
                                     if(oppList.size()>0){    
                                         // iterate over Opportunity records to OpportunityLineItems
                                         for(Opportunity opp : oppList){
                                             // iterate over OpportunityLineItem records to set paymentId
                                             if(opp.OpportunityLineItems.size()>0){ 
                                                 for(OpportunityLineItem oppLineItem : opp.OpportunityLineItems){
                                                     oppLineItem.Payment__c = oppPaymentMap.get(opp.Id).Id;
                                                     oppLineItemList.add(oppLineItem);
                                                 }
                                             }
                                             if(oppPaymentMap.get(opp.Id).Receipt_Number__c != null && opp.Care_Gift_Receipt_Number__c != oppPaymentMap.get(opp.Id).Receipt_Number__c){
                                                 opp.Care_Gift_Receipt_Number__c = oppPaymentMap.get(opp.Id).Receipt_Number__c;
                                             }
                                             
                                             
                                         }
                                         
                                         update oppList;
                                         //update opportunity line item
                                         Update oppLineItemList;
                                     }            
                                 }
                             }
}