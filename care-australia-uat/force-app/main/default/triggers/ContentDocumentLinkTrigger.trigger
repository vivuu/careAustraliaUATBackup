trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before insert) {
    if( Trigger.isAfter ){
        if( Trigger.isInsert ){
            	ContentDocumentLinkTriggerHelper.handleContentDistribution(Trigger.New);
        }
    } else if( Trigger.isBefore ){
        if( Trigger.isInsert ){
            	ContentDocumentLinkTriggerHelper.handleVisibility(Trigger.New);
        }
    }
}