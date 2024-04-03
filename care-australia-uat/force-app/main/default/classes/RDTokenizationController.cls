public class RDTokenizationController {
    public String ccToken {get; set;}
    public String recordId {get; set;}
    public String merchantGUID {get; set;}
    public boolean showSuccessMessage {get; set;}
    public boolean showErrorMessage {get; set;}
    public String statusMessage {get; set;}
    public String statusCode {get; set;}
    
    public BamboraAPI__c bamboraSettings = BamboraAPI__c.getValues('Bambora');
    
    public void initVFP()
    {
        merchantGUID = bamboraSettings.Merchant_ID__c;   
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        showSuccessMessage = false;
        showErrorMessage = false;
        statusMessage = '\u2714 New Token Generated and added to Recurring Donation.';
        system.debug('recordId++'+recordId);
    }
    public void getCCToken() {
        
        try{
            String stt = ApexPages.CurrentPage().getParameters().get('stt');
            String payeeName = ApexPages.CurrentPage().getParameters().get('payeeName');
            System.debug('stt::::'+stt);
            //stt='stt_0cdc23ba-b803-456c-afd6-7f73c6dc05f2';
            
            if(stt != null){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(bamboraSettings.TokeniseCC_API__c);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
                requestXML +='xmlns:sipp="http://www.ippayments.com.au/interface/api/sipp">';
                requestXML +='<soapenv:Header/>';
                requestXML +='<soapenv:Body>';
                requestXML +='<sipp:TokeniseCreditCard>';
                requestXML +='<sipp:tokeniseCreditCardXML>';
                requestXML +='<![CDATA[';
                requestXML +='<TokeniseCreditCard>';
                requestXML +='<CustomerStorageNumber>'+bamboraSettings.Customer_Storage_Number__c+'</CustomerStorageNumber>';
                requestXML +='<SecureTransactionToken>'+stt+'</SecureTransactionToken>';
                requestXML +='<TokeniseAlgorithmID>2</TokeniseAlgorithmID>';
                requestXML +='<AdditionalReturnValues>';
                requestXML +='<CardType>true</CardType>';
                requestXML +='<TruncatedCard>true</TruncatedCard>';
                requestXML +='<ExpM>true</ExpM>';
                requestXML +='<ExpY>true</ExpY>';
                requestXML +='</AdditionalReturnValues>';
                requestXML +='<UserName>'+bamboraSettings.Username__c+'</UserName>';
                requestXML +='<Password>'+bamboraSettings.Password__c+'</Password>';
                requestXML +='</TokeniseCreditCard>';
                requestXML +=']]>';
                requestXML +='</sipp:tokeniseCreditCardXML>';
                requestXML +='</sipp:TokeniseCreditCard>';
                requestXML +='</soapenv:Body>';
                requestXML +='</soapenv:Envelope>';
                System.debug('requestXML'+requestXML);
                request.setBody(requestXML);
                HttpResponse response = http.send(request);
                // If the request is successful, parse the JSON response.
                if(response.getStatusCode() == 200) {
                    System.debug('body'+response.getBody());
                    String jsonStr = XMLParser.xmlToJson(response.getBody().replaceAll('&lt;','<').replaceAll('&gt;','>') );
                    System.debug('jsonStr'+jsonStr);
                    
                    TokenJson obj = (TokenJson) System.JSON.deserialize(jsonStr, TokenJson.class);
                    System.debug('obj'+obj);
                    TokeniseCreditCardResponse creditcardResponce = obj.Envelope.Body.TokeniseCreditCardResponse.TokeniseCreditCardResult.TokeniseCreditCardResponse;    
                    if(creditcardResponce.ReturnValue == '0' && creditcardResponce.token != null){
                        ccToken=obj.Envelope.Body.TokeniseCreditCardResponse.TokeniseCreditCardResult.TokeniseCreditCardResponse.token;
                        ccToken = creditcardResponce.token;
                        
                         //showErrorMessage = true;
                        //statusMessage = '\u2714 New Token :'+ccToken;
                        
                        statusMessage = '\u2714 New Token Generated and added to Recurring Donation.';
                        if(recordId != null){
                            npe03__Recurring_Donation__c rd = [SELECT Id, Card_Type__c, Card_Token__c, Payee_Name__c, Card_Number_Masked__c, npsp__CardExpirationMonth__c,
                                                               Account_BSB__c,Account_Number__c,Financial_Institution__c,
                                                               npsp__CardExpirationYear__c FROM npe03__Recurring_Donation__c Where id=:recordId];
                            if(rd != null){
                                rd.Card_Token__c = creditcardResponce.token;
                                rd.Card_Number_Masked__c = creditcardResponce.TruncatedCard;
                                rd.Card_Type__c = creditcardResponce.CardType;
                                rd.npsp__CardExpirationMonth__c  = creditcardResponce.ExpM;
                                rd.npsp__CardExpirationYear__c = creditcardResponce.ExpY;
                                rd.Payee_Name__c = payeeName;
                                rd.npsp__PaymentMethod__c = 'Credit Card';
                                
                                  rd.Account_Number__c = '';
                                   rd.Account_BSB__c = '';
                                  rd.Financial_Institution__c = '';
                            
                                
                                update rd;
                                
                            }
                        }
                        showSuccessMessage = true;
                        
                    }else{
                        showErrorMessage = true;
                        statusMessage = 'Tokenenization Failed.';
                        System.debug('Error Responce'+creditcardResponce.ReturnValue);
                        if(creditcardResponce.DeclinedMessage != null){
                            statusMessage+=' Reason :'+creditcardResponce.DeclinedMessage;
                        }else{
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
                        }
                    }
                    
                }else{
                    showErrorMessage = true;
                    statusMessage = 'Error Responce :'+response;
                    System.debug('Error Responce : '+response+' Contact Administrator.');
                }
                
            }
        }catch(exception e){
            
			showErrorMessage = true;
            System.debug('exception:::::::'+e.getMessage());
            statusMessage = 'Payment Failed. Reason : '+e.getMessage();
            
            //Adde error message to Apex DebugLog
            ApexDebugLog__c apexDebugLog = new ApexDebugLog__c();
            apexDebugLog.ApexClass__c = 'RDTokenizationController';
            apexDebugLog.Method__c = 'MakePaymentController.getCCToken()';
            apexDebugLog.Message__c = e.getMessage();
            apexDebugLog.StackTrace__c = e.getStackTraceString();
            apexDebugLog.Type__c  = 'Error';
            apexDebugLog.RecordIdData__c = recordId;
            insert apexDebugLog;
        } 
        
    }
    @AuraEnabled
    public static npe03__Recurring_Donation__c getRDRecords(String rdId){
        npe03__Recurring_Donation__c rd = [SELECT Id, npsp__PaymentMethod__c FROM npe03__Recurring_Donation__c Where id=:rdId];
        return rd;
    }
    public class TokenJson{
        public Envelope Envelope{get;set;}
        
    }
    public class Envelope{
        public Body Body{get;set;}
    }
    public class Body{
        public TokeniseCreditCardResponse TokeniseCreditCardResponse{get;set;}
    }
    public class TokeniseCreditCardResponse{
        public String ExpY{get;set;}
        public String ExpM{get;set;}
        public TokeniseCreditCardResult TokeniseCreditCardResult{get;set;}
        public String TruncatedCard{get;set;}
        public String CardType{get;set;}
        public String Token{get;set;}
        public String ReturnValue{get;set;}
        public String DeclinedMessage{get;set;}
        
    }
    public class TokeniseCreditCardResult{
        public TokeniseCreditCardResponse TokeniseCreditCardResponse{get;set;}
    }
}