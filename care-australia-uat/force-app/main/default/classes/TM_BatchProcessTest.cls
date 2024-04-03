@isTest
public class TM_BatchProcessTest {
    
    @isTest public static void positiveScenarios1(){
        
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        con.npe01__PreferredPhone__c = 'Mobile';
        con.MobilePhone = '+61123456788';
        con.MailingCountry = 'Australia';
        con.Telemarketing_Selection_Criteria__c = 'Upgrades';
        insert con;
        
        Donor_Constituency__c dc = new Donor_Constituency__c();
        dc.Constituency_Type__c = 'Regular Giver';
        dc.Contact__c = con.Id;
        dc.Start_Date__c = Date.newInstance(2021, 10, 13);
        insert dc;
        
        Campaign camp2 = new Campaign();
        camp2.Name = 'Test Camp';
        camp2.Channel__c = 'Telemarketing';
        camp2.IsActive = true;
        insert camp2;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Camp';
        camp.Channel__c = 'Telemarketing';
        camp.IsActive = true;
        camp.Status = 'In Progress';
        camp.ParentId = camp2.Id;
        insert camp;
        
        CampaignMember campMem = new CampaignMember();
        campMem.ContactId = con.Id;
        campMem.Action_Date__c = Date.newInstance(2021, 15, 10);
        campMem.Call_Type__c = 'C2C';
        campMem.Status = 'Responded';
        campMem.Telemarketing_Result__c = 'Refusal';
        campMem.CampaignId = camp.Id;
        insert campMem;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.ContactId = con.Id;
        opp.CloseDate = Date.newInstance(2021, 10, 13);
        opp.StageName = 'Closed Won';
        opp.Amount = 70;
        opp.CampaignId = camp.Id;
        insert opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2';
        opp2.RecordTypeId = oppRecType;
        opp2.ContactId = con.Id;
        opp2.CloseDate = Date.newInstance(2021, 10, 13);
        opp2.StageName = 'Closed Won';
        opp2.Amount = 120;
        opp2.CampaignId = camp.Id;
        insert opp2;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp2.Id;
        pay.npe01__Paid__c = true;
        pay.npe01__Payment_Amount__c = 0;
        insert pay;
        
        npe01__OppPayment__c pay2 = new npe01__OppPayment__c();
        pay2.npe01__Opportunity__c = opp2.Id;
        pay2.npe01__Paid__c = true;
        pay2.npe01__Payment_Amount__c = 0;
        insert pay2;
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Date_Established__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Amount__c = 250;
        rd.npsp__Day_of_Month__c = '1';
        rd.npe03__Installment_Period__c = 'Monthly';
        rd.npsp__StartDate__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__Status__c = 'Active';
        insert rd;
        
        test.startTest();
        TM_ConversionSelectionCriteriaBatch ba= new TM_ConversionSelectionCriteriaBatch();
        Id jobid= Database.executeBatch(ba,5);
        test.stopTest();
    }
    
    @isTest public static void declineScenarios1(){
        
         Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        con.npe01__PreferredPhone__c = 'Mobile';
        con.MobilePhone = '+61123456788';
        con.MailingCountry = 'Australia';
        con.Telemarketing_Selection_Criteria__c = 'Upgrades';
        insert con;
        
        Campaign camp2 = new Campaign();
        camp2.Name = 'Test Camp';
        camp2.Channel__c = 'Telemarketing';
        camp2.IsActive = true;
        insert camp2;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Camp';
        camp.Channel__c = 'Telemarketing';
        camp.IsActive = true;
        camp.Status = 'In Progress';
        camp.ParentId = camp2.Id;
        insert camp;
        
        CampaignMember campMem = new CampaignMember();
        campMem.ContactId = con.Id;
        campMem.Action_Date__c = Date.newInstance(2021, 15, 10);
        campMem.Call_Type__c = 'C2C';
        campMem.Status = 'Responded';
        campMem.Telemarketing_Result__c = 'Refusal';
        campMem.CampaignId = camp.Id;
        insert campMem;
        
        
         npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Date_Established__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Amount__c = 250;
        rd.npsp__Day_of_Month__c = '1';
        rd.npe03__Installment_Period__c = 'Monthly';
        rd.npsp__StartDate__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__Status__c = 'Active';
        insert rd;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2';
        opp2.RecordTypeId = oppRecType;
        opp2.ContactId = con.Id;
        opp2.CloseDate = Date.newInstance(2021, 10, 13);
        opp2.StageName = 'Closed Won';
        opp2.Amount = 120;
        opp2.CampaignId = camp.Id;
        opp2.npe03__Recurring_Donation__c = rd.Id;
        insert opp2;
        
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp2.Id;
        pay.npe01__Paid__c = true;
        pay.npe01__Payment_Amount__c = 0;
        pay.npe01__Payment_Date__c = Date.newInstance(2021, 9, 9);
        insert pay;
        
        npe01__OppPayment__c pay2 = new npe01__OppPayment__c();
        pay2.npe01__Opportunity__c = opp2.Id;
        pay2.npe01__Paid__c = true;
        pay2.npe01__Payment_Amount__c = 0;
        pay.npe01__Payment_Date__c = Date.newInstance(2021, 10, 10);
        insert pay2;
        
        opp2.Bounced_Payments__c = 3;
        update opp2;

        Donor_Constituency__c dc = new Donor_Constituency__c();
        dc.Constituency_Type__c = 'Major Donor';
        dc.Contact__c = con.Id;
        dc.Start_Date__c = Date.newInstance(2021, 10, 13);
        insert dc;        
        
        test.startTest();
        TM_DeclineSelectionCriteriaBatch ba= new TM_DeclineSelectionCriteriaBatch();
        Id jobid= Database.executeBatch(ba,5);
        test.stopTest();
    }
    
