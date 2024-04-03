({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPaymentRecords");
        var paymentId = component.get("v.recordId");
        action.setParams({
            "paymentId": paymentId,
        });
        var self = this;
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                //helper.showSuccessToast(component,"SDX Service Updated");
                var payment=actionResult.getReturnValue();
                component.set("v.payment",payment );
                component.set("v.initMethodCompleted",true);
                component.set("v.iframeLink",'/apex/MakePaymentVisualforce?id='+payment.Id);
                if(payment.npe01__Written_Off__c == false){
                    if(payment.npe01__Paid__c == false){
                        if(payment.npe01__Payment_Amount__c != undefined){
                            if(payment.npe01__Opportunity__r.npe03__Recurring_Donation__c == null){
                                if(payment.npe01__Payment_Method__c == 'Credit Card'){
                                    window.setTimeout(
                                        $A.getCallback(function() {
                                            component.set("v.showSpinner",false);
                                        }), 2500);
                                }else{
                                    $A.get("e.force:closeQuickAction").fire();  
                                    helper.showWarningToast(component,'Payment method is not Credit Card.');
                                }
                            }else{
                                $A.get("e.force:closeQuickAction").fire();  
                                helper.showWarningToast(component,'Payment is related to Recurring Donation.');
                            }
                        }else{
                            $A.get("e.force:closeQuickAction").fire();  
                            helper.showWarningToast(component,'Please Provide valid Payment Amount.')
                        }
                        
                    }else{
                        $A.get("e.force:closeQuickAction").fire();  
                        helper.showWarningToast(component,'Payment is already paid.')
                    }
                }else{
                    $A.get("e.force:closeQuickAction").fire();  
                    helper.showWarningToast(component,'Payment is Written Off.')
                }
                
                
            }else{
                
                this.showErrorToast(component,actionResult.getError()[0].message);  
            }
            
        });
        $A.enqueueAction(action);
    }
})