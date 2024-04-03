@istest
private class Payment_OppLineItem_TH_TDTM_Test {
    static testMethod void test_PaymentCareGiftOpportunity_TDTM() {
        // Retrieve default NPSP Trigger Handlers
		List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

		// Add our Trigger Handler to cached Trigger Handlers
		npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'CareGiftPaymentOppTriggerHandler';
		th.npsp__Class__c = 'Payment_OppLineItem_TriggerHandler_TDTM';
		th.npsp__Object__c = 'npe01__OppPayment__c';
		th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;';
		th.npsp__Active__c = true;
		th.npsp__Load_Order__c = 3;
		th.npsp__Asynchronous__c = false;

		triggerHandlers.add(th);
        
   		Account account_test = new Account(Name='AccountOrg');
        insert account_test;
        
        Contact contact_test = new Contact(FirstName = 'John', LastName = 'Smith',AccountId=account_test.Id);
		insert contact_test; 
        
        Campaign campaign_test = new Campaign(Name ='Catalogue General Internet');
        insert campaign_test;
        
        Opportunity opportunity_test = new Opportunity(Name='Opp-CAREGift1',AccountId=account_test.Id,CloseDate=Date.Today(),StageName='Prospecting',HIC_ShopifySync__Payment_Status__c='Paid');
        opportunity_test.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('CARE Gift').getRecordTypeId();
        opportunity_test.CampaignId = campaign_test.Id;
        insert opportunity_test;
        
        Product2 product2_test = new Product2(Name='A Bike',IsActive=true);
        insert product2_test;
        
        // insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = product2_test.Id;
        standardPrice.UnitPrice = 140;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        OpportunityLineItem OppLineItem_test = new OpportunityLineItem(OpportunityId=opportunity_test.Id,Product2Id=product2_test.Id,PricebookEntryId=standardPrice.id,Quantity=1,UnitPrice=140.00);
        insert OppLineItem_test;
        
        npe01__OppPayment__c payment_test = new npe01__OppPayment__c(npe01__Opportunity__c =opportunity_test.Id,npe01__Payment_Amount__c= OppLineItem_test.TotalPrice);
        Test.startTest();
        insert payment_test;
        Test.stopTest();
        OpportunityLineItem OppLineItem_compare = [Select Id, Payment__c  FROM OpportunityLineItem where Id=:OppLineItem_test.Id];
       // System.assertEquals(payment_test.Id,OppLineItem_compare.Payment__c);
        
    }

}