    @isTest public static void reactivatesScenarios1(){
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        con.npe01__PreferredPhone__c = 'Mobile';
        con.MobilePhone = '+61123456788';
        con.MailingCountry = 'Australia';
        insert con;
        
        Donor_Constituency__c dc = new Donor_Constituency__c();
        dc.Constituency_Type__c = 'Regular Giver';
        dc.Contact__c = con.Id;
        dc.Start_Date__c = Date.newInstance(2021, 10, 13);
        insert dc;
        
        Campaign camp2 = new Campaign();
        camp2.Name = 'Test Camp';
        camp2.Channel__c = 'Telemarketing';
        camp2.IsActive = true;
        insert camp2;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Camp';
        camp.Channel__c = 'Telemarketing';
        camp.IsActive = true;
        camp.Status = 'In Progress';
        camp.ParentId = camp2.Id;
        insert camp;
        
        CampaignMember campMem = new CampaignMember();
        campMem.ContactId = con.Id;
        campMem.Action_Date__c = Date.newInstance(2021, 15, 10);
        campMem.Call_Type__c = 'C2C';
        campMem.Status = 'Responded';
        campMem.Telemarketing_Result__c = 'Refusal';
        campMem.CampaignId = camp.Id;
        insert campMem;
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Date_Established__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Amount__c = 250;
        rd.npsp__Day_of_Month__c = '1';
        rd.npe03__Installment_Period__c = 'Monthly';
        rd.npsp__StartDate__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__Status__c = 'Cancelled';
        insert rd;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2';
        opp2.RecordTypeId = oppRecType;
        opp2.ContactId = con.Id;
        opp2.CloseDate = Date.newInstance(2021, 10, 13);
        opp2.StageName = 'Closed Won';
        opp2.Amount = 120;
        opp2.CampaignId = camp.Id;
        opp2.npe03__Recurring_Donation__c = rd.Id;
        insert opp2;
        
        test.startTest();
        TM_ReactivatesSelectionCriteriaBatch ba= new TM_ReactivatesSelectionCriteriaBatch();
        Id jobid= Database.executeBatch(ba,5);
        test.stopTest();
    }
    
    @isTest public static void upgradesScenarios1(){
        
         Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
        
        Contact con = new Contact();
        con.LastName = 'Test Con 1';
        con.npe01__PreferredPhone__c = 'Mobile';
        con.MobilePhone = '+61123456788';
        con.MailingCountry = 'Australia';
        con.Telemarketing_Selection_Criteria__c = 'Upgrades';
        insert con;
        
        Donor_Constituency__c dc = new Donor_Constituency__c();
        dc.Constituency_Type__c = 'Regular Giver';
        dc.Contact__c = con.Id;
        dc.Start_Date__c = Date.newInstance(2021, 10, 13);
        insert dc;
        
        Campaign camp2 = new Campaign();
        camp2.Name = 'Test Camp';
        camp2.Channel__c = 'Telemarketing';
        camp2.IsActive = true;
        insert camp2;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Camp';
        camp.Channel__c = 'Telemarketing';
        camp.IsActive = true;
        camp.Status = 'In Progress';
        camp.ParentId = camp2.Id;
        insert camp;
        
        CampaignMember campMem = new CampaignMember();
        campMem.ContactId = con.Id;
        campMem.Action_Date__c = Date.newInstance(2021, 15, 10);
        campMem.Call_Type__c = 'C2C';
        campMem.Status = 'Responded';
        campMem.Telemarketing_Result__c = 'Refusal';
        campMem.CampaignId = camp.Id;
        insert campMem;
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Contact__c = con.Id;
        rd.npe03__Date_Established__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Amount__c = 250;
        rd.npsp__Day_of_Month__c = '1';
        rd.npe03__Installment_Period__c = 'Monthly';
        rd.npsp__StartDate__c = Date.newInstance(2021, 10, 13);
        rd.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd.npsp__Status__c = 'Held';
        rd.npsp__PaymentMethod__c = 'Credit Card';
        insert rd;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2';
        opp2.RecordTypeId = oppRecType;
        opp2.ContactId = con.Id;
        opp2.CloseDate = Date.newInstance(2021, 10, 13);
        opp2.StageName = 'Closed Won';
        opp2.Amount = 120;
        opp2.CampaignId = camp.Id;
        opp2.npe03__Recurring_Donation__c = rd.Id;
        opp2.Number_of_Consecutive_payments__c = 6;
        insert opp2;
        
        Date dt = Date.newInstance(2023, 10, 13);
        Test.setCreatedDate(rd.Id, dt);
        test.startTest();
        TM_SelectionCriteriaBatch ba= new TM_SelectionCriteriaBatch();
        Id jobid= Database.executeBatch(ba,5);
        test.stopTest();
    }
}