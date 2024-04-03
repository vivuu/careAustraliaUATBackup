/**
 * Class Name: StripeHttpCalloutHelper
 * Auhtor: Gerent Team
 * Description: this file is to provide helper / utility methods to support
 * the Stripe to SFDC Integration
 * Modificatio Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * 						Devansh Jain - 12/09/2022 - Added methods
 * 						Amit Goyal - 13/09/2022 - Code refinement
 * */
public class StripeHttpCalloutHelper {

    //Stripe Config
    public Stripe_Config__mdt calloutMetadata;
    public String base64Str;
    public String className;
    
    public StripeHttpCalloutHelper(String metadataName){
        if(!Test.isRunningTest() && Stripe_Setting__c.getValues('Default').Activation__c){
            //Get the callout details from stripe config metadata
           calloutMetadata = [SELECT DeveloperName,Headerparameters__c, method__c, Endpoint__c, Timeout__c, API_Key__c, isActive__c
                               FROM Stripe_Config__mdt WHERE DeveloperName =: metadataName];
           if(calloutMetaData != null){
               this.base64Str = calloutMetadata.API_Key__c; 
           }   
       }
       
       //remove the following
       if(Test.isRunningTest()) {
           calloutMetadata = [SELECT DeveloperName,Headerparameters__c, method__c, Endpoint__c, Timeout__c, API_Key__c, isActive__c
                              FROM Stripe_Config__mdt WHERE DeveloperName =: metadataName];   
       }
    }
    
    public HttpResponse doCallout(String stripeId, String body){
        // to send callout to stripe and get response
        HttpResponse response = new HttpResponse();
        if(calloutMetadata.isActive__c){
            Http http = new Http();
            if(String.isNotEmpty(body)){
                response = http.send(requestWithYourBody(stripeId, body));
            }else{
                response = http.send(request(stripeId));
            }   
        }else{
            response.setStatusCode(200);
            response.setBody('This is a Mock Response');
        }
        system.debug(response.getBody());
        return response;
    }

    public HttpRequest request(String stripeId){
        //This Helper method is use to create Http Request.
        String endpoint = calloutMetadata.Endpoint__c;
        if(stripeId != null && stripeId != ''){
            endpoint += '/'+stripeId;
        }
        HttpRequest request = new HttpRequest();  
        request.setEndpoint(endpoint);
        request.setMethod(calloutMetadata.Method__c); 
        Map<String,String> headerMap = getHeaderMap(calloutMetadata.HeaderParameters__c);
            if(!headerMap.isEmpty()){
                for(String key : headerMap.keySet()){
                    request.setHeader(key, headerMap.get(key));
                }
            }
        request.setTimeout(Integer.valueOf(calloutMetadata.Timeout__c));
        return request;
    }
    
    public HttpRequest requestWithYourBody(String stripeId, String body){     
        String endpoint = calloutMetadata.Endpoint__c;
        if(stripeId != null && stripeId != ''){
            endpoint += '/'+stripeId;
        }
        HttpRequest request = new HttpRequest();  
        //if(calloutMetadata != null && String.isNotEmpty(body)){
        request.setBody(body);
        request.setEndpoint(endpoint);
        request.setMethod(calloutMetadata.Method__c); 
        //request.setHeader('Authorization', 'Bearer ' + calloutMetadata.API_Key__c);
        request.setTimeout(Integer.valueOf(calloutMetadata.Timeout__c));
        Map<String,String> headerMap = getHeaderMap(calloutMetadata.HeaderParameters__c);
        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                request.setHeader(key, headerMap.get(key));
            }
        }
        return request;
    }
    
    public HttpResponse doCalloutForCustomerSource(String stripeId, String body){ 
    	// to send callout to stripe and get response
        HttpResponse response = new HttpResponse();
        if(calloutMetadata.isActive__c){
            Http http = new Http();
            if(String.isNotEmpty(body)){
                String endpoint = calloutMetadata.Endpoint__c + '/'+stripeId + '/sources';
                HttpRequest request = new HttpRequest();  
                //if(calloutMetadata != null && String.isNotEmpty(body)){
                request.setBody(body);
                request.setEndpoint(endpoint);
                request.setMethod(calloutMetadata.Method__c); 
                //request.setHeader('Authorization', 'Bearer ' + calloutMetadata.API_Key__c);
                request.setTimeout(Integer.valueOf(calloutMetadata.Timeout__c));
                Map<String,String> headerMap = getHeaderMap(calloutMetadata.HeaderParameters__c);
                if(!headerMap.isEmpty()){
                    for(String key : headerMap.keySet()){
                        request.setHeader(key, headerMap.get(key));
                    }
                }
                response = http.send(request);
            }   
        }else{
            response.setStatusCode(200);
            response.setBody('This is a Mock Response');
        }
        system.debug(response.getBody());
        return response;
    }
    
    public HttpResponse doCalloutForInvoiceSearch(String query) {
        // to send callout to stripe and get response
        HttpResponse response = new HttpResponse();
        if(calloutMetadata.isActive__c){
            Http http = new Http();
            String endpoint = calloutMetadata.Endpoint__c + '?query=' + query;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(calloutMetadata.Method__c); 
            request.setTimeout(Integer.valueOf(calloutMetadata.Timeout__c));
            Map<String,String> headerMap = getHeaderMap(calloutMetadata.HeaderParameters__c);
            if(!headerMap.isEmpty()){
                for(String key : headerMap.keySet()){
                    request.setHeader(key, headerMap.get(key));
                }
            }
            response = http.send(request);
        }else{
            response.setStatusCode(200);
            response.setBody('This is a Mock Response');
        }
        system.debug(response.getBody());
        return response;
    }

    private Map<String,String> getHeaderMap(String parameterInfo){
        Map<String, String> parametersMap = new Map<String, String>();
        List<String> parameters = parameterInfo.split('\n');
        for(String urlParam : parameters) {
            List<String> keyValuePair = urlParam.trim().split(':');
            if(!keyValuePair.isEmpty() && keyValuePair.size() == 2) {
                if(String.isNotEmpty(keyValuePair[0]) && String.isNotEmpty(keyValuePair[1])) {
                    parametersMap.put(keyValuePair[0], keyValuePair[1]);
                }
            }
        }
        return parametersMap;
    }
}