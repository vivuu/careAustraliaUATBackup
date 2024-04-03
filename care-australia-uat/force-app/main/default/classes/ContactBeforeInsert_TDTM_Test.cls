@isTest
public class ContactBeforeInsert_TDTM_Test {
    @isTest public static void positiveSecnarions(){
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Contact Trigger Handler';
        th.npsp__Class__c = 'ContactBeforeInsert_TDTM';
        th.npsp__Object__c = 'Contact';
        th.npsp__Trigger_Action__c = 'BeforeInsert;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
         // set up test data
        test.startTest();

        Contact c =new Contact();
        c.LastName = 'Test Shopify Mobile Phone';
        c.HIC_ShopifySync__Shopify_Id__c = 'Business 12323589174006';
        c.Shopify_Phone_Number__c = '041234567';
        insert c;
        
        
        Contact c1 =new Contact();
        c1.LastName = 'Test Shopify Home Phone';
        c1.HIC_ShopifySync__Shopify_Id__c = 'Business 22456589174006';
        c1.Shopify_Phone_Number__c = '021234567';
        insert c1;
            

        test.stopTest();
    }

}