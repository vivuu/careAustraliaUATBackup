@istest
public with sharing class TestDataFactory {
    public static Account createAccount(boolean create) {
        Account acc = new Account();
        acc.Name = 'Test Account';
        
        if(create){
            insert acc;
        }
        return acc;
        
    }
    public static Contact createContact(boolean create) {
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        if(create){
            insert con;
        }
        return con;
        
    }
    public static Opportunity createOpportunity(String stageName, Id accId, date closeDate,boolean create) {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = stageName;
        opp.AccountId = accId;
        opp.CloseDate = closeDate;
		if(create){
            insert opp;
        }
        return opp;
       
    }
    public static Campaign createCampaign(boolean create) {
        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        camp.ParentId = createParentCampaign(true).Id;
        camp.IsActive = true;
        if(create){
            insert camp;
        }
        return camp;
    }
     public static Campaign createParentCampaign(boolean create) {
        Campaign camp = new Campaign();
        camp.Name = 'Test Parent Campaign';
        camp.IsActive = true;
        if(create){
            insert camp;
        }
        return camp;
    }
    
}