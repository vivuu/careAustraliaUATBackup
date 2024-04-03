/**
 * Class Name: ApexLogCreator
 * Auhtor: Gerent Team
 * Description: create a log in case of error genetation
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */

public class ApexLogCreator {
    // insert the error record in ApexDebugLog__c
    public static void createApexLog(String className, String errorMessage,String method, String stackTrace){
        // instace of ApexDebugLog__c
        ApexDebugLog__c log = new ApexDebugLog__c();
        log.ApexClass__c = className;
        if(errorMessage.length() < 131072){
        	log.Message__c = errorMessage;    
        }
        else{
            log.Message__c = errorMessage.substring(0, 131071);
        }
        log.Method__c = method;
        if(stackTrace.length() < 255){
        	log.StackTrace__c = stackTrace;    
        }
        else{
            log.StackTrace__c = stackTrace.substring(0, 254);
        }
        // insert the error record
        insert log;
    }
}