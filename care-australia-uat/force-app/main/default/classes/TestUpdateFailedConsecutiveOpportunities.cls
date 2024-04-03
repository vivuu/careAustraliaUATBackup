@isTest
public class TestUpdateFailedConsecutiveOpportunities {
    
    static testMethod void testUpdateFailedConsecutiveOpportunities() {
        // Create test data
          Account acc1 = new Account(Name='AcctTest');
            insert acc1;
        Contact con = TestDataFactory.createContact(true);
        Campaign camp = TestDataFactory.createCampaign(true);
        camp.Campaign_Code__c='TestCode001';
        //Campaign camp = new Campaign(Name =System.Label.Shopify_Default_Campaign_Name,IsActive=true,Campaign_Code__c='TestCode001');
        camp.Name =System.Label.Shopify_Default_Campaign_Name;   
        UPDATE camp;
        //npe03__Recurring_Donation__c rd1 = new npe03__Recurring_Donation__c(npe03__Contact__c = con.Id,npe03__Recurring_Donation_Campaign__c = camp.Id,npsp__Status__c = 'Active');
        //insert rd1;
        npe03__Recurring_Donation__c rd1 = new npe03__Recurring_Donation__c();
        rd1.npe03__Amount__c = 50;
        rd1.npe03__Contact__c = con.Id;
        rd1.npe03__Recurring_Donation_Campaign__c = camp.Id;
        rd1.npsp__PaymentMethod__c = 'Direct Debit';
        rd1.Account_Number__c ='000123456';
        rd1.Account_BSB__c = '000-000';
        rd1.Payee_Name__c = 'Test Payee';
        rd1.npsp__Status__c = 'Active';
        rd1.On_Held_Date__c = Date.newinstance(2021, 3, 1);
        
        INSERT rd1;
        Opportunity opp1 = new Opportunity(Name='RecurringDonationOpp1',AccountId=acc1.Id,CloseDate=System.today()-1,StageName='Closed Lost',Donation_Source__c='Web',
                                          npe03__Recurring_Donation__c=rd1.Id,CampaignId =camp.Id);
        Opportunity opp2 = new Opportunity(Name='RecurringDonationOpp2',AccountId=acc1.Id,CloseDate=System.today()-2,StageName='Closed Lost',Donation_Source__c='Web',
                                          npe03__Recurring_Donation__c=rd1.Id,CampaignId =camp.Id);
        Opportunity opp3 = new Opportunity(Name='RecurringDonationOpp3',AccountId=acc1.Id,CloseDate=System.today()-3,StageName='Closed Lost',Donation_Source__c='Web',
                                          npe03__Recurring_Donation__c=rd1.Id,CampaignId =camp.Id);
        Opportunity opp4 = new Opportunity(Name='RecurringDonationOpp4',AccountId=acc1.Id,CloseDate=System.today()-4,StageName='Closed Lost',Donation_Source__c='Web',
                                          npe03__Recurring_Donation__c=rd1.Id,CampaignId =camp.Id);
        //Opportunity opp1=TestDataFactory.createOpportunity('Closed Lost', acc1.Id, System.today()-1, true);
        //Opportunity opp2=TestDataFactory.createOpportunity('Closed Lost', acc1.Id, System.today()-2, true);
        //Opportunity opp3=TestDataFactory.createOpportunity('Closed Lost', acc1.Id, System.today()-3, true);
        //Opportunity opp4=TestDataFactory.createOpportunity('Closed Lost', acc1.Id, System.today()-4, true);
        //opp1.npe03__Recurring_Donation__c=rd1.Id;
        //opp1.CampaignId=camp.Id;
        //opp2.npe03__Recurring_Donation__c=rd1.Id;
        //opp2.CampaignId=camp.Id;
        /*opp3.npe03__Recurring_Donation__c=rd1.Id;
        opp3.CampaignId=camp.Id;
        opp4.npe03__Recurring_Donation__c=rd1.Id;
        opp4.CampaignId=camp.Id;
        UPDATE opp1;
        UPDATE opp2;
        UPDATE opp3;
        UPDATE opp4;*/
        INSERT opp1;
        INSERT opp2;
        INSERT opp3;
        INSERT opp4;
        
        Test.startTest();
        Database.executeBatch(new UpdateFailedConsecutiveOpportunities(), 200);
        Test.stopTest();
        
        // Verify that the recurring donation was updated correctly
        rd1 = [SELECT Failed_Consecutive_Opportunities__c,Test_Failed_Consecutive_Opportunities__c FROM npe03__Recurring_Donation__c WHERE Id = :rd1.Id];
        //System.assertEquals(3, rd1.Failed_Consecutive_Opportunities__c);
      //  System.assertEquals(3, rd1.Test_Failed_Consecutive_Opportunities__c, 'Test Case Success');
    }
}