({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRDRecords");
        var rdId = component.get("v.recordId");
        action.setParams({
            "rdId": rdId,
        });
        var self = this;
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                //helper.showSuccessToast(component,"SDX Service Updated");
                var recurringDonation=actionResult.getReturnValue();
                component.set("v.recurringDonation",recurringDonation );
                component.set("v.initMethodCompleted",true);
                component.set("v.iframeLink",'/apex/RDTokenizationVisualforce?id='+recurringDonation.Id);
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.showSpinner",false);
                    }), 2500);
                /*if(recurringDonation.npsp__PaymentMethod__c == 'Credit Card'){
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showSpinner",false);
                        }), 2500);
                }else{
                    $A.get("e.force:closeQuickAction").fire();  
                    let showToast = $A.get( "e.force:showToast" );
                    showToast.setParams({
                        title : 'Warning!',
                        message : 'Payment method is not Credit Card.' ,
                        type : 'warning',
                        mode : 'pester'
                    });
                    showToast.fire();
                }*/
                
            }else{
                this.showErrorToast(component,actionResult.getError()[0].message);  
            }
            
        });
        $A.enqueueAction(action);
    }
    
})