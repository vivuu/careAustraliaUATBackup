/**
* Name          :       LWCUserTrigger
* Date          :       07/09/2023
* Author        :       Amit Goyal
* Description   :       To put Country and Currency Validation for FSP Staff Users
*/
trigger LWCUserTrigger on User (before insert, before update,after insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            UserTriggerHandler.handleBefore(Trigger.new);
        }
    }
    if(Trigger.isInsert || Trigger.isAfter)
    {
        UserTriggerHandler.handleAfterInsert(Trigger.new);
    }
}