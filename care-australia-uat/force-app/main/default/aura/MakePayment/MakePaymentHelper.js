({
	showWarningToast: function(component,warningMsg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Warning!",
            type: "warning",
            mode: "pester",
            message: warningMsg
        });
        toastEvent.fire();
    },
})