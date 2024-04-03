/**
* @class             : AuthorizePaymentBatch
* @description       : Authorize Payments.
* @created on        : 09-07-2021
* @group             : 
* @last modified on  : 09-07-2021
**/
global class AuthorizePaymentBatch implements Database.Batchable<sObject>,  Database.AllowsCallouts  ,schedulable {
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Name, CreatedDate, Payment_Method__c, Scheduled_Date__c, Batch_Unique_Identifier__c, Batch_Status__c,Status_Description__c ';
        query +='FROM RG_Processing_Batch__c Where Batch_Status__c = \'Submitted\' and Scheduled_Date__c <= today';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<RG_Processing_Batch__c> scope) {
        if(scope!=null && !scope.isEmpty()) {
             BamboraAPI__c bamboraSettings = BamboraAPI__c.getValues('Bambora');
            for(RG_Processing_Batch__c rgProcessBatch  : scope ){
                try {
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(bamboraSettings.Batch_API__c);
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                    String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
                    requestXML += 'xmlns:bat="http://www.ippayments.com.au/interface/api/batch">';
                    requestXML += '<soapenv:Header/><soapenv:Body><bat:AuthoriseBatchTrnFile>';
                    requestXML += '<bat:userName>'+bamboraSettings.Username__c+'</bat:userName> ';
                    requestXML += '<bat:password>'+bamboraSettings.Password__c+'</bat:password>';
                    requestXML += '<bat:uniqueBatchIdentifier>'+rgProcessBatch.Batch_Unique_Identifier__c+'</bat:uniqueBatchIdentifier>';
                    requestXML += '</bat:AuthoriseBatchTrnFile></soapenv:Body></soapenv:Envelope>';
                    request.setBody(requestXML);
                    HttpResponse response = http.send(request);
                    // If the request is successful, parse the JSON response.
                    if(response.getStatusCode() == 200) {
                        System.debug('body'+response.getBody());
                        System.debug('R'+response);
                        try {
                            String jsonStr = XMLParser.xmlToJson(response.getBody());
                            
                            System.debug('jsonStr'+jsonStr);
                            AuthorizeJSON obj = (AuthorizeJSON) System.JSON.deserialize(jsonStr, AuthorizeJSON.class);
                            System.debug('obj'+obj);
                            System.debug('obj'+obj.Envelope.Body.AuthoriseBatchTrnFileResponse.AuthoriseBatchTrnFileResult);
                            AuthoriseBatchTrnFileResponse responce = obj.Envelope.Body.AuthoriseBatchTrnFileResponse;
                            System.debug('responce'+responce);
                            
                            
                            if(responce.AuthoriseBatchTrnFileResult == '0'){
                                System.debug(':::::Batch has been authorised and Processing has been initiated::::');
                                if(rgProcessBatch.Payment_Method__c == 'Credit Card'){
                                     rgProcessBatch.Batch_Status__c = 'Authorized';
                                }else  if(rgProcessBatch.Payment_Method__c == 'Direct Debit'){
                                    rgProcessBatch.Batch_Status__c = 'On Hold';
                                }
                               
                                rgProcessBatch.Status_Description__c ='Batch has been authorised and Processing has been initiated';
                                
                                
                            }else{
                                switch on responce.AuthoriseBatchTrnFileResult {
                                    when '1' {
                                        System.debug(':::::Invalid username/password::::');
                                        rgProcessBatch.Status_Description__c ='Invalid username/password';
                                    }
                                    when '2' {
                                        System.debug(':::::User does not have permission to authorise batch files::::');
                                        rgProcessBatch.Status_Description__c ='User does not have permission to authorise batch files';
                                    }
                                    when '3' {
                                        System.debug(':::::Invalid batch number::::');
                                        rgProcessBatch.Status_Description__c ='Invalid batch number';
                                    }
                                    when '4' {
                                        System.debug(':::::Batch has been cancelled::::');
                                        rgProcessBatch.Status_Description__c ='Batch has been cancelled';
                                    }
                                    when '5' {
                                        System.debug(':::::Batch has already been authorised::::');
                                        rgProcessBatch.Status_Description__c ='Batch has already been authorised';
                                    }
                                    when '99' {
                                        System.debug(':::::Exception encountered::::');
                                        rgProcessBatch.Status_Description__c ='Exception encountered';
                                    }
                                    when else {
                                        System.debug('::::::::::::::Error with no AuthoriseBatchTrnFileResult Value::::::::::::::');
                                        rgProcessBatch.Status_Description__c ='Error with no AuthoriseBatchTrnFileResult Value';
                                    }
                                }
                                
                            }
                        }catch(exception e){
                            //Json Error
                            System.debug('exception:::::::'+e.getMessage());
                            rgProcessBatch.Status_Description__c ='Failed - '+ e.getMessage();
                        }
                        
                    }else{
                        System.debug('Error Responce'+response);
                        rgProcessBatch.Status_Description__c ='Error Responce - '+ response;
                    }
                }catch(exception e){
                    //HTTP Error
                    System.debug('exception:::::::'+e.getMessage());
                    rgProcessBatch.Status_Description__c ='Failed - '+ e.getMessage();
                }        
            }
            try{
                update scope;
            }catch(exception e){
                //RG Process Batch update error
                System.debug('exception:::::::'+e.getMessage());
            }     
        }
    }
    global void finish(Database.BatchableContext bc) {
        // finish code
        System.debug('Finished');
    }
    global void execute(SchedulableContext sc) {
        database.executebatch(new AuthorizePaymentBatch(),10);
    }
    public class AuthorizeJSON{
        public Envelope Envelope{get;set;}
    }
    
    public class Envelope{
        public Body Body{get;set;}
    }
    public class Body{
        public AuthoriseBatchTrnFileResponse AuthoriseBatchTrnFileResponse{get;set;}
    }
    public class AuthoriseBatchTrnFileResponse{
        public String AuthoriseBatchTrnFileResult{get;set;}
    }
    
    
}