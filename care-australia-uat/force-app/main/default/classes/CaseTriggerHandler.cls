public class CaseTriggerHandler {
	public static void handleBeforeInsert(list<Case> newCases){
        set<String> suppliedEmails = new set<String>();
        
        map<String, RecordType> rtMap = new map<String, RecordType>([select Id, Name from RecordType Where SObjectType='Case' AND IsActive=true]);
        map<String, RecordType> rtMapByName = new map<String, RecordType>();
        if(rtMap != null && rtMap.size()>0){
            for(RecordType rt: rtMap.values()){
                rtMapByName.put(rt.Name, rt);
            }
        }
        
        for(Case cs: newCases){
            if(cs.Origin=='Web' && cs.SuppliedEmail != null && cs.ContactId==null){
                suppliedEmails.add(cs.SuppliedEmail);
            }
        }
        
        map<String, list<Account>> accountsMap = new map<String, list<Account>>();
        list<Account> accList = [Select Id, Name, Email__c From Account Where Email__c IN: suppliedEmails];
        if(accList != null && accList.size()>0){
            for(Account acc: accList){
                list<Account> result=accountsMap.get(acc.Email__c);
                if(result==null){
                    result=new list<Account>();
                }
                result.add(acc);
                accountsMap.put(acc.Email__c, result);
            }
        }
        
        map<String, list<Contact>> contactsMap = new map<String, list<Contact>>();
        list<Contact> conList = [Select Id, Name, Email From Contact Where Email IN: suppliedEmails];
        if(conList != null && conList.size()>0){
            for(Contact con: conList){
                list<Contact> result=contactsMap.get(con.Email);
                if(result==null){
                    result=new list<Contact>();
                }
                result.add(con);
                contactsMap.put(con.Email, result);
            }
        }
        
        list<Lead> ldList = new list<Lead>();
        for(Case cs: newCases){
            if(cs.Origin=='Web' && cs.SuppliedEmail != null && cs.AccountId==null){
                if(accountsMap.containsKey(cs.SuppliedEmail)){
                    list<Account> result=accountsMap.get(cs.SuppliedEmail);
                    if(result != null && result.size()>0){
                        cs.AccountId=result[0].Id;
                    }
                }
                
                if(!contactsMap.containsKey(cs.SuppliedEmail) && !accountsMap.containsKey(cs.SuppliedEmail)){
                    ldList.add(new Lead(Company=cs.SuppliedName, Email=cs.SuppliedEmail, LastName=cs.SuppliedName, LeadSource='Web'));
                }
            }
        }
        
        map<String, Lead> ldMap = new map<String, Lead>();
        if(ldList != null && ldList.size()>0){
            insert ldList;
            for(Lead l: ldList){
                ldMap.put(l.Email, l);
            }
        }
        
        for(Case cs: newCases){
            if(cs.SuppliedEmail != null && cs.ContactId==null){
                if(cs.Origin=='Web' && ldMap != null && ldMap.containsKey(cs.SuppliedEmail)){
                    cs.Lead__c=ldMap.get(cs.SuppliedEmail).Id;
                }
            }
            
            if(cs.RecordTypeId != null && cs.Type==null){
                cs.Type=rtMap.get(cs.RecordTypeId).Name;
            }
            
            // if recordtype is blank and type is not blank
            if(cs.Type != null && cs.RecordTypeId==null){
                if(rtMapByName.containsKey(cs.Type)){
                    cs.RecordTypeId=rtMapByName.get(cs.Type).Id;
                }
            }
        }
    }
}