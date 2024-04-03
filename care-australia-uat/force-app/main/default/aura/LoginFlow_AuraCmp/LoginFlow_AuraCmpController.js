({
	init : function (component) {
        
        //Get current User Id
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        
        // Initilise flow input params
         var inputVariables = [
        		{ name : "LoginFlow_UserId", type : "String", value: userId }, 
         		{ name : "LoginFlow_Platform", type : "String", value: 'Browser' }
       		];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Login_OTP_Based_Flow", inputVariables);
    },
})