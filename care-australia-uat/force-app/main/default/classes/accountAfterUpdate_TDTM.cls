global class accountAfterUpdate_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            system.debug(':::::::::::::::::accountAfterUpdate_TDTM:::::::::::::::::::::');
            Map<Id,Account> accountOldMap = new Map<Id,Account>();
            
            for (Account accOld : (list<Account>) oldlist) {
                
                accountOldMap.put(accOld.Id,accOld);
            }
            
            Set<Id> emailUpdatedAccIdSet = new Set<Id>();
            for (Account accNew :(list<Account>) newlist) {
                if(accNew.Email__c != accountOldMap.get(accNew.Id).Email__c){
                    emailUpdatedAccIdSet.add(accNew.Id);
                }
                
            }
            system.debug(':::::::::::::::::emailUpdatedAccIdSet:::::::::::::::::::::'+emailUpdatedAccIdSet.size());
            if(System.IsBatch() == false && System.isFuture() == false){
                if(emailUpdatedAccIdSet != null){
                    AccountFutureOperations.UpdateRDDonorEmail(emailUpdatedAccIdSet);
                    AccountFutureOperations.UpdatePaymentDonorEmail(emailUpdatedAccIdSet);
                    
                }
            }
            
        }
        return dmlWrapper;
    }
}