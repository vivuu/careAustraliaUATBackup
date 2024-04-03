public class NBContactHelper {

    public static String preProcessPhone(String phone) {
        // Make the phone a valid format
        String invalidNumbers = '[^0-9]';  
        phone = phone.replaceAll( invalidNumbers, '' );
        //If the phone number is 10 digits long and starts with '04' strip the '04' pre-append (+614) and submit it to the mobile field. All other to Others (even if the number starts with '614') should go to other
        if ( '' != phone && phone.startsWith('04') && 10 == phone.length() ) {
            phone = '+' + phone;
            phone = phone.replace('+04', '+614'); 
        }
        else if ( '' != phone && (  
            ( phone.startsWith('614') && 11 == phone.length() ) 
            || ( phone.startsWith('6104') && 12 == phone.length() )   
            ) ) {
            phone = '+' + phone;                       
        }
        return phone;
    }

    public static String processAusMobile(String phone) {
        Boolean isAusMobile = phone.startsWith('+6104');
        if ( isAusMobile ) {
			phone = phone.replace('+6104', '+614');
		}
        return phone;
    }

    public static Boolean isTen(String phone) {
        Boolean isTen = false;
        Boolean isAusMobile = phone.startsWith('+614');
		if (12 == phone.length() && isAusMobile) {
			isTen = true;
		}
        return isTen;
    }


    public static String processOrganisation(String sessionId, String firstName, String lastName, String campaign, String paymentMode, Decimal amount, 
        String street, String city, String state, String postalCode, String country,
        String phone, String email, String formURL,
        String contactMode, String organisation, Integer triggerDupe, Boolean isTen) 
    {

        Database.DMLOptions dml = new Database.DMLOptions(); 
        String returnId = 'ERROR';
        Account account;
        Contact contact;
        Account foundAccount;
        Contact foundContact;
        boolean orgCreated = false;
        
        if ( 0 == triggerDupe ) {
            List<Account> foundAccounts = [SELECT Id, Name FROM Account where Name = :organisation];            
            for (Account currentAccount : foundAccounts) {
                foundAccount = currentAccount;
                break;
            }
        }
        else {
            System.debug('Triggering duplicate name: ' + organisation);
        }
        
        if ( null == foundAccount ) {
            System.debug('Account creation: ' + organisation);                
            Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
            account = new Account();
            account.Name = organisation;
            account.Email__c = email;
            account.BillingStreet = street;
            account.BillingCity = city;
            account.BillingState = state;
            account.BillingPostalCode = postalCode;
            account.BillingCountry = country;
            if ( isTen ) {
                System.debug('Mobile Phone: ' + phone);
                account.Mobile__c = phone;                        
            }                    
            else {
                System.debug('Other Phone: ' + phone);
                account.Other_Phone__c = phone;
            }	
            account.RecordTypeId = accountRecordTypeId;
            dml.DuplicateRuleHeader.allowSave = false;
            Database.SaveResult accountSaveResult = Database.insert(account, dml);
            if (!accountSaveResult.isSuccess()) {
                System.debug('Failed save');
                for (Database.Error error : accountSaveResult.getErrors()) {
                    System.debug(error);
                    if (error instanceof Database.DuplicateError) {
                        System.debug('MatchRecords');
                        // Use the existing account and get the contact
                        Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        String duplicateRule = duplicateResult.getDuplicateRule();
                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                        if (1 == matchResults.size() && triggerDupe < 2) {
                            Datacloud.MatchResult matchResult = matchResults[0];
                            Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                            for (Datacloud.MatchRecord matchRecord : matchRecords) {
                                System.debug('MatchRecord: ' + matchRecord.getRecord());
                                account = (Account) matchRecord.getRecord();
                                break;
                            }
                        }
                        else {   
                            System.debug('Match Size: ' + matchResults.size());
                            dml.DuplicateRuleHeader.allowSave = true;
                            dml.DuplicateRuleHeader.runAsCurrentUser = true;                                
                            Database.SaveResult sr = Database.insert(account, dml);
                            DuplicateRecordSet ds = new DuplicateRecordSet();
                            Id duplicateId;
                            List<DuplicateRule> foundRules = [SELECT Id, DeveloperName FROM DuplicateRule where DeveloperName = :duplicateRule];            
                            for (DuplicateRule foundRule : foundRules) {
                                duplicateId = foundRule.Id;
                                break;
                            }                                
                            ds.DuplicateRuleId = duplicateId;                                
                            insert ds;
                            DuplicateRecordItem di = new DuplicateRecordItem();
                            di.DuplicateRecordSetId = ds.Id;
                            di.RecordId = account.Id;
                            insert di;
                        }                            
                    }
                    else {
                        return 'ERROR';
                    }
                }                
            }
            else {
                System.debug('Completed save');
                // Try and create with phone
                orgCreated = true;
            }
        }
        else {
            System.debug('Account found: ' + organisation);
            account = foundAccount;
        }
        
        if ( null != account ) {
            Boolean updateEmail = false;
            Boolean updateContact = false;
            // See if there is a Contact with the email first.            
            List<Contact> foundContacts = [SELECT Id, AccountId, Email FROM Contact where FirstName = :firstName and LastName = :lastName and Email = :email];                
            for (Contact currentContact : foundContacts) {
                foundContact = currentContact;
                updateContact = true;
                break;
            }
            
            if ( null == foundContact ) {
                foundContacts = [SELECT Id, AccountId, Email, OtherPhone, MobilePhone FROM Contact where FirstName = :firstName and LastName = :lastName and OtherPhone = :phone and OtherPhone != '' and OtherPhone != null];
                for (Contact currentContact : foundContacts) {
                    foundContact = currentContact;
                    System.debug('Found Contact for ' + organisation);
                    if ( currentContact.Email != email ) {
                        System.debug('Updating email for ' + email + ' ' + currentContact.Email);
                        updateEmail = true;
                    }
                    updateContact = true;
                    break;
                }
            }  
            
            if ( null == foundContact ) {
                foundContacts = [SELECT Id, AccountId, Email, OtherPhone, MobilePhone FROM Contact where FirstName = :firstName and LastName = :lastName and MobilePhone = :phone and MobilePhone != '' and MobilePhone != null];
                for (Contact currentContact : foundContacts) {                        
                    foundContact = currentContact;
                    System.debug('Found Contact for ' + organisation);
                    if ( currentContact.Email != email ) {
                        System.debug('Updating email for ' + email + ' ' + currentContact.Email);
                        updateEmail = true;
                    }
                    updateContact = true;
                    break;
                }
            } 
            
            if ( null == foundContact ) {
                foundContacts = [SELECT Id, AccountId, Email, OtherPhone, MobilePhone FROM Contact where FirstName = :firstName and LastName = :lastName and MailingStreet = :street and MailingStreet != '' and MailingStreet != null];
                for (Contact currentContact : foundContacts) {
                    foundContact = currentContact;             
                    System.debug('Found Contact for ' + organisation);
                    if ( currentContact.Email != email ) {
                        System.debug('Updating email for ' + email + ' ' + currentContact.Email);
                        updateEmail = true;
                    }
                    updateContact = true;
                    break;
                }
            }
            
            if ( null == foundContact ) {                       				                    
                contact = new Contact();                    
                contact.Email = email;
                contact.FirstName = firstName;
                contact.LastName  = lastName; 
                contact.MailingStreet = street;
                contact.MailingCity = city;
                contact.MailingState = state;
                contact.MailingPostalCode = postalCode;
                contact.MailingCountry = country;
                if ( isTen ) {
                    System.debug('Mobile Phone: ' + phone);
                    contact.MobilePhone = phone;                        
                }                    
                else {
                    System.debug('Other Phone: ' + phone);
                    contact.OtherPhone = phone;
                }					                    
                dml.DuplicateRuleHeader.allowSave = false;
                Database.SaveResult contactSaveResult = Database.insert(contact, dml);
                if (!contactSaveResult.isSuccess()) {
                    System.debug('Failed Contact save');
                    NBContactHelper.handleDuplicate(contactSaveResult, dml, contact, triggerDupe);                  
                } 
            }
            else {
                contact = foundContact;
                System.debug('Updating Email for ' + contact.Id + ' to ' + email);
                Contact updateContactRecord = new Contact();
                Boolean performContactUpdate = false;
                if ( true == updateEmail ) {
                    updateContactRecord.Email = email;
                    performContactUpdate = true;
                }   
                updateContactRecord.Id = contact.Id;
                if ( true == updateContact ) {
                    updateContactRecord.MailingStreet = street;
                    updateContactRecord.MailingCity = city;
                    updateContactRecord.MailingState = state;
                    updateContactRecord.MailingPostalCode = postalCode;
                    updateContactRecord.MailingCountry = country;
                    performContactUpdate = true;
                }
                if ( true == updateContact && false == isTen ) {
                    updateContactRecord.OtherPhone = phone;
                    performContactUpdate = true;
                }
                else if ( true == updateContact && true == isTen ) {
                    updateContactRecord.MobilePhone = phone;
                    performContactUpdate = true;
                }
                if ( true == performContactUpdate ) {
                    update updateContactRecord;
                }
            }
            Id contactId = contact.Id;
            Id accountId = account.Id;
            // Now check for an affiliation
            List<npe5__Affiliation__c> affiliations = [SELECT npe5__Primary__c, npe5__Contact__c from npe5__Affiliation__c where npe5__Contact__c = :contactId and npe5__Organization__c = :accountId ];
            boolean foundAff = false;
            for (npe5__Affiliation__c affiliation : affiliations) {
                foundAff = true;
                break;
            }
            if ( false == foundAff ) {
                npe5__Affiliation__c aff = new npe5__Affiliation__c();
                aff.npe5__Contact__c = contact.Id;
                aff.npe5__Organization__c = account.Id;
                if ( true == orgCreated ) {
                    aff.npe5__Primary__c = true;
                }
                System.debug('Inserting Affiliation: ' + contact.Id + ' ' + account.Id);
                if ( null != account.Id && null != contact.Id ) {
                    insert aff;
                }                    
            }

            // Now check for the account primary Contact
            List<Account> primaryContactAccounts = [SELECT npe01__One2OneContact__c from Account where npe01__One2OneContact__c = :contactId and Id = :accountId ];
            boolean foundPrimary = false;
            for (Account primaryContactAccount : primaryContactAccounts) {
                foundPrimary = true;
                break;
            }
            if ( false == foundPrimary ) {
                Account updateAccountPrimary = new Account();
                updateAccountPrimary.Id = accountId;
                updateAccountPrimary.npe01__One2OneContact__c = contactId;
                update updateAccountPrimary;
            }
            returnId = account.Id;
        }
        return returnId;
    }

    public static String processIndividual(String sessionId, String firstName, String lastName, String campaign, String paymentMode, Decimal amount, 
        String street, String city, String state, String postalCode, String country,
        String phone, String email, String formURL,
        String contactMode, String organisation, Integer triggerDupe, Boolean isTen) 
    {
        Database.DMLOptions dml = new Database.DMLOptions(); 
        String returnId = 'ERROR';
        System.debug('Phone: ' + phone);    
        // See if there is a Contact with the email first.  
        Id foundContact;
        Boolean updateEmail;
        Boolean updateContact;
        List<Contact> foundContacts;
        if ( 0 == triggerDupe ) {
            foundContacts = [SELECT Id, AccountId, Email, OtherPhone, MobilePhone FROM Contact where FirstName = :firstName and LastName = :lastName and Email = :email];                
            for (Contact currentContact : foundContacts) {
                foundContact = currentContact.Id;
                updateContact = true;
                break;
            }
        }
        
        if ( 0 == triggerDupe ) {
            if ( null == foundContact ) {
                foundContacts = [SELECT Id, AccountId, Email, OtherPhone, MobilePhone FROM Contact where FirstName = :firstName and LastName = :lastName and OtherPhone = :phone and OtherPhone != '' and OtherPhone != null];
                for (Contact currentContact : foundContacts) {
                    foundContact = currentContact.Id;                        
                    if ( currentContact.Email != email ) {
                        System.debug('Updating email for ' + email + ' ' + currentContact.Email);
                        updateEmail = true;
                    }
                    updateContact = true;
                    break;
                }
            }
        }
        
        if ( 0 == triggerDupe ) {
            if ( null == foundContact ) {
                foundContacts = [SELECT Id, AccountId, Email, OtherPhone, MobilePhone FROM Contact where FirstName = :firstName and LastName = :lastName and MobilePhone = :phone and MobilePhone != '' and MobilePhone != null];
                for (Contact currentContact : foundContacts) {
                    foundContact = currentContact.Id;
                    if ( currentContact.Email != email ) {
                        System.debug('Updating email for ' + email + ' ' + currentContact.Email);
                        updateEmail = true;
                    }
                    updateContact = true;
                    break;
                }
            }
        }
        
        if ( 0 == triggerDupe ) {
            if ( null == foundContact ) {
                foundContacts = [SELECT Id, AccountId, Email, OtherPhone, MobilePhone FROM Contact where FirstName = :firstName and LastName = :lastName and MailingStreet = :street and MailingStreet != '' and MailingStreet != null];
                for (Contact currentContact : foundContacts) {
                    foundContact = currentContact.Id;
                    if ( currentContact.Email != email ) {
                        System.debug('Updating email for ' + email + ' ' + currentContact.Email);
                        updateEmail = true;
                    }
                    updateContact = true;
                    break;
                }
            }
        }
        
        if ( null != foundContact ) {
            System.debug('Contact Found: ' + sessionId + ' ' + foundContact);
            try {
                Contact updateContactRecord = new Contact();
                updateContactRecord.Id = foundContact;
                Boolean performContactUpdate = false;
                if ( true == updateEmail ) {
                    updateContactRecord.Email = email;
                    performContactUpdate = true;
                }
                if ( true == updateContact ) {
                    updateContactRecord.MailingStreet = street;
                    updateContactRecord.MailingCity = city;
                    updateContactRecord.MailingState = state;
                    updateContactRecord.MailingPostalCode = postalCode;
                    updateContactRecord.MailingCountry = country;
                    performContactUpdate = true;
                }
                if ( true == updateContact && false == isTen ) {
                    updateContactRecord.OtherPhone = phone;
                    performContactUpdate = true;
                }
                else if ( true == updateContact && true == isTen ) {
                    updateContactRecord.MobilePhone = phone;
                    performContactUpdate = true;
                }

                if ( true == performContactUpdate ) {
                    update updateContactRecord;
                }
                
            }
            catch( Exception ecu) {
                System.debug('Contact Error ' + ecu.getMessage());
            }
            
            returnId = foundContact;
        }
        else {
            System.debug('Creating Account: ' + sessionId);
            Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
            Account account = new Account();
            account.Name = firstName + ' ' + lastName;
            account.Email__c = email;
            account.BillingStreet = street;
            account.BillingCity = city;
            account.BillingState = state;
            account.BillingCountry = postalCode;
            account.Phone = phone;
            account.RecordTypeId = accountRecordTypeId;
            
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;                                
            Database.SaveResult sr = Database.insert(account, dml);
            if ( null != account ) {
                System.debug('Account Created: ' + sessionId + ' ' + account.Id);                    
                
                Contact contact = new Contact();
                contact.AccountId = account.Id;
                contact.Email = email;
                contact.FirstName = firstName;
                contact.LastName  = lastName; 
                contact.MailingStreet = street;
                contact.MailingCity = city;
                contact.MailingState = state;
                contact.MailingPostalCode = postalCode;
                contact.MailingCountry = country;
                if ( isTen ) {
                    contact.MobilePhone = phone;                        
                }                    
                else {
                    contact.OtherPhone = phone;
                }	                                                                                
                dml.DuplicateRuleHeader.allowSave = false;
                Database.SaveResult contactSaveResult = Database.insert(contact, dml);
                if (!contactSaveResult.isSuccess()) {
                    NBContactHelper.handleDuplicate(contactSaveResult, dml, contact, triggerDupe);               
                }
                returnId = contact.id;   
            }                
        }
        return returnId;
    }
    
    public static Contact handleDuplicate(Database.SaveResult contactSaveResult, Database.DMLOptions dml, Contact contact, Integer triggerDupe ) {
        System.debug('Failed Contact save');
        for (Database.Error error : contactSaveResult.getErrors()) {
            System.debug(error);
            if (error instanceof Database.DuplicateError) {
                System.debug('MatchRecords');
                // Use the existing account and get the contact
                Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                String duplicateRule = duplicateResult.getDuplicateRule();
                Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                if (1 == matchResults.size() && triggerDupe < 2) {
                    Datacloud.MatchResult matchResult = matchResults[0];
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        System.debug('MatchRecord: ' + matchRecord.getRecord());
                        contact = (Contact) matchRecord.getRecord();
                        return contact;                        
                    }
                }
                else {   
                    System.debug('Match Size: ' + matchResults.size());
                    dml.DuplicateRuleHeader.allowSave = true;
                    dml.DuplicateRuleHeader.runAsCurrentUser = true;                                
                    Database.SaveResult sr = Database.insert(contact, dml);
                    DuplicateRecordSet ds = new DuplicateRecordSet();
                    Id duplicateId;
                    List<DuplicateRule> foundRules = [SELECT Id, DeveloperName FROM DuplicateRule where DeveloperName = :duplicateRule];            
                    for (DuplicateRule foundRule : foundRules) {
                        duplicateId = foundRule.Id;
                        break;
                    }                                
                    ds.DuplicateRuleId = duplicateId;                                
                    insert ds;
                    DuplicateRecordItem di = new DuplicateRecordItem();
                    di.DuplicateRecordSetId = ds.Id;
                    di.RecordId = contact.Id;
                    insert di;
                }                            
            }
        }
        return null;
    }
    
    public static DateTime transformDate( String processedDate ) {
        DateTime processedDateValue = system.Today();
        Date processedDateOnlyValue = system.Today();
        if ( '' != processedDate ) {               
            Datetime processedDateObj = null;        
            try {                   
                processedDate = processedDate.replace('T', ' ');
                processedDate = processedDate.substringBefore('.');
                System.debug('Date to parse: ' + processedDate);
                Datetime parsedDate = Datetime.valueOf(processedDate);  
                System.debug('Date before tz: ' + parsedDate.format('yyyy-MM-dd HH:mm:ss'));
                String zone = 'Australia/Sydney';
                TimeZone target = TimeZone.getTimeZone(zone);
                Integer offsetAtUTC = target.getOffset(parsedDate);
                processedDateObj = parsedDate.addSeconds(offsetAtUTC / 1000);
                processedDateValue = Datetime.valueOf( processedDateObj.format('yyyy-MM-dd HH:mm:ss') );
                System.debug('Date parsed to: ' + processedDateObj.format('yyyy-MM-dd HH:mm:ss'));
                processedDateOnlyValue = date.newinstance(processedDateValue.year(), processedDateValue.month(), processedDateValue.day());
            }
            catch ( Exception dateEx ) {
                System.debug('Date Parse Error: ' + processedDate);
            }
        }
        return processedDateValue;
    }
}