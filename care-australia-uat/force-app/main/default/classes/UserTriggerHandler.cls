/**
* Name			:		UserTriggerHandler
* Date			:		02/10/2023
* Author		:		Sayan Baral
* Description	:		To share Loans and Borrowers of same FSP upon new user creation
*/
public without sharing class UserTriggerHandler {
    
    public static void handleBefore(List<User> usersList)
    {
        set<String> profileIds = new set<String>();
        set<String> contactIds = new set<String>();
            for(User usr: usersList){
                if(usr.ContactId != null){
                    profileIds.add(usr.ProfileId);
                    contactIds.add(usr.ContactId);
                }
            }
            
            map<String, Profile> profilesMap = new map<String, Profile>([Select Id, Name From Profile Where Id IN: profileIds]);
            
            if(contactIds != null && contactIds.size()>0){
                map<String, Contact> contactsMap = new map<String, Contact>([Select Id, Country__c, CurrencyIsoCode 
                                                                             From Contact Where Id IN: contactIds]);
                for(User usr: usersList){
                    if(usr.ContactId != null && contactsMap.containsKey(usr.ContactId)){
                        if(profilesMap.containsKey(usr.ProfileId)){
                            if(profilesMap.get(usr.ProfileId).Name=='FSP Staff'){
                                if(usr.Country==NULL || usr.Country==''){
                                    usr.addError('Country is a required field for FSP User.');
                                }
                                
                                if(usr.CurrencyIsoCode==null || usr.CurrencyIsoCode != contactsMap.get(usr.ContactId).CurrencyIsoCode){
                                    usr.CurrencyIsoCode=contactsMap.get(usr.ContactId).CurrencyIsoCode;
                                }
                            }
                        }
                    }
                }
            }
    }
    public static void handleAfterInsert(list<User> usersList)
    {
        List<String> userIds=new List<String>();
        List<String> contactIds=new List<String>();
        Map<String,String> contactwithFSP=new Map<String,String>();
        Id fspRTId = LWCUtility.getFSPRecordTypeId();
        Id fspBRTId=LWCUtility.getFSPBorrowerRecordTypeId();
        Id fspStaffRTId = LWCUtility.getFSPStaffRecordTypeId();
        for(User u: usersList)
        {
            userIds.add(u.Id);
        }
        Map<String,User> userMap=new Map<String,User>([SELECT Id,ContactId,Profile.Name,IsActive FROM User WHERE Profile.Name='FSP Staff' AND IsActive=TRUE AND Id IN :userIds AND ContactId<>NULL]);
        for(User u: userMap.values())
        {
            contactIds.add(u.ContactId);
        }
        System.debug('contactIds-->'+contactIds);
        Map<String,Contact> contactMap=new Map<String,Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds AND RecordTypeId=:fspStaffRTId]);
        System.debug('contactMap-->'+contactMap);
        for (Contact con : contactMap.values()) 
                contactwithFSP.put(con.Id,con.AccountId);
        

        if(contactwithFSP != null && contactwithFSP.size()>0)
        {
            createBorrowerSharing(contactwithFSP);
            //createLoanSharingforFSP(contactwithFSP.values());
        }

    }
    
   /* public static void createLoanSharingforFSP(List<Id> fspAccountIds){
        list<Loan__c> records = [Select Id, FSP__c, FSP_Name__c From Loan__c Where FSP__c IN: fspAccountIds];
        LoanTriggerHandler.createLoanSharing(records);
    }*/
    
    public static void createBorrowerSharing(Map<String,String> contwithFSP)
    {
        List<AccountShare> accShareList=new List<AccountShare>();
        //System.debug('COntwithFSP-->'+contwithFSP);
        Map<String, Account> BorrowerwithParent=new Map<String,Account>([SELECT Id, OwnerId, ParentId FROM Account WHERE ParentId IN :contwithFsp.values() AND RecordType.Name='FSP (Borrower)']);
        Map<String,String> borfsp=new Map<String,String>();
        
        if((BorrowerwithParent!=null)&&(BorrowerwithParent.size()>0))
        {
            for(Account acc: BorrowerwithParent.values())
                borfsp.put(acc.ParentId,acc.Id);//fsp , non-fsp
        }
        
        //System.debug('Borfsp--->'+borfsp);              
        Map<String,User> fspstaffs=new Map<String,User>([SELECT Id, ContactId FROM User WHERE Profile.Name='FSP Staff' AND ContactId<>null and isActive=true AND ContactId IN :contwithFsp.keySet()]);
        //System.debug('FSPUsers-->'+fspstaffs);
        
        if((fspstaffs.size()>0)&&(fspstaffs!=null))
        {
            for(User u: fspstaffs.values())
            {
                if(contwithFSP.containsKey(u.contactId))
                {
                    String conId;
                    if(borfsp.containsKey(contwithFSP.get(u.contactId)))
                    {
                        if(u.id<>BorrowerwithParent.get(borfsp.get(contwithFSP.get(u.contactId))).OwnerId)
                        {
                            AccountShare ashare=new AccountShare();
                            ashare.AccountId=borfsp.get(contwithFSP.get(u.contactId));
                            ashare.AccountAccessLevel='Read';
                            ashare.OpportunityAccessLevel='Edit';
                            ashare.UserOrGroupId=u.Id;
                            System.debug(ashare);
                            accShareList.add(ashare);
     
                        }     
                    }
                }
            }  
        }  
        
        try
        {
            if((accShareList!=null)&&(accShareList.size()>0))
            {
                insert accShareList;
            }     
        }
        catch(Exception e)
        {
            system.debug('Error Message-->'+e.getMessage());
        }
    }
    	
}