/**
* Class Name: StripeCustomLookupCtrl
* Auhtor: Gerent Team
* Description: Used by StripeCustomLookup LWC
* Modification Details:  - 10/10/2022 - Initial version created
* Test Class and Coverage:  - StripeCustomLookupCtrlTest - 92%
* */
public with sharing class StripeCustomLookupCtrl {
    // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName,string whereClause) {  
        if(Stripe_Setting__c.getValues('Default').Activation__c){
        	List < sObject > returnList = new List < sObject > ();
    
            string sWildCardText = '%' + searchKey + '%';
            string sQuery = 'Select Id,Name From ' + sObjectApiName;
            sQuery+=' Where Name Like : sWildCardText';
            if(whereClause!=null && whereClause!=''){
                sQuery+=' AND '+whereClause;
            }
            sQuery+=' order by createdDate DESC LIMIT 5';
            System.debug('sQuery'+sQuery);
            for (sObject obj: database.query(sQuery)) {
                returnList.add(obj);
            }
            return returnList;    
        }
        return null;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        if(Stripe_Setting__c.getValues('Default').Activation__c){
         	string sRecId = recordId;    
            string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
            for (sObject obj: database.query(sQuery)) {
                return obj;
            }   
        }
        return null;
    }
}