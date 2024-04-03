@isTest
public class NBHeartbeatTest {
    static Donation_Bridge_Settings__c settingVersion;
    
    static void init() {
        settingVersion = new Donation_Bridge_Settings__c();
        settingVersion.Version__c = '1.0.0';
        settingVersion.Active__c = true;
        insert settingVersion;
    }
    
    static testMethod void nbHeartbeat() {
        init();
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/NBHeartbeat';
        request.httpMethod = 'Get';        
    
        RestContext.request = request;
        RestContext.response = response;
        
        NBHeartbeat.doGet(); 
        String response1 = RestContext.response.responseBody.toString();
		System.debug('Heartbeat Response: ' + response1);
		settingVersion.Version__c = 'MESSAGE';
        settingVersion.End_User_Message__c = 'TEST';
        update settingVersion;   
        NBHeartbeat.doGet(); 
        String response2 = RestContext.response.responseBody.toString();
		System.debug('Heartbeat Response: ' + response2);
        
        Test.stopTest();
        // Must change on version bumps to verify the correct version is being outputted to the Donation Bridge.
        System.assertEquals(response1, '{ "version" : "1.0.0", "build" : "a", "message" : "" }');
        System.assertEquals(response2, '{ "version" : "TEST", "build" : "a", "message" : "TEST" }');
    }

}