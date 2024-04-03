@isTest
private class OppAppealCodeBatchTest {
   @isTest
    private static void testOpportunityBatch()
    {
        Campaign cam1 = new Campaign(Name =System.Label.Shopify_Default_Campaign_Name,IsActive=true,Campaign_Code__c='TestCode001');
            insert cam1;
        Campaign cam2 = new Campaign(Name =System.Label.Shopify_Default_Campaign_Name,IsActive=true,Campaign_Code__c='TestCode');
            insert cam2;
        Account acc1 = new Account(Name='AcctTest');
            insert acc1;
        Opportunity opp1 = new Opportunity(Name='CAREGift1',AccountId=acc1.Id,CloseDate=Date.parse('20/09/2022'),StageName='Prospecting',Donation_Source__c='Web',
                                          Donation_URL__c='test/testcampaign/appealcode=TestCode',CampaignId =cam1.Id);
        insert opp1;
        OppAppealCodeBatch b = new OppAppealCodeBatch();
        database.executeBatch(b, 100);
    }

}