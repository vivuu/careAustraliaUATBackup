@istest
public class contactAfterUpdate_TDTM_Test {
    @testSetup 
    public static void setup() {
        List<npe03__Recurring_Donation__c> rdList =  new  List<npe03__Recurring_Donation__c>();
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        for(Integer i=0 ;i <10;i++)
        {
            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
            rd.npe03__Amount__c = 50;
            rd.npe03__Contact__c = con.Id;
            rd.npsp__PaymentMethod__c = 'Credit Card';
            rd.Card_Token__c ='123';
            rd.Card_Number_Masked__c = '123456780000';
            rd.Payee_Name__c = 'Test Payee';
            rd.Card_Type__c = 'Visa';
            rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
            rdList.add(rd);
        }
        system.debug('rdList***'+rdList);
        insert rdList;
    }
    @isTest 
    public static void testmethod1_ContactWithoutDeceasedDate(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Contact After Update';
        th.npsp__Class__c = 'contactAfterUpdate_TDTM';
        th.npsp__Object__c = 'Contact';
        th.npsp__Trigger_Action__c = 'AfterUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 2;
        th.npsp__Asynchronous__c = false;
        
        triggerHandlers.add(th);
        
        contact con = [Select Id from Contact limit 1];
        test.startTest();
        con.npsp__Deceased__c = true;
        update con;
        test.stopTest();
        system.debug('con***'+con);
        List<npe03__Recurring_Donation__c> rdUpdatedList = [Select Id,npsp__Status__c,Cancellation_Date__c,npsp__ClosedReason__c from npe03__Recurring_Donation__c] ;
        system.debug('rdUpdatedList***'+rdUpdatedList);
        for(npe03__Recurring_Donation__c rd : rdUpdatedList){
            System.assertEquals(rd.npsp__Status__c, 'Cancelled');
            System.assertEquals(rd.npsp__ClosedReason__c, 'Deceased');
                System.assertEquals(rd.Cancellation_Date__c, System.today());
        }
    }
    @isTest 
    public static void testmethod2_ContactWithDeceasedDate(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Contact After Update';
        th.npsp__Class__c = 'contactAfterUpdate_TDTM';
        th.npsp__Object__c = 'Contact';
        th.npsp__Trigger_Action__c = 'AfterUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 2;
        th.npsp__Asynchronous__c = false;
        
        triggerHandlers.add(th);
        
        contact con = [Select Id from Contact limit 1];
        test.startTest();
        con.npsp__Deceased__c = true;
        con.Deceased_Date__c = System.today() +2;
        update con;
        test.stopTest();
        system.debug('con***'+con);
        List<npe03__Recurring_Donation__c> rdUpdatedList = [Select Id,npsp__Status__c,Cancellation_Date__c,npsp__ClosedReason__c from npe03__Recurring_Donation__c] ;
        system.debug('rdUpdatedList***'+rdUpdatedList);
        for(npe03__Recurring_Donation__c rd : rdUpdatedList){
            System.assertEquals(rd.npsp__Status__c, 'Cancelled');
            System.assertEquals(rd.npsp__ClosedReason__c, 'Deceased');
                System.assertEquals(rd.Cancellation_Date__c, System.today() +2);
        }
    }
    
        @isTest 
    public static void testmethod_ContactEmailUpdate(){
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Contact After Update';
        th.npsp__Class__c = 'contactAfterUpdate_TDTM';
        th.npsp__Object__c = 'Contact';
        th.npsp__Trigger_Action__c = 'AfterUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 2;
        th.npsp__Asynchronous__c = false;
        
        triggerHandlers.add(th);
        
        contact con = [Select Id,Email from Contact limit 1];
        con.Email = 'test@test.com';
        test.startTest();
        update con;
        test.stopTest();
        
        List<npe03__Recurring_Donation__c> rdList = [Select Id,Donor_Email__c From npe03__Recurring_Donation__c];
        for(npe03__Recurring_Donation__c rd : rdList){
            System.assertEquals('test@test.com', rd.Donor_Email__c);
        }
        
        List<npe01__OppPayment__c> paymentList = [Select Id,Donor_Email__c From npe01__OppPayment__c];
        for(npe01__OppPayment__c payment : paymentList){
            System.assertEquals('test@test.com', payment.Donor_Email__c);
        }
    }
}