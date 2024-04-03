/**
* Name          :       RepaymentScheduleTrigger
* Date          :       07/07/2023
* Author        :       Amit Goyal
* Description   :       FSP Repayment Template related field update
                        Rollup information on related Loan
                        Writing Off process related functionality   
*/
trigger RepaymentScheduleTrigger on Repayment_Schedule__c (before insert, before update, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            RepaymentScheduleTriggerHandler.handleBeforeInsert(Trigger.New);
        }else{
            RepaymentScheduleTriggerHandler.handleBeforeUpdate(Trigger.New);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            RepaymentScheduleTriggerHandler.handleAfterInsert(Trigger.NewMap);
        }else if(Trigger.isUpdate){
            RepaymentScheduleTriggerHandler.handleAfterUpdate(Trigger.NewMap, Trigger.OldMap);
        }else if(Trigger.isDelete){
            RepaymentScheduleTriggerHandler.handleAfterDelete(Trigger.OldMap);
        }else{
            RepaymentScheduleTriggerHandler.handleAfterUndelete(Trigger.New);
        }
    }
}