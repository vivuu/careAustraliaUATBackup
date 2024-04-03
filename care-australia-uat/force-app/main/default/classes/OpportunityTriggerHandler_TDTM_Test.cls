@istest
private class OpportunityTriggerHandler_TDTM_Test {
   
        static testMethod void test_CareGiftOpportunity_TDTM() {
            List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
            // Add our Trigger Handler to cached Trigger Handlers
            npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
            th.Name = 'CareGiftOppTriggerHandler';
            th.npsp__Class__c = 'OpportunityTriggerHandler_TDTM';
            th.npsp__Object__c = 'Opportunity';
            th.npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate';
            th.npsp__Active__c = true;
            th.npsp__Load_Order__c = 3;
            th.npsp__Asynchronous__c = false;
            triggerHandlers.add(th);
            Account acc1 = new Account(Name='AcctTest');
            insert acc1;
            System.debug(acc1.id);
            Contact con1 = new Contact(FirstName = 'Jess', LastName = 'Lopez',AccountId=acc1.Id);
		    insert con1;
            
            
            Campaign cam1 = new Campaign(Name =System.Label.Shopify_Default_Campaign_Name,IsActive=true);
            insert cam1;
            System.debug(cam1.id);
            Opportunity opp1 = new Opportunity(Name='CAREGift1',AccountId=acc1.Id,CloseDate=Date.parse('20/09/2021'),StageName='Prospecting',HIC_ShopifySync__Payment_Status__c='Paid');
            opp1.Shopify_Shipping_Details__c ='({carrier_identifier=null, code=Standard, delivery_category=null, discount_allocations=(), discounted_price=10.00, discounted_price_set={presentment_money={amount=10.00, currency_code=AUD}, shop_money={amount=10.00, currency_code=AUD}}, id=3340841943093, phone=null, price=10.00, price_set={presentment_money={amount=10.00, currency_code=AUD}, shop_money={amount=10.00, currency_code=AUD}}, ...})';
            opp1.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('CARE Gift').getRecordTypeId();
            insert opp1;
            Opportunity op = [Select Id, npsp__Primary_Contact__c  FROM Opportunity where Id=:opp1.Id];
           // System.assertEquals(con1.Id,op.npsp__Primary_Contact__c);
        }
}