public without sharing class StripePaymentController {
    @AuraEnabled(cacheable=true)
    public static Stripe_Payment_Configs__mdt getStripePaymentConfigs() {
        Stripe_Payment_Configs__mdt metadataRecords = [SELECT Allow_Apple_Pay__c, Allow_Credit_Card__c, Allow_Google_Pay__c, Allow_Paypal__c, VF_page_domain__c, Constant_Contact_Id__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
    	return metadataRecords;
    }
    
	@AuraEnabled
    public static StripePaymentResponseWrapper processPaymentByCard(Id contactId, String tokenId, String paymentTypeId, Decimal amount, List<Id> transactionsIds, Decimal usedLenderBalance, String email, String fullLenderName) {
        StripePaymentResponseWrapper responseWrapper = new StripePaymentResponseWrapper();
        Map<String, Object> paymentResponse = createCustomerAndProcessCharge(responseWrapper, contactId, tokenId, paymentTypeId, amount, true);
               
        if(!responseWrapper.isError) {
            Contact con = [SELECT Id, FirstName, LastName, Name, Email, Phone, Stripe_Customer_Id__c, CurrencyIsoCode, AccountId FROM Contact WHERE Id = :contactId];
            CheckoutUtility.lenderName = fullLenderName;
            CheckoutUtility.processTransactionsAndPayment(transactionsIds, con, usedLenderBalance, paymentResponse, email);   
        }
        
        return responseWrapper;
    }
    
    @AuraEnabled
    public static StripePaymentResponseWrapper processPaymentByWallet(Id contactId, String tokenId, Decimal amount, List<Id> transactionsIds, Decimal usedLenderBalance, String email, String fullLenderName) {
        StripePaymentResponseWrapper responseWrapper = new StripePaymentResponseWrapper();
        responseWrapper.isError = false;
        
        Boolean isNewCustomer = false;
        
        Contact con = [SELECT Id, FirstName, LastName, Name, Email, Phone, Stripe_Customer_Id__c, CurrencyIsoCode, AccountId FROM Contact WHERE Id = :contactId];
        
        String stripeCustomerId = con.Stripe_Customer_Id__c;
        
        Map<String, String> contactRequestParameters = new Map<String, String>();
        
        if(stripeCustomerId == null || String.isEmpty(stripeCustomerId)) {
            setCustomerRequests(contactRequestParameters, con);
            isNewCustomer = true;
        }

        Map<String, Object> paymentResponse = new Map<String, Object>();
            
        if(String.isNotBlank(tokenId)){
            HttpResponse customerResponse = StripeConnection.postCustomer(stripeCustomerId, createRequestBody(contactRequestParameters));
            Map<String, Object> customerMap = (Map<String, Object>) JSON.deserializeUntyped(customerResponse.getBody());
        
            if(customerResponse.getStatusCode() == 200) {
                Map<String, String> paymentIntent = new Map<String, String>{
                    'amount' => String.valueOf(Integer.valueOf(amount*100)),
                    'currency' => con.CurrencyIsoCode,
                    'customer' => String.valueOf(customerMap.get('id')),
                    'confirm' => 'true',
                    'payment_method' => tokenId,
                    'metadata[is_processed]' => 'true',
                    'metadata[care_product]' => 'LWC'
                };
            
                HttpResponse paymentIntentResponse = StripeConnection.postPaymentIntent('', createRequestBody(paymentIntent));
                
                if(paymentIntentResponse.getStatusCode() != 200) {
                    if(isNewCustomer) {
                        StripeConnection.deleteCustomer(stripeCustomerId);
                    }
                    updateErrorInResponse(responseWrapper, paymentIntentResponse.getBody());
                } else {
                    paymentResponse = (Map<String, Object>) JSON.deserializeUntyped(paymentIntentResponse.getBody());
                }
            } else {
                updateErrorInResponse(responseWrapper, customerResponse.getBody());
            }
        }
        
        if(!responseWrapper.isError) {
            CheckoutUtility.lenderName = fullLenderName;
            CheckoutUtility.processTransactionsAndPayment(transactionsIds, con, usedLenderBalance, paymentResponse, email);   
        }

        return responseWrapper;
    }
    
    @AuraEnabled
    public static StripePaymentResponseWrapper processRD(Id contactId, String tokenId, String paymentTypeId, Decimal amount, String cardResponse) {
        StripePaymentResponseWrapper responseWrapper = new StripePaymentResponseWrapper();
      	createCustomerAndProcessCharge(responseWrapper, contactId, tokenId, paymentTypeId, amount, false);
        
        if(!responseWrapper.isError) {
            Contact con = [SELECT Id, FirstName, LastName, Name, Email, Phone, Stripe_Customer_Id__c, CurrencyIsoCode, AccountId FROM Contact WHERE Id = :contactId];
            CheckoutUtility.processRD(con, amount,(Map<String, Object>) JSON.deserializeUntyped(cardResponse));   
        }
        
        return responseWrapper;
    }
    
    @AuraEnabled
    public static StripePaymentResponseWrapper processPayPal(Id contactId, String paymentResponse, List<Id> transactionsIds, Decimal usedLenderBalance, String email, String fullLenderName) {
        StripePaymentResponseWrapper responseWrapper = new StripePaymentResponseWrapper();
        responseWrapper.isError = false;
        
        Contact con = [SELECT Id, FirstName, LastName, Name, Email, Phone, Stripe_Customer_Id__c, CurrencyIsoCode, AccountId FROM Contact WHERE Id = :contactId];
        CheckoutUtility.lenderName = fullLenderName;
        CheckoutUtility.processTransactionsAndPayment(transactionsIds, con, usedLenderBalance, (Map<String, Object>) JSON.deserializeUntyped(paymentResponse), email);
        
        return responseWrapper;
    }
    
    private static Map<String, Object> createCustomerAndProcessCharge(StripePaymentResponseWrapper responseWrapper, Id contactId, String tokenId, String paymentTypeId, Decimal amount, Boolean processCharge) {
        responseWrapper.isError = false;
        
        Boolean isNewCustomer = false;
        
        Contact con = [SELECT Id, FirstName, LastName, Name, Email, Phone, Stripe_Customer_Id__c, CurrencyIsoCode, AccountId FROM Contact WHERE Id = :contactId];
        
        String stripeCustomerId = con.Stripe_Customer_Id__c;
        
        Map<String, String> contactRequestParameters = new Map<String, String>();
        
        if(String.isNotBlank(tokenId)) {
         	contactRequestParameters.put('source', tokenId);   
        }
        
        if(stripeCustomerId == null || String.isEmpty(stripeCustomerId)) {
            setCustomerRequests(contactRequestParameters, con);
            isNewCustomer = true;
        } else {
            if(String.isNotBlank(tokenId)) {
             	HttpResponse customerSourceResponse = StripeConnection.postCustomerSource(stripeCustomerId, createRequestBody(contactRequestParameters));
                if(customerSourceResponse.getStatusCode() == 200) {
                    contactRequestParameters = new Map<String, String>{
                        'default_source' => paymentTypeId  
                    };
                } else {
                    updateErrorInResponse(responseWrapper, customerSourceResponse.getBody());
                }   
            }
        }
        
         Map<String, Object> paymentResponse = new Map<String, Object>();
        
        if(!responseWrapper.isError) {
            HttpResponse customerResponse = StripeConnection.postCustomer(stripeCustomerId, createRequestBody(contactRequestParameters));
            Map<String, Object> customerMap = (Map<String, Object>) JSON.deserializeUntyped(customerResponse.getBody());
            if(customerResponse.getStatusCode() == 200) {
                stripeCustomerId = String.valueOf(customerMap.get('id'));
                if(String.isNotBlank(tokenId) && processCharge) {
                    paymentResponse = createChargeOnStripe(responseWrapper, String.valueOf(customerMap.get('id')), amount, con.CurrencyIsoCode, isNewCustomer);
                }
            } else {
                updateErrorInResponse(responseWrapper, customerResponse.getBody());
            }
        }
        
        if(!responseWrapper.isError) {
            con.Stripe_Customer_Id__c = stripeCustomerId;
            update con;
        }
		
        return paymentResponse;
    }
    
    private static void setCustomerRequests(Map<String, String> contactRequestParameters, Contact con) {
        contactRequestParameters.put('name', con.Name);
        contactRequestParameters.put('phone', con.Phone);
        contactRequestParameters.put('metadata[sf_contact_id]', con.Id);
        contactRequestParameters.put('metadata[firstName]', (!String.isEmpty(con.FirstName) ? con.FirstName + ' ': ''));
        contactRequestParameters.put('metadata[lastName]', (!String.isEmpty(con.LastName) ? con.LastName + ' ': ''));
        if(!String.isEmpty(con.Email)){
            String email = con.Email.replace('+', '%2B');
            contactRequestParameters.put('email', email);
        }
    }
    
    private static Map<String, Object> createChargeOnStripe(StripePaymentResponseWrapper responseWrapper, String stripeCustomerId, Decimal amount, String currencyIsoCode, Boolean isNewCustomer) {
        Map<String, String> chargeRequestParameters = new Map<String, String>{
        	'amount' => String.valueOf(Integer.valueOf(amount*100)),
        	'currency' => currencyIsoCode,
        	'customer' => stripeCustomerId,
            'metadata[is_processed]' => 'true',
            'metadata[donation_source]' => 'Web',
            'metadata[care_product]' => 'LWC'
        };
       	HttpResponse chargeResponse = StripeConnection.postCharge(createRequestBody(chargeRequestParameters));
        
        if(chargeResponse.getStatusCode() != 200) {
            if(isNewCustomer) {
                StripeConnection.deleteCustomer(stripeCustomerId);
            }
            updateErrorInResponse(responseWrapper, chargeResponse.getBody());
        } else {
            return (Map<String, Object>) JSON.deserializeUntyped(chargeResponse.getBody());
        }
        
        return new Map<String, Object>();
    }
    
    private static void updateErrorInResponse(StripePaymentResponseWrapper responseWrapper, String response) {
        Map<String, Object> callbackResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> errorResponse = (Map<String, Object>) callbackResponse.get('error');
        
        responseWrapper.isError = true;
        responseWrapper.message = String.valueOf(errorResponse.get('message'));
    }
    
    private static String createRequestBody(Map<String, String> requestParameters) {
        String requestBody = '';
        for(String key: requestParameters.keySet()) {
            String value = requestParameters.get(key);
            if(String.isEmpty(requestBody) && value.trim().length() > 0 && value != null){
                requestBody += key + '=' + value;
            }else{
                requestBody += '&' + key + '=' + value;
            }
        }
        return requestBody;
    }
    
    public class StripePaymentResponseWrapper {
        @AuraEnabled
        public Boolean isError { get; set; }
        @AuraEnabled
        public String message { get; set; }
    }
}