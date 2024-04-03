public class MakePaymentController {
    public String ccToken {get; set;}
    public String recordId {get; set;}
    public String merchantGUID {get; set;}
    public boolean showSuccessMessage {get; set;}
    public boolean showErrorMessage {get; set;}
    public String statusMessage {get; set;}
    public String statusCode {get; set;}
    public Decimal paymentAmount {get; set;}
    
    public BamboraAPI__c bamboraSettings = BamboraAPI__c.getValues('Bambora');
    
    public void initVFP()
    {
        merchantGUID = bamboraSettings.Merchant_ID__c;   
        recordId = ApexPages.CurrentPage().getParameters().get('id').escapeHtml4();
        paymentAmount =[SELECT Id, npe01__Payment_Amount__c FROM npe01__OppPayment__c Where id=:recordId].npe01__Payment_Amount__c;
        showSuccessMessage = false;
        showErrorMessage = false;
        statusMessage = '\u2714 New Token Generated and added to Recurring Donation.';
        system.debug('recordId++'+recordId);
    }
    public void makePayment() {
        try{
            
            npe01__OppPayment__c payment = [SELECT Id,Name, Payment_Status__c, npe01__Paid__c,npe01__Opportunity__r.npe03__Recurring_Donation__c,npsp__Card_Expiration_Month__c, 
                                            npsp__Card_Expiration_Year__c, npe01__Payment_Amount__c,npe01__Opportunity__c,Payment_Result__c, Response_Code__c, 
                                            Result_Description__c, npe01__Payment_Method__c,npe01__Opportunity__r.npsp__Primary_Contact__c,npe01__Check_Reference_Number__c,npe01__Written_Off__c  
                                            FROM npe01__OppPayment__c Where id=:recordId limit 1 ];
            
            String stt = ApexPages.CurrentPage().getParameters().get('stt');
            String payeeName = ApexPages.CurrentPage().getParameters().get('payeeName');
             System.debug('::::::::::::::::payeeName::::::::::::::::::::'+payeeName);
            System.debug('::::::::::::::::stt::::::::::::::::::::'+stt);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(bamboraSettings.Payment_API__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            String requestXML ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
            requestXML +='xmlns:dts="http://www.ippayments.com.au/interface/api/dts">';
            requestXML +='<soapenv:Header/>';
            requestXML +='<soapenv:Body>';
            requestXML +='<dts:SubmitSinglePayment>';
            requestXML +='<dts:trnXML>';
            requestXML +='<![CDATA[';
            requestXML +='<Transaction>';
            requestXML +='<CustNumber>'+payment.npe01__Opportunity__r.npsp__Primary_Contact__c+'</CustNumber> ';
            requestXML +='<CustRef>'+payment.Name+'</CustRef>';
            requestXML +='<Amount>'+(paymentAmount*100)+'</Amount>';
            requestXML +='<TrnType>1</TrnType>';
            requestXML +='<AccountNumber>'+bamboraSettings.Cash_Account_Number__c+'</AccountNumber>';
            requestXML +='<CreditCard>';
            requestXML +='<SecureTransactionToken>'+stt+'</SecureTransactionToken>';
            requestXML +='</CreditCard>';
            requestXML +='<AdditionalReturnValues>';
            requestXML +='<CardType>true</CardType>';
            requestXML +='<TruncatedCard>true</TruncatedCard>';
            requestXML +='<ExpM>true</ExpM>';
            requestXML +='<ExpY>true</ExpY>';
            requestXML +='</AdditionalReturnValues>';
            requestXML +='<Security>';
            requestXML +='<UserName>'+bamboraSettings.Cash_Username__c+'</UserName>';
            requestXML +='<Password>'+bamboraSettings.Cash_Password__c+'</Password>';
            requestXML +='</Security>';
            requestXML +='</Transaction>';
            requestXML +=']]>    ';
            requestXML +='</dts:trnXML>';
            requestXML +='</dts:SubmitSinglePayment>';
            requestXML +='</soapenv:Body>';
            requestXML +='</soapenv:Envelope>';
            System.debug('requestXML'+requestXML);
            request.setBody(requestXML);
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200) {
                System.debug('body'+response.getBody());
                System.debug('R'+response);
                
                String jsonStr = XMLParser.xmlToJson(response.getBody().replaceAll('&lt;','<').replaceAll('&gt;','>') );
                
                System.debug('jsonStr'+jsonStr);
                
                PaymentJson obj = new PaymentJson();
                
                
                obj = (PaymentJson) System.JSON.deserialize(jsonStr.replaceAll('\n',''), PaymentJson.class);		
                
                
                System.debug('obj'+obj);
                Response res = obj.Envelope.Body.SubmitSinglePaymentResponse.SubmitSinglePaymentResult.Response;
                System.debug('res'+res);
                
                
                if(res.ResponseCode == 0){
                    
                    statusMessage = '\u2714 Payment of Amount '+paymentAmount+' successfully submitted.';
                    
                    payment.Card_Number_Masked__c = res.TruncatedCard;
                    payment.Card_Type__c = res.CardType;
                    payment.npe01__Payment_Date__c  = date.today();
                    payment.npe01__Paid__c = true;
                    payment.Payment_Result__c = 'Success';
                    payment.npsp__Card_Expiration_Month__c = String.valueOf(res.ExpM);
                    payment.npsp__Card_Expiration_Year__c = String.valueOf(res.ExpY);
                    payment.npe01__Check_Reference_Number__c = String.valueOf(res.Receipt);
                    payment.Merchant_Category__c = 'Bambora';
                    payment.Response_Code__c = '0';
                    payment.Result_Description__c = 'Approved';
                    payment.Payee_Name__c = payeeName;
                    update payment;
                     
                    showSuccessMessage = true;
                }else{
                    
                    Map<String,RG_Response__c> rgResponceMap = new Map<String,RG_Response__c>();
                    for(RG_Response__c rgResponce : [SELECT Id, Financial_Institution_Name__c, Merchant_Category__c, 
                                                     Payment_Method__c, Response_Code__c, Result_Description__c, Response_Code_Ref__c, Payment_Result__c FROM RG_Response__c])
                    {
                        rgResponceMap.put(rgResponce.Response_Code__c,rgResponce);
                    }
                    System.debug('rgResponceMap:::::::::::'+rgResponceMap);
                    
                    showErrorMessage = true;
                    statusMessage = 'Payment Failed.';
                    res.DeclinedCode = String.valueOf(Integer.valueOf(res.DeclinedCode));
                    if(rgResponceMap.get(String.valueOf(res.DeclinedCode)) != null){
                        
                        statusMessage +=' Reason : ' + rgResponceMap.get(String.valueOf(res.DeclinedCode)).Result_Description__c;
                        
                        payment.Card_Number_Masked__c = res.TruncatedCard;
                        payment.Card_Type__c = res.CardType;
                        payment.npe01__Payment_Date__c  = date.today();
                        payment.npsp__Card_Expiration_Month__c = String.valueOf(res.ExpM);
                        payment.npsp__Card_Expiration_Year__c = String.valueOf(res.ExpY);
                        payment.npe01__Check_Reference_Number__c = String.valueOf(res.Receipt);
                        payment.Payee_Name__c = payeeName;
                        payment.Merchant_Category__c = rgResponceMap.get(String.valueOf(res.DeclinedCode)).Merchant_Category__c;
                        payment.Payment_Result__c = rgResponceMap.get(String.valueOf(res.DeclinedCode)).Payment_Result__c;
                        payment.Response_Code__c = rgResponceMap.get(String.valueOf(res.DeclinedCode)).Response_Code__c;
                        payment.Result_Description__c = rgResponceMap.get(String.valueOf(res.DeclinedCode)).Result_Description__c;
                        update payment;
                    } else{
                        statusMessage += ' Payment Gateway Error (Bambora): ' + res.DeclinedCode+' - '+res.DeclinedMessage;
                        
                        payment.Card_Number_Masked__c = res.TruncatedCard;
                        payment.Card_Type__c = res.CardType;
                        payment.npe01__Payment_Date__c  = date.today();
                        payment.npsp__Card_Expiration_Month__c = String.valueOf(res.ExpM);
                        payment.npsp__Card_Expiration_Year__c = String.valueOf(res.ExpY);
                        payment.Payee_Name__c = payeeName;
                        payment.npe01__Check_Reference_Number__c = String.valueOf(res.Receipt);
                        payment.Merchant_Category__c = 'Bambora';
                        payment.Payment_Result__c = 'ERROR';
                        payment.Response_Code__c = res.DeclinedCode;
                        payment.Result_Description__c = 'Payment Gateway Error (Bambora): '+' - '+res.DeclinedMessage;
                        update payment;
                    }
                }
                
                
            }else{
                showErrorMessage = true;
                System.debug('Error Responce'+response);
                statusMessage = 'Payment Failed. Reason : '+response;
            }
        }catch(exception e){
            System.debug('showSuccessMessage:::::::'+showSuccessMessage);
            System.debug('showErrorMessage:::::::'+showErrorMessage);
            showErrorMessage = true;
            System.debug('exception:::::::'+e.getMessage());
            statusMessage = 'Payment Failed. Reason : '+e.getMessage();
            
            //Adde error message to Apex DebugLog
            ApexDebugLog__c apexDebugLog = new ApexDebugLog__c();
            apexDebugLog.ApexClass__c = 'MakePaymentController';
            apexDebugLog.Method__c = 'MakePaymentController.makePayment()';
            apexDebugLog.Message__c = e.getMessage();
            apexDebugLog.StackTrace__c = e.getStackTraceString();
            apexDebugLog.Type__c  = 'Error';
            apexDebugLog.RecordIdData__c = recordId;
            insert apexDebugLog;
        } 
    }
    @AuraEnabled
    public static npe01__OppPayment__c getPaymentRecords(String paymentId){
        npe01__OppPayment__c payment = [SELECT Id, Payment_Status__c, npe01__Paid__c,npe01__Opportunity__r.npe03__Recurring_Donation__c,npsp__Card_Expiration_Month__c, 
                                        npsp__Card_Expiration_Year__c, npe01__Payment_Amount__c,npe01__Opportunity__c,Payment_Result__c, Response_Code__c, npe01__Written_Off__c,
                                        Result_Description__c, npe01__Payment_Method__c FROM npe01__OppPayment__c Where id=:paymentId  ];
        return payment;
    }
    public class PaymentJson{
        public Envelope Envelope{get;set;}
        
    }
    public class Envelope{
        public Body Body{get;set;}
    }
    public class Body{
        public SubmitSinglePaymentResponse SubmitSinglePaymentResponse{get;set;}
    }
    public class SubmitSinglePaymentResult{
        public Response Response{get;set;}
    }
    public class SubmitSinglePaymentResponse{
        public SubmitSinglePaymentResult SubmitSinglePaymentResult{get;set;}
    }
    public class Response{
        public String TruncatedCard{get;set;}
        public String CardType{get;set;}
        public String DeclinedMessage{get;set;}
        public Integer ExpM{get;set;}
        public String DeclinedCode{get;set;}
        public Integer ExpY{get;set;}
        public String SettlementDate{get;set;}
        public Integer Receipt{get;set;}
        public String Timestamp{get;set;}
        public Integer ResponseCode{get;set;}
    }
    
    
}