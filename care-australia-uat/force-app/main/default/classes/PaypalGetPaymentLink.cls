public without sharing class PaypalGetPaymentLink 
{
   
    @AuraEnabled(cacheable=true)
    Public static contact getContactForGuest()
    {
        return  [select id from contact where Name='LWC Guest Lender' limit 1];
    }
    
    public class PaymentCapture {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String referenceId { get; set; }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static PaymentCapture capturePayPalOrder(string accesstoken,string orderId) {
        PaypalInformation__mdt PaypalInfo = [SELECT OrderExtra__c,ConfirmOrderUrl__c FROM PaypalInformation__mdt WHERE DeveloperName = 'PaypalSandboxAccessToken'];
        system.debug('accesstoken: '+accesstoken);
        system.debug('orderId: '+orderId);
        String endpointUrl = PaypalInfo.ConfirmOrderUrl__c+orderId+PaypalInfo.OrderExtra__c;
        
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        headers.put('Authorization', 'Bearer '+accesstoken);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('POST');
        
        for (String key : headers.keySet()) {
            req.setHeader(key, headers.get(key));
        }
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 201) {
            String responseBody = res.getBody();
            System.debug('Response Body: ' + responseBody);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            List<Object> purchaseUnits = (List<Object>) responseMap.get('purchase_units');
            if (!purchaseUnits.isEmpty()) {
                Map<String, Object> purchaseUnit = (Map<String, Object>) purchaseUnits[0];
                Map<String, Object> payments = (Map<String, Object>) purchaseUnit.get('payments');
                if (payments != null) {
                    List<Object> captures = (List<Object>) payments.get('captures');
                    if (!captures.isEmpty()) {
                        Map<String, Object> capture = (Map<String, Object>) captures[0];
                        String captureId = (String) capture.get('id');
                        String captureStatus = (String) capture.get('status');
                        String referenceId = (String) purchaseUnit.get('reference_id');
                        PaymentCapture wrapper = new PaymentCapture();
                        wrapper.id = captureId;
                        wrapper.status = captureStatus;
                        wrapper.referenceId = referenceId;
                        return wrapper;
                    }else{
                        return null;  
                    }
                }else{
                    return null;
                }
            }else{
                return null;
            }
            
        } else {
            String errorMessage = 'Error: ' + res.getStatusCode() + ' ' + res.getStatus();
            System.debug(errorMessage);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    Public static string getAccesstoken()
    {
        String clientId;
        String clientSecret;
        String endPointUrl;
        PaypalInformation__mdt PaypalInfo = [SELECT ClientId__c,DeveloperName,ClientSecret__c,EndpointUrl__c FROM PaypalInformation__mdt WHERE DeveloperName = 'PaypalSandboxAccessToken'];
        if( PaypalInfo.ClientId__c!=null)
        {
            clientId= PaypalInfo.ClientId__c;
        }
        if( PaypalInfo.ClientSecret__c!=null)
        {
            clientSecret= PaypalInfo.ClientSecret__c;
        }
        if( PaypalInfo.EndpointUrl__c!=null)
        {
            endPointUrl= PaypalInfo.EndpointUrl__c;
        }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(endPointUrl);
        req.setMethod('POST');
        String authString = clientId + ':' + clientSecret;
        String encodedAuth = EncodingUtil.base64Encode(Blob.valueOf(authString));
        System.debug('encodedAuth: ' + encodedAuth);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic ' + encodedAuth);
        String body = 'grant_type=client_credentials';
        req.setBody(body);
        
        try 
        {
            res = http.send(req);
            if (res.getStatusCode() == 200) 
            {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                String accessToken = (String) jsonResponse.get('access_token');
                System.debug('Access Token: ' + accessToken);
                return accessToken;
                
            } else 
            {
                System.debug('Error: ' + res.getBody());
                return null;
            }
        } catch (Exception e)
        {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
        
    }
    public class MyJsonWrapper {
        @AuraEnabled
        public String successPageUrl { get; set; }
        @AuraEnabled
        public String returnPageUrl { get; set; }
        @AuraEnabled
        public String accesstoken { get; set; }
        @AuraEnabled
        public String refid { get; set; }
        @AuraEnabled
        public String amount { get; set; }
        
    }
    @AuraEnabled(cacheable=true)
    Public static string getPaypalPaymentLink(MyJsonWrapper payment)
    {
        PaypalInformation__mdt PaypalInfo = [SELECT PaymentEndpoint__c FROM PaypalInformation__mdt WHERE DeveloperName = 'PaypalSandboxAccessToken'];
        String successPageUrl = payment.successPageUrl;
        String returnPageUrl = payment.returnPageUrl;
        String accesstoken = payment.accesstoken;
        String refid = payment.refid;
        String amount = payment.amount;
        If(accesstoken!=null){
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint(PaypalInfo.PaymentEndpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+accesstoken);
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            gen.writeStringField('intent', 'CAPTURE');
            gen.writeFieldName('purchase_units');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('reference_id',refid);
            gen.writeFieldName('amount');
            gen.writeStartObject();
            gen.writeStringField('currency_code', 'AUD'); 
            gen.writeStringField('value', amount); 
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('payment_source');
            gen.writeStartObject();
            gen.writeFieldName('paypal');
            gen.writeStartObject();
            gen.writeFieldName('experience_context');
            gen.writeStartObject();
            gen.writeStringField('payment_method_preference', 'IMMEDIATE_PAYMENT_REQUIRED');
            gen.writeStringField('brand_name', 'Care Australia');  //Have to provide valid value
            gen.writeStringField('locale', 'en-AU');
            gen.writeStringField('landing_page', 'LOGIN');
            gen.writeStringField('user_action', 'PAY_NOW');
            gen.writeStringField('return_url', successPageUrl);
            gen.writeStringField('cancel_url', returnPageUrl);
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            String jsonString = gen.getAsString();
            
            System.debug('JSON Payload: ' + jsonString);
            req.setBody(jsonString);
            
            try {
                res = http.send(req);
                if (res.getStatusCode() == 200)
                {
                    Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    
                    List<Object> links = (List<Object>) parsedResponse.get('links');
                    String payerActionHref = null;
                    if(links.size()>0){
                        for (Object link : links) {
                        Map<String, Object> linkMap = (Map<String, Object>) link;
                        String rel = (String) linkMap.get('rel');
                        String href = (String) linkMap.get('href');
                        
                        if (rel != null && rel.equals('payer-action')) {
                            payerActionHref = href;
                            break;
                        }
                    }
                    }
                    System.debug('Payer Action Href: ' + payerActionHref);
                    Return payerActionHref;
                } 
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
                Return Null;
            } 
            Return Null;
        }else{
            Return null;
        }
    }
}