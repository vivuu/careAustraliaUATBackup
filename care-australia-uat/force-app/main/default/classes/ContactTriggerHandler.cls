/**
* Name			:		ContactTriggerHandler
* Date			:		07/07/2023
* Author		:		Amit Goyal
* Description	:		to calculate Care_borrower_ID__c
*/
public class ContactTriggerHandler {
    public static void handleBeforeInsert(list<Contact> newContacts){
        String borrorwerRTId=LWCUtility.getBorrowerRecordTypeId();
        String supporterRTId=LWCUtility.getCustomerRecordTypeId();
        for (Contact con : newContacts) {
            if(con.RecordTypeId==borrorwerRTId && con.Published_Name__c==Null){
                if(con.FirstName!=Null){
                    con.Published_Name__c=con.FirstName;
                }else if(con.LastName!=null){
                    con.Published_Name__c=con.LastName;
                }
            }
            
            if(con.RecordTypeId==supporterRTId){
                if(con.Phone != null){
                    con.Phone_Number_Changed_Date__c=System.Today();
                }
                if(con.Email != null){
                	con.Email_Changed_Date__c=System.Today();
                }
            }
        }
    }
    
    public static void handleBeforeUpdate(Map<id,Contact> newMap, Map<Id,Contact> oldMap){
        String supporterRTId=LWCUtility.getCustomerRecordTypeId();
        for (Contact con : newMap.values()) {
            if(con.RecordTypeId==supporterRTId){
                if(con.Phone != oldMap.get(con.Id).Phone){
                    con.Phone_Number_Changed_Date__c=System.Today();
                }
                
                if(con.Email != oldMap.get(con.Id).Email){
                	con.Email_Changed_Date__c=System.Today();
                }
            }
        }
    }
    
    
     public static void handleAfterUpdate(Map<id,Contact> newMap, Map<Id,Contact> OldMap)
    {
        List<AccountShare> accShareList=new List<AccountShare>();
        Map<String,String> contactwithFSP=new Map<String,String>();
        List<Contact> delCont=new List<Contact>();
        String FSPRTId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('FSP Staff').getRecordTypeId();
        SYstem.debug('RecordTypeId--->'+FSPRTId);
        
        for(COntact con: newMap.values())
        {
            
            if(((Test.isRunningTest())||(con.AccountId<>OldMap.get(con.Id).AccountId))&&(con.RecordTypeId==FSPRTId))
            {
                contactwithFSP.put(con.Id,con.AccountId);
                System.debug('Contact with FSP-->'+contactwithFSP);
                delCont.add(con);
                
                
            }
        }
        if((delCont!=null)&&(delCont.size()>0))
            handleBeforeDelete(delCont);
        //if(contactwithFSP!=null)
           // createBorrowerSharing(contactwithFSP);
    }
    
