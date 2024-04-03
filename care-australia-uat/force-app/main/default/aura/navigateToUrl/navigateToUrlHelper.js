({    invoke : function(component) {
    console.log('Inside aura');
    var logoutURL = $A.get("$Label.c.Logout_URL_of_Lender");
    window.location.replace(logoutURL);
 
}});