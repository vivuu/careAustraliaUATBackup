global class contactAfterUpdate_TDTM extends npsp.TDTM_Runnable {
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            system.debug(':::::::::::::::::contactAfterUpdate_TDTM:::::::::::::::::::::');
            
            Map<Id,Contact> conOldMap = new Map<Id,Contact>();
            for (Contact conOld : (list<Contact>) oldlist) {
                conOldMap.put(conOld.Id,conOld);
            }
            Set<ID> conIdSet = new Set<ID>();
            
            Set<Id> emailUpdatedConIdSet = new Set<Id>();
            for (Contact con : (list<Contact>)newlist) {
                if (con.npsp__Deceased__c == true) {
                    conIdSet.add(con.Id);
                }   
                if(con.Email != conOldMap.get(con.Id).Email ){
                    emailUpdatedConIdSet.add(con.Id);
                }
                
            }
            if(conIdSet!=null && !conIdSet.isEmpty()) {
                //Retrieve all Active Recurring Deposits of Deceased Donor
                list<npe03__Recurring_Donation__c > listDeceasedRD = [SELECT Id, npsp__ClosedReason__c, npsp__Status__c,npe03__Contact__r.Deceased_Date__c 
                                                                      FROM npe03__Recurring_Donation__c where npsp__Status__c != 'Cancelled' 
                                                                      and Donor_Type__c = 'Contact' and npe03__Contact__c in :conIdSet];
                system.debug(':::::::::::::::::listDeceasedRD:::::::::::::::::::::'+listDeceasedRD.size());
                if(listDeceasedRD!=null && !listDeceasedRD.isEmpty()) {
                    
                    //Update Recurring Deposits Status to 'Closed' and Status Reason to 'Deceased Donor'
                    for (npe03__Recurring_Donation__c rd : listDeceasedRD) {
                        rd.npsp__Status__c = 'Cancelled';
                        rd.npsp__ClosedReason__c = 'Deceased';
                        if(rd.npe03__Contact__r.Deceased_Date__c != null){
                            rd.Cancellation_Date__c = rd.npe03__Contact__r.Deceased_Date__c;
                        }else{
                            rd.Cancellation_Date__c = System.today();
                        }
                    }
                    try{
                        dmlWrapper.objectsToUpdate.addAll((list<SObject>)listDeceasedRD);
                    }Catch(exception e){
                        system.debug('Exception:'+e.getmessage());
                        
                    }
                }   
            }
            if(System.IsBatch() == false && System.isFuture() == false){
                if(emailUpdatedConIdSet!=null && !emailUpdatedConIdSet.isEmpty()) {
                    ContactFutureOperations.UpdateRDDonorEmail(emailUpdatedConIdSet);
                    ContactFutureOperations.UpdatePaymentDonorEmail(emailUpdatedConIdSet);
                    
                }
            }
        }
        return dmlWrapper;
    }
}