({
	updateExpiry : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
		component.set("v.showSpinner", true);
        var self = this;
        
        var action = component.get("c.updateExpiry");
        var idToUse = component.get("v.recordId");
        let month = '';
        let year = '';
        if(component.get('v.month') != undefined){
            month = component.get('v.month');
        }
       if(component.get('v.year') != undefined){
            year = component.get('v.year');
        }
        
        action.setParams({
            "recId": idToUse,
            "month" : month,
            "year" : year
        });
        
        var self = this;
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                
                $A.get('e.force:refreshView').fire();
                component.set("v.showSpinner", false);
                
                toastEvent.setParams({
                "title": "Success!",
                "message": "The record has been updated successfully.",
                "type":"success"
            });
            toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }else{
                component.set("v.showSpinner", false);
                toastEvent.setParams({
                "title": "Error!",
                "message": actionResult.getError()[0].message,
                "type":"error"
            });
            toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})