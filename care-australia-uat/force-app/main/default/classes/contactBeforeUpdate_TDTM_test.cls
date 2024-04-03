@isTest
public class contactBeforeUpdate_TDTM_test {
    @isTest public static void positiveSecnarions(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Contact Trigger Handler';
        th.npsp__Class__c = 'contactBeforeUpdate_TDTM';
        th.npsp__Object__c = 'Contact';
        th.npsp__Trigger_Action__c = 'BeforeUpdate;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
        
        // set up test data
        test.startTest();
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        con.RTS_Received_Date__c = Date.newInstance(2021, 12, 8);
        insert con;
        con.RTS_Received_Date__c = Date.newInstance(2021, 13, 8);
        update con;
        con.RTS_Received_Date__c = Date.newInstance(2021, 14, 8);
        update con;
        con.RTS_Received_Date__c = Date.newInstance(2021, 15, 8);
        update con;
        con.MailingCity = 'Pune';
        update con;
        con.npsp__Do_Not_Contact__c = true;
        update con;
        test.stopTest();
    }
}