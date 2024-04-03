({ 
    doInit : function(component, event, helper) {
        var self = this;
        var action = component.get("c.getRD");
        var idToUse = component.get("v.recordId");
        var toastEvent = $A.get("e.force:showToast");
        action.setParams({
            "recId": idToUse
        });
        
        var self = this;
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                let rd = actionResult.getReturnValue();
                component.set("v.recurringDonation",actionResult.getReturnValue() );
                component.set("v.month",rd.npsp__CardExpirationMonth__c );
                component.set("v.year",rd.npsp__CardExpirationYear__c );
                component.set("v.showSpinner", false);
                component.set("v.initMethodCompleted", true);
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
        
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        
        var monthCmp = component.find("month");
        var yearCmp = component.find("year");
        if(monthCmp.checkValidity() &&  yearCmp.checkValidity()){
            let month,year;
        month = component.get('v.month');
        year = component.get('v.year');
        
        let rd = component.get("v.recurringDonation");
        
        
        if(month != rd.npsp__CardExpirationMonth__c || year != rd.npsp__CardExpirationYear__c){
            
            helper.updateExpiry(component, event, helper);
        }else{
            toastEvent.setParams({
                "title": "Warning!",
                "message": "Please change the values before submit.",
                "type":"warning"
            });
            toastEvent.fire();
        }
        }else{
            toastEvent.setParams({
                "title": "Warning!",
                "message": "Please check Month & Year before Update.",
                "type":"warning"
            });
            toastEvent.fire();
        }
        
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    showToast : function(component, event, helper) {
        
        
    },
    handleMonthBlur: function(component, event, helper) {
        let month = component.get('v.month');
        var monthCmp = component.find("month");
        let text = /^[0-9]+$/;
        if (((month != "") && (!text.test(month))) || !(parseInt(month)>0 && parseInt(month) <13)) {
            //alert("Year is not proper. Please check");
            monthCmp.setCustomValidity("Month is not proper. Please check");
        }else{
            monthCmp.setCustomValidity("");
        }
        monthCmp.reportValidity();
    },
    handleYearBlur: function(component, event, helper) {
        let year = component.get('v.year');
        var yearCmp = component.find("year");
        
        let text = /^[0-9]+$/;
        let current_year=new Date().getFullYear();
        if (((year != "") && (!text.test(year))) || year.length != 4) {
            //alert("Year is not proper. Please check");
            yearCmp.setCustomValidity("Year is not proper. Please check");
        }else if(year < current_year){
            //alert("Your card's expiration year is in the past.");
            yearCmp.setCustomValidity("Your card's expiration year is in the past.");
        }else{
            yearCmp.setCustomValidity("");
        }
        yearCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
    }
})