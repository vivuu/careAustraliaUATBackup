trigger LWC_TransactionTrigger on Transaction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LWC_TransactionTriggerHandler.handleBeforeInsert(Trigger.New);
        }else if(Trigger.isUpdate){
            LWC_TransactionTriggerHandler.handleBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
        }else{
            LWC_TransactionTriggerHandler.handleBeforeDelete(Trigger.OldMap);
        }
    }else{
        if(Trigger.isInsert){
            if(!LWC_TransactionTriggerHandler.hasRanAfterInsert){
                LWC_TransactionTriggerHandler.handleAfterInsert(Trigger.NewMap);
            }
        }else if(Trigger.isUpdate){
            if(!LWC_TransactionTriggerHandler.hasRanAfterUpdate){
            	LWC_TransactionTriggerHandler.handleAfterUpdate(Trigger.NewMap, Trigger.OldMap);
            }
        }else if(Trigger.isDelete){
            if(!LWC_TransactionTriggerHandler.hasRanAfterDelete){
            	LWC_TransactionTriggerHandler.handleAfterDelete(Trigger.OldMap);
            }
        }else{
            if(!LWC_TransactionTriggerHandler.hasRanAfterUndelete){
            	LWC_TransactionTriggerHandler.handleAfterUndelete(Trigger.NewMap);
            }
        }
    }
}