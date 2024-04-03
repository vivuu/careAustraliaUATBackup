/**
* Name			:		ContactTrigger
* Date			:		07/07/2023
* Author		:		Amit Goyal
* Description	:		to apply event based automation on Contact Object
*/
trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert) {
        ContactTriggerHandler.handleBeforeInsert(Trigger.New);
        ContactTriggerHelper.updateContactDetails(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        ContactTriggerHandler.handleBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.handleAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
        ContactTriggerHandler.handleBeforeDelete(Trigger.Old);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        ContactTriggerHandler.handleAfterInsert(Trigger.New);
    }
}