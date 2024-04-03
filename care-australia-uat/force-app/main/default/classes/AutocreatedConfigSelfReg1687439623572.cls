global class AutocreatedConfigSelfReg1687439623572 implements Auth.ConfigurableSelfRegHandler {
    
    private final Long CURRENT_TIME = Datetime.now().getTime();
    private final String[] UPPERCASE_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    private final String[] LOWERCASE_CHARS = 'abcdefghijklmnopqrstuvwxyz'.split('');
    private final String[] NUMBER_CHARS = '1234567890'.split('');
    private final String[] SPECIAL_CHARS = '!#$%-_=+<>'.split('');
    private static final String DEFAULT_ACCOUNTNAME = label.PartnerAccountName;
    private static final String EXTERNAL_USER_PROFILE =  label.PartnerProfile;
    private static final String INTERNAL_USER_PROFILE = 'Standard User';    
    private static final String contOwner=Label.Lender_Contact_Owner;

    
    // This method is called once after verification (if any was configured)
    // This method should create a user and insert it
    // Password can be null
    // Return null or throw an exception to fail creation
    global Id createUser(Id accountId, Id profileId, Map<SObjectField, String> registrationAttributes, String password) {
        User u = new User();
        String setLender,contId;
        u.ProfileId = profileId;
        for (SObjectField field : registrationAttributes.keySet()) {
            String value = registrationAttributes.get(field);
            u.put(field, value);
        }
        
        u = handleUnsetRequiredFields(u);
        u.Username=u.email;
        String alias = u.firstName + u.lastName;
        
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
            u.alias = alias;
        }
        
        try{
            String returnsting= generateContact(u, accountId);
            contId=returnsting.substringBefore('~');
            u.contactId =contId;
            setLender=returnsting.substringAfter('~');
        }catch(Exception e){
            string message = e.getMessage();
            if(message!=null) {
                System.debug('Duplicate emailline 36');
                throw new Auth.DiscoveryCustomErrorException (e.getMessage());
            }
        }
        
        if (String.isBlank(password)) {
            password = generateRandomPassword();
        }
        try{
            if(!Test.isRunningTest()){
                Site.validatePassword(u, password, password);  
            }
        }catch(Exception e){
            string message = e.getMessage();
            if(message.equals('Your password must be at least 12 characters long.')) {
                throw new Auth.DiscoveryCustomErrorException (e.getMessage());
            }
        }
        
        
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = UserInfo.getTimezone().getID();
        
        try{
            if(setLender.equalsIgnoreCase('true'))
            {
                
                Contact setLenderCont=[SELECT Id,IsLender__c,OwnerId FROM Contact WHERE Id= :contId LIMIT 1];
                setLenderCont.IsLender__c=True;
                setLenderCont.OwnerId=contOwner;
                update setLenderCont;
            }
            insert u;
            system.debug('user--> '+u);
            System.setPassword(u.Id, password);
            return u.id;   
        }catch(exception e){
            
            string message = e.getMessage();
            string LinkUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            if(message.equals('[User already exists.]')){
                throw new Auth.DiscoveryCustomErrorException ('User Already Exists, please go to login page. ' + LinkUrl );
            }else if(message.equals('[There was an error in registering a user in site [SiteName]. The error message is: portal user already exists for contact]')) {
                throw new Auth.DiscoveryCustomErrorException('An error occurred, please try logging in or using a different email. You can login at ' + LinkUrl);
            }else if(message.equals('Your password must have a mix of letters and numbers')) {
                throw new Auth.DiscoveryCustomErrorException (e.getMessage());
            }else if(message.equals('Your password must be at least 12 characters long.')) {
                throw new Auth.DiscoveryCustomErrorException (e.getMessage());
            }
            else if(message.contains('DUPLICATE_USERNAME')) {
                throw new Auth.DiscoveryCustomErrorException ('The username already exist. Please try to login with your email address or reset your password.If the issue persist, please contact us'+accountId);
            }
            else if(message.contains('DUPLICATES_DETECTED')) {
                throw new Auth.DiscoveryCustomErrorException ('Account already exists, please login or contact us for help.');
            }
            /*else if(message.contains('DUPLICATE_EMAIL_DETECTED')) {
throw new Auth.DiscoveryCustomErrorException ('Email address already exists, Please create user with a different email.');
}*/
            else{
                throw new Auth.DiscoveryCustomErrorException ('Please contact us and give us this error message: ' + e.getMessage());
            }
        }
        
    }
    
    // Method to autogenerate a password if one was not passed in
    // By setting a password for a user, we won't send a welcome email to set the password
    private String generateRandomPassword() {
        String[] characters = new List<String>(UPPERCASE_CHARS);
        characters.addAll(LOWERCASE_CHARS);
        characters.addAll(NUMBER_CHARS);
        characters.addAll(SPECIAL_CHARS);
        String newPassword = '';
        Boolean needsUpper = true, needsLower = true, needsNumber = true, needsSpecial = true;
        while (newPassword.length() < 50) {
            Integer randomInt = generateRandomInt(characters.size());
            String c = characters[randomInt];
            if (needsUpper && c.isAllUpperCase()) {
                needsUpper = false;
            } else if (needsLower && c.isAllLowerCase()) {
                needsLower = false;
            } else if (needsNumber && c.isNumeric()) {
                needsNumber = false;
            } else if (needsSpecial && !c.isAlphanumeric()) {
                needsSpecial = false;
            }
            newPassword += c; 
        }
        newPassword = addMissingPasswordRequirements(newPassword, needsLower, needsUpper, needsNumber, needsSpecial);
        return newPassword;
    }
    
    private String addMissingPasswordRequirements(String password, Boolean addLowerCase, Boolean addUpperCase, Boolean addNumber, Boolean addSpecial) {
        if (addLowerCase) {
            password += LOWERCASE_CHARS[generateRandomInt(LOWERCASE_CHARS.size())];
        }
        if (addUpperCase) {
            password += UPPERCASE_CHARS[generateRandomInt(UPPERCASE_CHARS.size())];
        }
        if (addNumber) {
            password += NUMBER_CHARS[generateRandomInt(NUMBER_CHARS.size())];
        }
        if (addSpecial) {
            password += SPECIAL_CHARS[generateRandomInt(SPECIAL_CHARS.size())];
        }
        return password;
    }
    
    // Generates a random number from 0 up to, but not including, max.
    private Integer generateRandomInt(Integer max) {
        return Math.mod(Math.abs(Crypto.getRandomInteger()), max);
    }
    
    // Loops over required fields that were not passed in to set to some default value
    private User handleUnsetRequiredFields(User u) {
        if (String.isBlank(u.LastName)){
            u.LastName = generateLastName();
        }
        if (String.isBlank(u.Username)) {
            u.Username = generateUsername();
        }
        if (String.isBlank(u.Email)) {
            u.Email = generateEmail();
        }
        if (String.isBlank(u.Alias)) {
            u.Alias = generateAlias();
        }
        if (String.isBlank(u.CommunityNickname)) {
            u.CommunityNickname = generateCommunityNickname();
        }
        return u;
    }
    
    // Method to construct a contact for a user
    private string generateContact(User u, Id accountId) {
        String returnstring;
        String foundEmail=u.Email;
        list<Contact> existingCont=[SELECT Id,Email,FirstName,LastName FROM Contact WHERE Email=:foundEmail LIMIT 1];
        Contact contact = new Contact();
        try{
            if((existingCont.size()>0)&&(existingCont[0].Email==u.Email)&&(existingCont[0].LastName.equalsIgnoreCase(u.lastName))&&(existingCont[0].FirstName.equalsIgnoreCase(u.firstName)))
            {
                
                contact.Id= existingCont[0].Id;
                returnstring=contact.Id+'~true';
            }
            else
            { 
                contact.LastName =  u.lastName;
                contact.FirstName =  u.firstName;
                contact.Email =  u.email;
                //List<Account> accounts = [select Id from Account where Name =:DEFAULT_ACCOUNTNAME];
                //contact.accountId = accounts[0].Id;
                contact.OwnerId=contOwner;
                contact.IsLender__c = true;
                string recordTypeId = Schema.Sobjecttype.contact.getRecordTypeInfosByName().get('Supporter').getRecordTypeId();
                contact.RecordTypeId = recordTypeId;
                insert contact;
                returnstring=contact.Id+'~false';
                Lender_Balance__c leanderB = new Lender_Balance__c();
                leanderB.Balance__c= 0;
                leanderB.Lender__c = contact.Id;
                leanderB.CurrencyIsoCode = 'VND';
                insert leanderB;
                System.debug('Contact created for ' + contact.id);
                Cart__c cart = new Cart__c();
                cart.Contact__c = contact.Id;
                insert cart;
            } 
            return returnstring;  
        }    
        catch(Exception e){
            string message = e.getMessage();
            if(message.contains('DUPLICATE_EMAIL_DETECTED')) {
                throw new Auth.DiscoveryCustomErrorException ('Email address already exists, Please create user with a different email.');
            }
            return null;
        }
        
        
    }
    
    // Default implementation to try to provide uniqueness
    private String generateAlias() {
        String timeString = String.valueOf(CURRENT_TIME);
        return timeString.substring(timeString.length() - 8);
    }
    
    // Default implementation to try to provide uniqueness
    private String generateLastName() {
        return 'ExternalUser' + CURRENT_TIME;
    }
    
    // Default implementation to try to provide uniqueness
    private String generateUsername() {
        return 'externaluser' + CURRENT_TIME + '@company.com';
    }
    
    // Default implementation to try to provide uniqueness
    private String generateEmail() {
        return 'externaluser' + CURRENT_TIME + '@company.com';
    }
    
    // Default implementation to try to provide uniqueness
    private String generateCommunityNickname() {
        return 'ExternalUser' + CURRENT_TIME;
    }
}