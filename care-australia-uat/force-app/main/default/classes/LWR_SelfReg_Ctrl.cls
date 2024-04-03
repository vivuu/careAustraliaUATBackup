public class LWR_SelfReg_Ctrl {
    @AuraEnabled
    public static Boolean checkEmail(String email){
        List<User> userList = [SELECT Id, Name FROM User WHERE Username =: email];
        if(!userList.isEmpty()){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static RegistrationStatus registerLenderExtUser(String title, String firstname, String lastname, String email, String postalCode, Date birthDay, String phone, Boolean TermsAccepted, String password, String startURL){
        
        Savepoint savepoint = Database.setSavepoint();
        RegistrationStatus rs = new RegistrationStatus();
        String returnSTR = null;
        String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
               
        Map<String,Object> contactMap = new Map<String,Object>();
        contactMap.put('Email',email);
        contactMap.put('Birthdate',birthDay);
        contactMap.put('MobilePhone',phone);
        contactMap.put('Terms_and_conditions__c',TermsAccepted);
        contactMap.put('MailingPostalCode',postalCode);
        contactMap.put('IsLender__c',true);
        contactMap.put('Salutation',title);
        
        User extUser = new User();
        extUser.FirstName = firstname;  
        extUser.LastName = lastname;
        extUser.Email = email;
        extUser.Username = email;
        extUser.CommunityNickName = nickname;
        extUser.EmailEncodingKey='UTF-8';
        extUser.LanguageLocaleKey='en_US';
        extUser.LocaleSidKey='en_AU';
        extUser.TimeZoneSidKey='Australia/Sydney';
        
        String userId;
        Account portalAccount = new Account();
        portalAccount.Name = firstName + ' Household';
        portalAccount.Contact_Update_Data__c = JSON.serialize(contactMap);
        portalAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        insert portalAccount;
        startURL = null;
        try{
            userId = Site.createExternalUser(extuser, portalAccount.Id, password, false);
            if(userId != null){
                ApexPages.PageReference lgn = Site.login(email, password, startURL);
                if(lgn != null){
                    rs.success = true;
                    rs.returnSTR = lgn.getUrl();
                }
            }
        }catch(Exception ex) {
            System.debug('Error '+ex);
            Database.rollback(savepoint);
            rs.success = false;
            rs.returnSTR = String.valueOf(ex);
        }
        return rs;
    }
    
    public class RegistrationStatus{
        @AuraEnabled
        public Boolean success{get;set;}
        @AuraEnabled
        public String returnSTR{get;set;}
    }
}