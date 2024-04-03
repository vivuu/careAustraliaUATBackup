@isTest
public class ContactTriggerHelperTest {
	@isTest
    public static void testM1(){
        Map<String,Object> contactMap = new Map<String,Object>();
        contactMap.put('Email','test@test.com');
        contactMap.put('Birthdate','1953-01-22');
        contactMap.put('MobilePhone','+6111111111111');
        contactMap.put('Terms_and_conditions__c',true);
        contactMap.put('MailingPostalCode','1235');
        contactMap.put('IsLender__c',true);
        contactMap.put('Salutation','Mr.');
                       
        Account portalAccount = new Account();
        portalAccount.Name = 'Test ' + ' Household';
        portalAccount.Contact_Update_Data__c = JSON.serialize(contactMap);
        portalAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        insert portalAccount;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Last';
        con.Email ='test@test.com';
        con.AccountId = portalAccount.Id;
        
        Test.startTest();
        insert con;
        Test.stopTest();
        
    }
}