global class LWC_LastLoginScheduler Implements Schedulable{
    global void execute(SchedulableContext sc){
        map<String, Contact> lenderContactsMap = new map<String, Contact>();
        list<User> lenderUsers = [SELECT Id, Name, ContactId, LastLoginDate FROM User WHERE Profile.Name = 'Lender' AND IsActive=true AND MobilePhone !=null];
        set<String> conIds = new set<String>();
        for(User u: lenderUsers){
            conIds.add(u.ContactId);
        }
        
        String customerRTId=LWCUtility.getCustomerRecordTypeId();
        map<String, Contact> contactsMap = new map<String, Contact>([Select Id, Lender_Balance__c, Lending_Enabled_Date__c, 
                                                                     Is_LastLogin_6_Months__c 
                                                                     From Contact Where RecordTypeId =: customerRTId AND Id IN: conIds]);
        system.debug('### contactsMap size: '+contactsMap.size());
        for(User u: lenderUsers){
            Boolean isChanged=false;
            Boolean isOlderThan6Months=false;
            if(contactsMap.containsKey(u.ContactId)){
                Contact con = contactsMap.get(u.ContactId);
                if(con.Lender_Balance__c >= 25){
                    if(con.Lending_Enabled_Date__c==NULL){
                        isChanged=true;
                        con.Lending_Enabled_Date__c=System.Today();
                    }
                }else{
                    if(con.Lending_Enabled_Date__c!=NULL){
                        isChanged=true;
                        con.Lending_Enabled_Date__c=NULL;
                    }
                }
                
                Date dt = System.Today().addMonths(-6);
                if(u.LastLoginDate < dt){
                    if(contactsMap.get(u.ContactId).Is_LastLogin_6_Months__c==false){
                        isChanged=true;
                        con.Is_LastLogin_6_Months__c=true;
                    }
                }else{
                    if(contactsMap.get(u.ContactId).Is_LastLogin_6_Months__c==true){
                        isChanged=true;
                        con.Is_LastLogin_6_Months__c=false;
                    }
                }
                
                if(isChanged){
                    lenderContactsMap.put(u.ContactId, con);
                }
            }
        }
        
        if(lenderContactsMap != null && lenderContactsMap.size()>0){
            update lenderContactsMap.values();
        }
    }
}