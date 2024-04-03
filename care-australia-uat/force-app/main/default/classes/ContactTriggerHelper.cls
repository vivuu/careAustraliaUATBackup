public class ContactTriggerHelper {
    public static void updateContactDetails(List<Contact> contactList){
        List<Id> accountId = new List<Id>();
        for(Contact con: contactList){
            if(con.AccountId != null){
                accountId.add(con.AccountId);
            }
        }
        if(!accountId.isEmpty()){
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Contact_Update_Data__c FROM Account WHERE Id IN: accountId ]);
            for(Contact con: contactList){
                Account acc = accountMap.get(con.AccountId);
                if(acc.Contact_Update_Data__c != null){
                    Map<String,Object> contactDetails = (Map<String,Object>)JSON.deserializeUntyped(acc.Contact_Update_Data__c);
                    con.MailingPostalCode =(String)contactDetails.get('MailingPostalCode');
                    con.MobilePhone = (String)contactDetails.get('MobilePhone');
                    con.Salutation = (String)contactDetails.get('Salutation');
                    con.Birthdate = Date.valueOf((String)contactDetails.get('Birthdate'));
                    con.IsLender__c = (Boolean)contactDetails.get('IsLender__c');
                    con.Terms_and_conditions__c = (Boolean)contactDetails.get('Terms_and_conditions__c');
                }
            }
        }
    }
}