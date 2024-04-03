public without sharing class DonorCareProcesswithSSCtrl {
    @AuraEnabled
    public static String getSSUrl(String contactId, String campaignId, String amount, Boolean isRecurring, String rdId, String oppId){
        //https://d11b329c73.i.payline.payshield.com.au/?
        //instance=Stripe-Test-RG-01& [from Sequence_Shift_User__mdt]
        //agent=gavin.mcdonnell@care.org.au& [from Sequence_Shift_User__mdt]
        //signature=7Oi9n0EIzHMYw3fzH3eI3R6QB%2BQE88K2LLZrVsvYXKM=& [from Sequence_Shift_User__mdt]
        //display_token_field=0&
        //amount=1200&
        //amount_read_only=0&
        //callback_url1=https://dev.care.org.au/sequence-shift/sscallback&
        //cardholder_name=Bluey+Heeler&
        //cardholder_name_read_only=0&
        //timestamp=2023-03-29T00:34:31.000Z&
        //custom_parameter_first_name=Bluey&
        //custom_parameter_last_name=Heeler&
        //custom_parameter_phone=123345567&
        //cardholder_email=bluey@healer.abc.net&
        //custom_parameter_donation_source=phone&
        //custom_parameter_sf_contact_id=& [Contact Salesforce-Id]
        //custom_parameter_campaign_id=YERGen-Ph& [Campaign_Code__c field on Campaign]
        //custom_parameter_is_recurring=true& [If the Action=RG]
        //custom_parameter_customer_storage_number=car_57003& [Not Required]
        //custom_parameter_account_number=reg_59009& [Not Required]
        
        try {
            String charSet = 'UTF-8';
            String url = 'https://d11b329c73.i.payline.payshield.com.au/?';
            
            Sequence_Shift_User__mdt shiftUser = getSSUser(isRecurring);
            if(shiftUser == null) {
                throw new NewException('No sequence shift user found.');
            }
            
            List<Contact> contacts = [SELECT firstName, lastName, email, phone FROM Contact WHERE Id = :contactId];
            List<Campaign> campaigns = [SELECT Campaign_Code__c FROM Campaign WHERE Id = :campaignId];
            
            if(contacts.size() == 0) {
                throw new NewException('No contact found.');
            }
            
            if(campaigns.size() == 0) {
                throw new NewException('No campaign found.');
            }
            
            Integer finalAmount = Integer.valueOf(amount) * 100;
            
            Map<String, String> urlParameters = new Map<String, String>();
            urlParameters.put('instance', shiftUser.Instance__c);
            urlParameters.put('agent', shiftUser.Username__c);
            urlParameters.put('display_token_field', '0');
            urlParameters.put('amount', String.valueOf(finalAmount));
            urlParameters.put('amount_read_only', '0');
            urlParameters.put('callback_url1', 'https://dev.care.org.au/sequence-shift/sscallback');
            urlParameters.put('cardholder_name', contacts[0].firstName + '+' + contacts[0].lastName);
            urlParameters.put('cardholder_name_read_only', '0');
            urlParameters.put('timestamp', getCurrentUTCDate());
            urlParameters.put('custom_parameter_first_name', contacts[0].firstName);
            urlParameters.put('custom_parameter_last_name', contacts[0].lastName);
            if(String.isNotBlank(contacts[0].phone)) {
                urlParameters.put('custom_parameter_phone', contacts[0].phone);
            }
            if(String.isNotBlank(contacts[0].email)) {
                urlParameters.put('cardholder_email', contacts[0].email);
            }
            urlParameters.put('custom_parameter_donation_source', 'phone');
            urlParameters.put('custom_parameter_sf_contact_id', String.valueOf(contactId));
            if(String.isNotBlank(campaigns[0].Campaign_Code__c)) {
                urlParameters.put('custom_parameter_campaign_id', campaigns[0].Campaign_Code__c);
            }
            urlParameters.put('custom_parameter_is_recurring', String.valueOf(isRecurring));
            urlParameters.put('display_customer_reference_number1_field', '0');
            if(String.isNotBlank(rdId)) {
                urlParameters.put('custom_parameter_rg_id', rdId);
            }
            if(String.isNotBlank(oppId)) {
                urlParameters.put('custom_parameter_opp_id', oppId);
            }
            //urlParameters.put('custom_parameter_customer_storage_number', 'car_57003');
            //urlParameters.put('custom_parameter_account_number', 'reg_59009'); 
            
            String payload = getEncodedURLParameters(urlParameters, charSet);
            
            String signature = getSignature(payload, shiftUser.Token__c);
            
            url = url + payload + '&signature=' + EncodingUtil.urlEncode(signature, charSet);
            
            return url;
        } catch (Exception ex) {
            throw new NewException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> hangUpCall(Boolean isRecurring) {
        try {
            String charSet = 'UTF-8';
            String url = 'https://f70fb9603a.i.payline.payshield.com.au/end?';
            
            Sequence_Shift_User__mdt shiftUser = getSSUser(isRecurring);
            if(shiftUser == null) {
                throw new NewException('No sequence shift user found.');
            }
            
            Map<String, String> urlParameters = new Map<String, String>();
            urlParameters.put('instance', shiftUser.Instance__c);
            urlParameters.put('agent', shiftUser.Username__c);
            urlParameters.put('timestamp', getCurrentUTCDate());
            urlParameters.put('hangup', 'true');
            
            String payload = getEncodedURLParameters(urlParameters, charSet);
            
            String signature = getSignature(payload, shiftUser.Token__c);
            
            url = url + payload + '&signature=' + EncodingUtil.urlEncode(signature, charSet);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(url);
            request.setHeader('Content-Type', 'application/json');
            
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 301) {
                Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                return responseBody;
            } else {
                throw new NewException('Error in hang up call');
            }
        } catch (Exception ex) {
            throw new NewException(ex.getMessage());
        }
    }

    private static Sequence_Shift_User__mdt getSSUser(Boolean isRecurring){
        system.debug('£££ UserName: '+UserInfo.getFirstName()+' - '+UserInfo.getLastName());
        String userFirstName = Test.isRunningTest() ? 'Gavin' : UserInfo.getFirstName(); 
        String userLastName = Test.isRunningTest() ? 'Mcdonnell' : UserInfo.getLastName();
        String strSoql='Select Id, MasterLabel, DeveloperName, FirstName__c, LastName__c, Username__c, Token__c, Instance__c From Sequence_Shift_User__mdt Where';
        strSoql+=' FirstName__c= :userFirstName AND LastName__c = :userLastName';//Removed the comments from this line.
        if(!isRecurring){
            strSoql+=' AND Instance4Object__c=\'Opportunity\'';
        }else{
            strSoql+=' AND Instance4Object__c=\'RG\'';
        }
        
        list<Sequence_Shift_User__mdt> result = Database.Query(strSoql);
        if(result != null && result.size()>0){
            return result[0];
        }
        return null;
    }
    
    private static String getCurrentUTCDate() {
        Datetime now = System.now();
        return now.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    }
    
    private static String getEncodedURLParameters(Map<String, String> urlParameters, String charSet) {
        List<String> listOfKeys = new List<String>(urlParameters.keySet());
        listOfKeys.sort();
        
        String payload = '';
        
        for(String key: listOfKeys) {
            payload += key + '=' + EncodingUtil.urlEncode(urlParameters.get(key), charSet) + '&';
        }
        
        payload = payload.replace('+', '%20');
        payload = payload.removeEnd('&');
        
        return payload;
    }
    
    private static String getSignature(String urlWithParameters, String accessToken) {
        Blob urlBlob = Blob.valueOf(urlWithParameters);
        Blob tokenBlob = Blob.valueof(accessToken);
        Blob hashToken = Crypto.generateMac('hmacSHA256', urlBlob, tokenBlob);
        return EncodingUtil.base64Encode(hashToken);
    }
    
    public class NewException extends Exception{}
}