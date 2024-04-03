public class RDCCExpiryUpdateController {
    @AuraEnabled
    public static npe03__Recurring_Donation__c getRD(String recId){
        return [Select Id,npsp__CardExpirationMonth__c,npsp__CardExpirationYear__c,Card_Token__c from npe03__Recurring_Donation__c where Id=:recId ];
    }
    @AuraEnabled
    public static void updateExpiry(String recId,String month,String year){
        system.debug('Month>>>>>>>>>>>'+month);
        system.debug('Year>>>>>>>>>>>'+year);
        npe03__Recurring_Donation__c rd = [Select Id,npsp__CardExpirationMonth__c,npsp__CardExpirationYear__c,Card_Token__c from npe03__Recurring_Donation__c where Id=:recId ];
        if(month == ''){
            month = rd.npsp__CardExpirationMonth__c;
        }
        if(year == ''){
            year = rd.npsp__CardExpirationYear__c;
        }
        system.debug('After Month>>>>>>>>>>>'+month);
        system.debug('After Year>>>>>>>>>>>'+year);
        String statusMessage='';
        if(Integer.valueOf(month) >0 && Integer.valueOf(month) < 10){
            month = '0'+Integer.valueOf(month);
        }
        try {
            BamboraAPI__c bamboraSettings = BamboraAPI__c.getValues('Bambora');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(bamboraSettings.TokeniseCC_API__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
            requestXML += ' xmlns:sipp="http://www.ippayments.com.au/interface/api/sipp">';
            requestXML += '<soapenv:Header/>';
            requestXML += '<soapenv:Body>';
            requestXML += '<sipp:TokeniseCreditCard>';
            requestXML += '<sipp:tokeniseCreditCardXML>';
            requestXML += '<![CDATA[';
            requestXML += '<TokeniseCreditCard>';
            requestXML += '<CustomerStorageNumber>'+bamboraSettings.Customer_Storage_Number__c+'</CustomerStorageNumber> ';
            requestXML += '<CustNumber></CustNumber>';
            requestXML += '<TokeniseAlgorithmID>8</TokeniseAlgorithmID>';
            requestXML += '<CardNumber>'+rd.Card_Token__c+'</CardNumber>';
            requestXML += '<ExpM>'+month+'</ExpM>';
            requestXML += '<ExpY>'+year+'</ExpY>';
            requestXML += '<UserName>'+bamboraSettings.Username__c+'</UserName> ';
            requestXML += '<Password>'+bamboraSettings.Password__c+'</Password>';
            requestXML += '</TokeniseCreditCard>';
            requestXML += ']]>';
            requestXML += '</sipp:tokeniseCreditCardXML>';
            requestXML += '</sipp:TokeniseCreditCard>';
            requestXML += '</soapenv:Body>';
            requestXML += '</soapenv:Envelope>';
            request.setBody(requestXML);
            System.debug('requestXML'+requestXML);
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            
            if(response.getStatusCode() == 200) {
                System.debug('Sucess responseResult'+response);
               String jsonStr = XMLParser.xmlToJson(response.getBody().replaceAll('&lt;','<').replaceAll('&gt;','>') );
                    System.debug('jsonStr'+jsonStr);
                    
                    UpdateExpiryJson obj = (UpdateExpiryJson) System.JSON.deserialize(jsonStr, UpdateExpiryJson.class);
                    System.debug('obj'+obj);
                    TokeniseCreditCardResponse creditcardResponce = obj.Envelope.Body.TokeniseCreditCardResponse.TokeniseCreditCardResult.TokeniseCreditCardResponse;    
                    if(creditcardResponce.ReturnValue == '0' && creditcardResponce.token != null){
                        String ccToken = creditcardResponce.token;
                        if(ccToken == rd.Card_Token__c){
                            rd.npsp__CardExpirationMonth__c = month;
                            rd.npsp__CardExpirationYear__c = year;
                            update rd;
                        }else{
                            throw new AuraHandledException('There is some problems with Credit Card Token. Please Contact Administrator.');
                        }
                    }else{
                        statusMessage = 'Expiry update failed. ';
                         String returnValue = creditcardResponce.ReturnValue;
                            switch on returnValue {
                                when '1' {
                                    statusMessage+=' Reason : Invalid username/password';
                                }
                                when '2' {
                                    statusMessage+=' Reason : User does not belong to an API User Group';
                                }
                                when '4' {
                                    statusMessage+=' Reason : Invalid CustomerStorageNumber';
                                }
                                when '99' {
                                    statusMessage+=' Reason : Exception encountered';
                                }
                                when else {
                                    System.debug('Error with no Return Value');
                                }
                            }
                        System.debug('statusMessage1:::::::'+statusMessage);
                        throw new AuraHandledException(statusMessage);
                    }
                
                
            }else{
                //HTTP failed response (no equals 200)
                System.debug('Error responseResult'+response);
                statusMessage  ='Error responseResult'+response;
                throw new AuraHandledException('Error responseResult:::'+statusMessage);
            }
        }catch(exception e){
            System.debug('RDCCExpiryUpdateController:::::::'+e.getMessage());
            System.debug('statusMessage3:::::::'+statusMessage);
            if(statusMessage != ''){
                throw new AuraHandledException(statusMessage);
            }else{
                throw new AuraHandledException('Error:::'+e.getMessage());
            }
            
        }
    }
    
    public class UpdateExpiryJson{
        public Envelope Envelope{get;set;}
        
    }
    public class Envelope{
        public Body Body{get;set;}
    }
    public class Body{
        public TokeniseCreditCardResponse TokeniseCreditCardResponse{get;set;}
    }
    public class TokeniseCreditCardResponse{
        //public String ExpY{get;set;}
        //public String ExpM{get;set;}
        public TokeniseCreditCardResult TokeniseCreditCardResult{get;set;}
        //public String TruncatedCard{get;set;}
        //public String CardType{get;set;}
        public String Token{get;set;}
        public String ReturnValue{get;set;}
        public String DeclinedMessage{get;set;}
        
    }
    public class TokeniseCreditCardResult{
        public TokeniseCreditCardResponse TokeniseCreditCardResponse{get;set;}
    }
}