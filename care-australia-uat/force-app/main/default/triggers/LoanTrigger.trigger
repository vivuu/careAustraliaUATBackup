/**
* Name			:		LoanTriggerHandler
* Date			:		07/07/2023
* Author		:		Amit Goyal
* Description	:		to apply event based automation on Loan Object
*/

trigger LoanTrigger on Loan__c (before insert, before update, after insert,after Update, before delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LoanTriggerHandler.handleBeforeInsert(Trigger.New);
        } else if(Trigger.isUpdate){
            LoanTriggerHandler.handleBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
        } else if(Trigger.isDelete){
            LoanTriggerHandler.handleBeforeDelete(Trigger.OldMap);
        }
    } else {
        if(Trigger.isInsert){
            LoanTriggerHandler.handleAfterInsert(Trigger.New);
        } else if(Trigger.isUpdate){
            LoanTriggerHandler.handleAfterUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }
}