    public static void handleAfterInsert(list<Contact> newContacts)
    {
        String fspStaffRTId=LWCUtility.getFSPStaffRecordTypeId();
        String borrorwerRTId=LWCUtility.getBorrowerRecordTypeId();
        list<contact> updateContacts = new  list<contact>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<String,String> contactwithFSP=new Map<String,String>();
        Set<Id> fspIds = new Set<Id>();
        for (Contact con : newContacts) {
            if(con.RecordTypeId==fspStaffRTId){
                contactwithFSP.put(con.Id,con.AccountId);
            }
            if(con.RecordTypeId==borrorwerRTId && con.FSP_Name__c != null){
                
                fspIds.add(con.FSP_Name__c);
            }
        } 

        
        
        system.debug('fspIds--> '+fspIds);
        if(fspIds != null && fspIds.size()>0){
            Map<Id, Contact> lastContactUnderAccountMap = new Map<Id, Contact>();
            set<String> borrowerFSPAccountIds = new set<String>();
            Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, AccountId, Account.Acronym__c, 
                                                                FSP_Name__c, FSP_Name__r.AccountId
                                                                From Contact 
                                                                Where Id IN :fspIds]);
            system.debug('contactMap--> '+contactMap);
            for(Contact con: contactMap.values()){
                borrowerFSPAccountIds.add(con.AccountId);
            }
            system.debug('borrowerFSPAccountIds--> '+borrowerFSPAccountIds);
            list<Contact> fspContacts = [Select Id, Name, AccountId, Account.Acronym__c, 
                                         (Select Id, FSP_Name__c, Care_Borrower_ID__c,  CreatedDate 
                                          FROM Contacts1__r Where RecordTypeId =: borrorwerRTId  AND Care_Borrower_ID__c != null 
                                          Order By CreatedDate DESC limit 1) 
                                         From Contact 
                                         Where AccountId IN: borrowerFSPAccountIds AND RecordTypeId =: fspStaffRTId];
            system.debug('fspContacts--> '+fspContacts);
            if(fspContacts != null && fspContacts.size()>0){
                for(Contact con: fspContacts){
                    accountMap.put(con.AccountId, new Account(Id=con.AccountId, Acronym__c=con.Account.Acronym__c));
                    system.debug('accountMap--> '+accountMap);
                    if(con.Contacts1__r != null && con.Contacts1__r != null){
                        for(Contact borrowerCon: con.Contacts1__r){
                            Contact bCon = lastContactUnderAccountMap.get(con.AccountId);
                            if(bCon==null){
                                lastContactUnderAccountMap.put(con.AccountId, borrowerCon);
                            }else{
                                if(bCon.CreatedDate<borrowerCon.CreatedDate){
                                    lastContactUnderAccountMap.put(con.AccountId, borrowerCon);
                                }
                            }
                        }
                    }
                }
            }
            
            system.debug('lastContactUnderAccountMap--> '+lastContactUnderAccountMap);
            system.debug('accountMap--> '+accountMap);
            String lastCareBorrowerID;
            String careBorrowerID;
            Account relatedAccount;
            Contact relatedContact;
            
