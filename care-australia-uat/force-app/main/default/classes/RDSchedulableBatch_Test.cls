@istest
public  class RDSchedulableBatch_Test {
    @testSetup 
    public static void setup() {
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        
        List<npe03__Recurring_Donation__c> rdList =  new  List<npe03__Recurring_Donation__c>();
        for(Integer i=0 ;i <100;i++)
        {
            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
            rd.npe03__Amount__c = 50;
            rd.npe03__Contact__c = con.Id;
            rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
            rd.npsp__PaymentMethod__c = 'Credit Card';
            rd.Card_Token__c ='123';
            rd.Card_Number_Masked__c = '123456780000';
            rd.Payee_Name__c = 'Test Payee';
            rd.Card_Type__c = 'Visa';
            rd.npsp__Status__c = 'Held';
            rd.On_Held_Date__c = Date.newinstance(2021, 3, 1);
            rdList.add(rd);
        }
         DateTime dT = System.now();
        for(Integer i=0 ;i <100;i++)
        {
            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
            rd.npe03__Amount__c = 100;
            rd.npe03__Contact__c = con.Id;
            rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
            rd.npsp__PaymentMethod__c = 'Credit Card';
            rd.Card_Token__c ='123';
            rd.Card_Number_Masked__c = '123456780000';
            rd.Payee_Name__c = 'Test Payee';
            rd.Card_Type__c = 'Visa';
            rd.npsp__Status__c = 'Active';
            rd.npe03__Date_Established__c =  Date.newinstance(dT.year()-1, dT.month(), dT.day());
            rd.Auto_Upgrade_Amount__c = 50;
            rdList.add(rd);
        }
        insert rdList;
    }
    @isTest 
    public static void testmethod1(){
        List<npe03__Recurring_Donation__c> rdList =  [SELECT Id,npe03__Amount__c,npe03__Date_Established__c, Auto_Upgrade_Amount__c, 
                                                      Cancellation_Date__c,npsp__Status__c,npsp__ClosedReason__c,Failed_Consecutive_Opportunities__c,On_Held_Limit__c
                                                      FROM npe03__Recurring_Donation__c ];
       

        Test.startTest();
        RDSchedulableBatch RDSB = new RDSchedulableBatch();
        DataBase.executeBatch(RDSB); 
        Test.stopTest();
        List<npe03__Recurring_Donation__c> rdCancelledList = [SELECT Id,Cancellation_Date__c,npsp__Status__c,npsp__ClosedReason__c
                                                              FROM npe03__Recurring_Donation__c where npsp__Status__c = 'Cancelled'];
        List<npe03__Recurring_Donation__c> rdActive= [SELECT Id,npe03__Amount__c,npsp__Status__c,Auto_Upgrade_Amount__c
                                                              FROM npe03__Recurring_Donation__c where npsp__Status__c = 'Active'];
        System.debug('rdCancelledList***'+rdCancelledList);
        System.debug('rdActive***'+rdActive);
        for(npe03__Recurring_Donation__c rd : rdCancelledList){
            system.assertEquals(rd.npsp__Status__c, 'Cancelled');
            system.assertEquals(rd.npsp__ClosedReason__c, 'Terminated from Held');
        }
        for(npe03__Recurring_Donation__c rd : rdActive){
            system.assertEquals(rd.npe03__Amount__c,150);
        }
        
        
    }
    
    @isTest 
    public static void testmethod2(){
        List<npe03__Recurring_Donation__c> rdList =  [SELECT Id,npe03__Amount__c,npe03__Date_Established__c, Auto_Upgrade_Amount__c, 
                                                      Cancellation_Date__c,npsp__Status__c,npsp__ClosedReason__c,Failed_Consecutive_Opportunities__c,On_Held_Limit__c
                                                      FROM npe03__Recurring_Donation__c ];
       

        Test.startTest();
        
        RDSchedulableBatch sh1 = new RDSchedulableBatch();

		String sch = '0 0 23 * * ?'; 
        system.schedule('Test RDSchedulableBatch', sch, sh1); 
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
   		System.assertEquals(1, jobsScheduled.size());
    	System.assertEquals('RDSchedulableBatch', jobsScheduled[0].ApexClass.Name);

    // check apex batch is in the job list
    }
   
}