({
	doInit : function(component, event, helper) {
        console.log('In controller');
		var startURL = component.get('v.redirectURL');
        location.href(startURL);
        //helper.invoke(component);
	}
})