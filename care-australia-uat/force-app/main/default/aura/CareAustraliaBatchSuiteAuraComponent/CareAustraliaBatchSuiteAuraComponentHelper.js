({
    initializeData : function(component, event) {
        var action = component.get("c.fetchAsyncJobList");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                component.set("v.asyncapexjobs",result['apexJobLst']);
                console.log(result);
            }
            else{
                var errors = response.getError();
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, batchName, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})