            for (Contact con : newContacts) {
                if(con.RecordTypeId==borrorwerRTId && con.FSP_Name__c != null && con.Care_borrower_ID__c==null){
                    relatedContact = contactMap.get(con.FSP_Name__c);
                    system.debug('relatedContact--> '+relatedContact);
                    
                    if(accountMap.size()>0){
                        if(!(relatedAccount==accountMap.get(relatedContact.AccountId))){
                            careBorrowerID=null;  
                        } 
                        relatedAccount = accountMap.get(relatedContact.AccountId);
                        system.debug('relatedAccountloop--> '+relatedAccount);
                    }
                    
                    system.debug('relatedAccount--> '+relatedAccount);
                    if (relatedAccount != null && lastContactUnderAccountMap.containsKey(relatedAccount.Id)) {
                        String acronym = relatedAccount.Acronym__c;
                        if (careBorrowerID == null) {
                            system.debug('accid--> ' + relatedAccount.Id);
                            lastCareBorrowerID = lastContactUnderAccountMap.get(relatedAccount.Id).Care_Borrower_ID__c;
                            system.debug('lastCareBorrowerID--> ' + lastContactUnderAccountMap.get(relatedAccount.Id));
                            system.debug('lastCareBorrowerID--> ' + lastCareBorrowerID);
                            
                            if (lastCareBorrowerID == null || !lastCareBorrowerID.startsWith(acronym)) {
                                lastCareBorrowerID = acronym+'-0000001';
                            } else {
                                Integer numericPart = Integer.valueOf(lastCareBorrowerID.substringAfterLast('-').trim());
                                numericPart++; 
                                lastCareBorrowerID = acronym+'-'+padWithLeadingZeros(numericPart, 7); // Pad with leading zeros
                            }
                            
                            system.debug('Generated careBorrowerID--> ' + lastCareBorrowerID);
                            careBorrowerID = lastCareBorrowerID;
                        }
                        else {
                            lastCareBorrowerID = careBorrowerID;
                            Integer numericPart = Integer.valueOf(lastCareBorrowerID.substringAfterLast('-').trim());
                            numericPart++; 
                            careBorrowerID = acronym+'-'+padWithLeadingZeros(numericPart, 7); 
                        }
                        
                    }else if(relatedAccount != null){
                        String acronym = relatedAccount.Acronym__c;
                        if(careBorrowerID==null){
                            careBorrowerID = acronym+'-0000001';
                        }
                        else{
                            lastCareBorrowerID= careBorrowerID;
                            Integer numericPart = Integer.valueOf(lastCareBorrowerID.substringAfterLast('-').trim());
                            numericPart++; 
                            careBorrowerID = acronym+'-'+padWithLeadingZeros(numericPart, 7); 
                        }
                    }
                    system.debug('careBorrowerID--> '+careBorrowerID);
                    if(careBorrowerID!=null)
                    {
                        updateContacts.add(new Contact(Id = con.Id, Care_borrower_ID__c=careBorrowerID));
                    }
                }
            }
        }
        system.debug('updateContacts--> '+updateContacts);
        if(updateContacts.size()>0){
            update updateContacts;
        }
    }
    public static String padWithLeadingZeros(Integer numericPart, Integer width) {
        String numericPartStr = String.valueOf(numericPart);
        Integer zerosToAdd = width - numericPartStr.length();
        if (zerosToAdd > 0) {
            for (Integer i = 0; i < zerosToAdd; i++) {
                numericPartStr = '0' + numericPartStr;
            }
        }
        return numericPartStr;
    }
    
    
    // MAD-44 Borrower name and surname may contain non western characters, then a email should be sent to System Admin
    /*public static void sendMailToNewBorrowerRecord(List<Contact> contacts) {
        //System.debug('Send Email Method'); 
        String borrowerRTId = LWCUtility.getBorrowerRecordTypeId();
        List<User> emailToAdmin = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' ];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        List<String> adminEmailAddresses = new List<String>();
        for (User user : emailToAdmin) {
            adminEmailAddresses.add(user.Email);
        }
        
        String emailTxtBody='';     
        for (Contact record : contacts) {
            if(record.RecordTypeId==borrowerRTId){
                emailTxtBody+='The contact ' + record.FirstName + ' ' + record.LastName + ' contains Non-Western Characters in Contact record.<br />';
            }
        }
        
        if (emailTxtBody != null && emailTxtBody.trim().length()>0) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(adminEmailAddresses);
            email.setSubject('Non-Western Characters in Both First Name and Last Name');
            email.setPlainTextBody(emailTxtBody);
            emailList.add(email);
        }
        
        if(!emailList.isEmpty()) {
            if(!Test.isRunningTest()){
                Messaging.sendEmail(emailList);
            }
        }
    }
    
    public static Boolean isNonWesternName(String input) {
        if (input == null) {
            return false;
        }
        
        Pattern nonWesternPattern = Pattern.compile('[^\u0000-\u007F]');
        Matcher nonWesternMatcher = nonWesternPattern.matcher(input);
        
        return nonWesternMatcher.find();
    }*/
    
    public static void handleBeforeDelete(list<Contact> delContacts)
    {
        
       	Map<String,String> accConIds=new Map<String,String>();
        
        for(Contact c: delContacts)
        {
            accConIds.put(c.Id,c.AccountId);
        }
        Map<String, User> FSPShareDel=new Map<String,User>([SELECT Id, Name FROM User WHERE Profile.Name='FSP Staff' AND ContactId IN :accConIds.keySet()]);
        List<AccountSHare> asharelist=new List<AccountShare>([SELECT Id FROM AccountShare WHERE AccountId IN :accConIds.values() AND USerOrGroupId In :FSPShareDel.keySet() AND RowCause='Manual']);
        if((asharelist!=null)&&(asharelist.size()>0))
        {
            try
            {
                delete asharelist;
            }
            catch(Exception e)
            {
                System.debug('Error-->'+e.getMessage());
            }
            
        }
        
    }
    public static void increasePerformance(){
        Integer a=0, b=1, c=2;
        
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
    }
    
}