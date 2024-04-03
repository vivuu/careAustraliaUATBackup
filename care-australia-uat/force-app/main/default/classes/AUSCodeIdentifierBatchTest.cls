@istest
private class AUSCodeIdentifierBatchTest {
    static testMethod void AUSCodeIdentifierBatch_TC001() {
        Account acc1 = new Account(Name='AcctTest');
            insert acc1;
            System.debug(acc1.id);
            Contact con1 = new Contact(FirstName = 'Jess', LastName = 'Lopez',AccountId=acc1.Id,Email='Jess.Lopez@testemail.com');
		    insert con1;
         Account acc2 = new Account(Name='TestCase002');
            insert acc2;
            System.debug(acc2.id);
            Contact con2 = new Contact(FirstName = 'Test', LastName = 'Case002',AccountId=acc2.Id,Email='test.case002@testemail.com');
		    insert con2;
        Campaign camp = TestDataFactory.createCampaign(true);
        	Opportunity opp1 = new Opportunity(Name='CAREGift1',AccountId=acc1.Id,StageName='Open',CampaignId = camp.Id,
                                               CloseDate = Date.newInstance(2022, 12, 9),npsp__Primary_Contact__c = con1.Id);            
            insert opp1;
        Opportunity opp2 = new Opportunity(Name='CAREGift002',AccountId=acc2.Id,StageName='Open',CampaignId = camp.Id,
                                               CloseDate = Date.newInstance(2022, 12, 9),npsp__Primary_Contact__c = con2.Id);            
            insert opp2;
         npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = opp1.Id;
        pay.npe01__Paid__c = true;
        
        
        pay.Refund_Status__c = 'Processed';
        pay.npe01__Paid__c = false;
        pay.npe01__Written_Off__c = true;
        pay.npe01__Payment_Amount__c = 1234;
        //update pay;
        
        pay.Chargeback_Status__c = 'Approved';
        pay.npe01__Written_Off__c = true;
        pay.Chargeback_Date__c = Date.newInstance(2021, 12, 12);
        //update pay;
        
        pay.Adjustment_Status__c = 'Processed';
        pay.AUS_Code__c = 'AUS779';
        insert pay;
        npe01__OppPayment__c pay01 = new npe01__OppPayment__c();
        pay01.npe01__Opportunity__c = opp2.Id;
        pay01.npe01__Paid__c = true;
        
        
        pay01.Refund_Status__c = 'Processed';
        pay01.npe01__Paid__c = false;
        pay01.npe01__Written_Off__c = true;
        pay01.npe01__Payment_Amount__c = 1234;
        //update pay;
        
        pay01.Chargeback_Status__c = 'Approved';
        pay01.npe01__Written_Off__c = true;
        pay01.Chargeback_Date__c = Date.newInstance(2021, 12, 12);
        //update pay;
        
        pay01.Adjustment_Status__c = 'Processed';
        pay01.AUS_Code__c = 'AUS782';
        insert pay01;
        AUSCodeIdentifierBatch newIns = new AUSCodeIdentifierBatch();
Database.executeBatch(newIns);

}
}