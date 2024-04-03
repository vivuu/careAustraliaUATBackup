trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert,before update) {    
    If(trigger.isInsert || trigger.isUpdate){
         OpportunityLineItemTriggerHandler.OppLineItemHandler(trigger.new);
    }

}