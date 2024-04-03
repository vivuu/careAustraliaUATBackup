/**
* Name			:		CareCustomLoginCtrl
* Date			:		10/07/2023
* Author		:		Saravanan P
* Description	:		Used for lender registration process 
*/
public  without sharing class CareCustomLoginCtrl {
    @AuraEnabled
    public static contact updateContact (contact insertContact)
    {
        try{
            update insertContact;
            return insertContact;
        }catch(Exception e){
             LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='CareCustomLoginCtrl', MethodName__c='updateContact', 
                                                        Exception_Type__c='Error', Description__c=e.getMessage(), 
                                                        StackTrace__c=e.getStackTraceString());
            insert err;
            return null;
        }
    }
    @Auraenabled(cacheable=true)
    public static Contact getContactbyUserID(String userID)
    {
        try
        {
             if(userID!=null){
            user users=[select id,lastName,firstName,email,ContactId from user where id=:userID];
            contact lenderContact = [select Id,Salutation,MailingPostalCode,Birthdate,lastName,firstName,email,Terms_and_conditions__c,MobilePhone from contact where Id=:users.ContactId AND recordtypeId=:Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Supporter').getRecordTypeId()];      
            return lenderContact; 
        }else{
            return null;   
        }
        }catch(Exception e){
            return null;
        }
       
        
        
    }
    
}