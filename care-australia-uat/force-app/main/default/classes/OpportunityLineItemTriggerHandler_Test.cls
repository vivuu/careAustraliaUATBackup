@isTest(SeeAllData=True)
public class OpportunityLineItemTriggerHandler_Test {
	
    public static TestMethod void TestOppLineItem(){
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();

        
        // insert product
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry For Product';
        p.productCode = 'SFDCPanther-123';
        p.isActive = true;
        insert p;
        
         //get standard pricebook
		Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        // insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        
        // insert account
        Account acc = new Account(
        Name = 'SFDCPanther.com',
        RecordTypeId=RecordTypeIdAccount
        );
        insert acc;
        
        // insert contact
        Contact con = new Contact(
        LastName = 'SFDCPanther'
       
        );
        insert con;
        
        // insert Parent Campaign
        Campaign ParentCamp = new Campaign();
      	ParentCamp.Name = 'Parent Campaign';  
        ParentCamp.IsActive = TRUE;
      	insert ParentCamp;
        
        // insert Campaign
        Campaign camp = new Campaign();
      	camp.Name = 'Test Campaign'; 
        camp.ParentId = ParentCamp.Id;
        camp.IsActive = TRUE;
      	insert camp;
        
		// Create Opportunity
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.AccountId = acc.Id;
        opp.ContactId = con.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.CampaignId = camp.Id;
        insert opp;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = standardPrice.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        oppLineItem.HIC_ShopifySync__Shopify_Id__c = '8982193091331231';
        //oppLineItem.Product_Properties__c = '({name=Gift Type, value=printed card}, {name=Gift SKU, value=40WH/Fifty bars of soap})';
        oppLineItem.Product_Properties__c = '[{"value":"printed cards","name":"Gift Type"},{"value":"67CB/CARE bundle of farming support","name":"Gift SKU"}]';
        insert oppLineItem;
        
        
    }
}