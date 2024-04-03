@RestResource(urlMapping='/NBHeartbeat/*')
global with sharing class NBHeartbeat {
    
    /**
     * The Heartbeat endpoing indicates to the Donation Bridge the status and version of the integration. A message can be sent to display to the user by setting System.Label.NBMessage.
     * Gordon Jackson October 2021 gordon@gordonjackson.org
     */
 	@HttpGet
    global static void doGet() {
        String versionNo = '';
        String message = '';
        List<Donation_Bridge_Settings__c> donationBridgeSettings = [ SELECT Version__c, End_user_Message__c from Donation_Bridge_Settings__c WHERE Active__c = true ];
        for (Donation_Bridge_Settings__c donationBridgeSetting : donationBridgeSettings) {
            if (donationBridgeSetting.Version__c == 'MESSAGE') {
                message = donationBridgeSetting.End_user_Message__c;
                versionNo = message;
            }
            else {
                versionNo = donationBridgeSetting.Version__c;
            }
            break;
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.responseBody = Blob.valueOf('{ "version" : "' + versionNo + '", "build" : "a", "message" : "' + message + '" }');
    }
}