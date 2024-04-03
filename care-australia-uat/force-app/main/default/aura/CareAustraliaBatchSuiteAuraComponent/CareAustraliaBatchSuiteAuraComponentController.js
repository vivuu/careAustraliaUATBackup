({
    doInit: function (component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.columns', [
            {label: 'Job name', fieldName: 'ApexClass', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'},
            {label: 'Total Batches', fieldName: 'TotalJobItems', type: 'number', cellAttributes: { alignment: 'left' }},
            {label: '# Processed', fieldName: 'JobItemsProcessed', type: 'number', cellAttributes: { alignment: 'left' }},
            {label: '# Failed', fieldName: 'NumberOfErrors', type: 'number', cellAttributes: { alignment: 'left' }},
            {label: 'Submitted By', fieldName: 'SubmittedBy', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'datetime'},
        ]);

        helper.initializeData(component, event);
    },
    executeBatchJS: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var batchName = event.getSource().get("v.name");
        var action = component.get("c.executeBatchableProcess");
        action.setParams({"batchName":batchName});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.showSpinner", false);
                var result = JSON.parse(response.getReturnValue());
            	var message = result["msg"];
                var success = result["isSuccess"];
                helper.initializeData(component, event);
                if(success == true ){
                    helper.showToast(component, batchName, "Success", "success", message);
                } else {
                    helper.showToast(component, batchName, "Error", "error", message);
                }
            }
            else{
                component.set("v.showSpinner", false);
                var error = response.getError();
            	helper.showToast(component, batchName, "Error", "error", "Following error occurred while submitting batch for execution " + error);
            }
            
        });
        $A.enqueueAction(action);
    }
})