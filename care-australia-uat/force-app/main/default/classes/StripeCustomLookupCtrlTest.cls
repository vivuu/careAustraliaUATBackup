@isTest
public with sharing class StripeCustomLookupCtrlTest {
    @TestSetup
    static void makeData(){
       Contact con=new Contact(FirstName='Test',LastName='TestLastName',email='lookup@testemail12.com');
       insert con;
        
        
        Campaign parentCampaign = new Campaign(Name='Recurring Donation', IsActive=true);
        insert parentCampaign;
        
        Campaign camp = new Campaign(Name='2022 CAREGifts', ParentId=parentCampaign.Id, IsActive=true);
        insert camp;
        
        
        //Added on 21-Oct
 		 Stripe_Setting__c recSetting = new Stripe_Setting__c();
		 recSetting.Name= 'Default';
		 recSetting.Default_Contact__c = con.id;
		 recSetting.Default_Campaign__c = camp.id;
		 recSetting.Activation__c = True;
		 insert recSetting;
    }

    @isTest
    static void fetchLookupDataTest(){
        Test.startTest();
        List<sobject> recordList=StripeCustomLookupCtrl.fetchLookupData('Test', 'contact','Name!=null');
        Contact con=(Contact) recordList.get(0);
        Test.stopTest();
        System.assertEquals('Test TestLastName', con.Name,'Name Must Be Same');
    }

    @isTest
    static void fetchDefaultRecordTest(){
        Contact exCon=[Select id,Name,FirstName from Contact Limit1];
        Test.startTest();
        sobject record=StripeCustomLookupCtrl.fetchDefaultRecord(exCon.Id, 'contact');
        Contact con=(Contact) record;
        Test.stopTest();
        System.assertEquals(exCon.Name, con.Name,'Name Must Be Same');
    }
}