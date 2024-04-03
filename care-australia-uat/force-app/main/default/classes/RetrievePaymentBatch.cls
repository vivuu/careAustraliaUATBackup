/**
* @class             : RetrievePaymentBatch
* @description       : Retrieve Payments Result.
* @created on        : 10-07-2021
* @group             : 
* @last modified on  : 10-07-2021
**/
global class RetrievePaymentBatch implements Database.Batchable<sObject>,  Database.AllowsCallouts  ,schedulable {
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Name, CreatedDate, Payment_Method__c, Scheduled_Date__c, Batch_Unique_Identifier__c, Batch_Status__c,Status_Description__c ';
        query +='FROM RG_Processing_Batch__c Where Batch_Status__c = \'Authorized\' ';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<RG_Processing_Batch__c> scope) {
        if(scope!=null && !scope.isEmpty()) {
            BamboraAPI__c bamboraSettings = BamboraAPI__c.getValues('Bambora');
            RG_Process_Value__mdt rgProcessValue = [Select Failed_Consecutive_Opportunities__c,Next_Payment_Retry_Days__c,Retry_Attempt__c,Payment_Limit__c From RG_Process_Value__mdt limit 1];
            
            List<npe01__OppPayment__c> paymentList = new List<npe01__OppPayment__c>();
            List<npe01__OppPayment__c> paymentListToCreate = new List<npe01__OppPayment__c>();
            List<npe03__Recurring_Donation__c> rdListtoUpdateHeldStatus = new List<npe03__Recurring_Donation__c>();
            List<npe03__Recurring_Donation__c> rdListtoUpdateFailedOpp = new List<npe03__Recurring_Donation__c>();
            List<npe03__Recurring_Donation__c> rdListtoResetFailedOpp = new List<npe03__Recurring_Donation__c>();
            List<Opportunity> oppListToUpdateCloseStatus = new List<Opportunity>();
            List<Opportunity> oppListToUpdateRetry = new List<Opportunity>();
            Attachment attachment = new Attachment();
            
            List<Id> failHardRDIDList = new List<Id>();
            List<Id> failSoftRDIDList = new List<Id>();
            List<Id> closeOppIDList = new List<Id>();
            List<Id> failSoftRetryOppIDList = new List<Id>();
            List<Id> resetRDIDList = new List<Id>();
            
            //Map for storing response code and response code details
            Map<String,RG_Response__c> rgresponseResultMap = new Map<String,RG_Response__c>();
            for(RG_Response__c rgresponseResult : [SELECT Id, Financial_Institution_Name__c, Merchant_Category__c, 
                                                   Payment_Method__c, Response_Code__c, Result_Description__c, Response_Code_Ref__c, Payment_Result__c FROM RG_Response__c])
            {
                rgresponseResultMap.put(rgresponseResult.Response_Code__c,rgresponseResult);
            }
            System.debug('rgresponseResultMap:::::::::::'+rgresponseResultMap);
            
            //key = payment Id and value = PaymentResponseWrapper(Contains result code, Error Code, Error Description and Reciept)
            Map<String,PaymentResponseWrapper> paymentResponseMap = new Map<String,PaymentResponseWrapper>();
            
            //For checking week days
           	Integer nextPaymentRetryDays = Integer.valueOf(rgProcessValue.Next_Payment_Retry_Days__c);
            DateTime myDateTime = (DateTime)Date.today() + nextPaymentRetryDays;
            String dayOfWeek = myDateTime.format('EEEE');
            system.debug(':::::::::dayOfWeek:::::::'+dayOfWeek); 
            Date scheduledDate ;
            if(dayOfWeek == 'Saturday'){
                scheduledDate =Date.today() + nextPaymentRetryDays + 2;
            }else if(dayOfWeek == 'Sunday'){
                scheduledDate =Date.today() + nextPaymentRetryDays + 1;
            }else{
                scheduledDate =Date.today() + nextPaymentRetryDays;
            }
            system.debug(':::::::::scheduledDate:::::::'+scheduledDate); 
            
            for(RG_Processing_Batch__c rgProcessBatch  : scope ){
                try {
                    
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(bamboraSettings.Batch_API__c);
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                    String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
                    requestXML += 'xmlns:bat="http://www.ippayments.com.au/interface/api/batch">';
                    requestXML += '<soapenv:Header/>';
                    requestXML += '<soapenv:Body>';
                    requestXML += '<bat:RetrieveBatchResultFile>';
                    requestXML += '<bat:userName>'+bamboraSettings.Username__c+'</bat:userName>';
                    requestXML += '<bat:password>'+bamboraSettings.Password__c+'</bat:password>';
                    requestXML += '<bat:uniqueBatchIdentifier>'+rgProcessBatch.Batch_Unique_Identifier__c+'</bat:uniqueBatchIdentifier>';
                    requestXML += '<bat:zipped>false</bat:zipped>';
                    requestXML += '</bat:RetrieveBatchResultFile>';
                    requestXML += '</soapenv:Body>';
                    requestXML += '</soapenv:Envelope>';
                    request.setBody(requestXML);
                    HttpResponse response = http.send(request);
                    // If the request is successful, parse the JSON response.
                    if(response.getStatusCode() == 200) {
                        System.debug('body'+response.getBody());
                        System.debug('R'+response);
                        try {
                            //parse XML response to JSON
                            String jsonStr = XMLParser.xmlToJson(response.getBody());
                            
                            System.debug('jsonStr'+jsonStr);
                            RetrieveBatchJson obj = (RetrieveBatchJson) System.JSON.deserialize(jsonStr, RetrieveBatchJson.class);
                            System.debug('obj'+obj);
                            RetrieveBatchResultFileResult responseResult = obj.Envelope.Body.RetrieveBatchResultFileResponse.RetrieveBatchResultFileResult;
                            System.debug('responseResult'+responseResult);
                            
                            if(responseResult.batchStatus == '0'){
                                rgProcessBatch.Batch_Status__c = 'Completed';
                                rgProcessBatch.Status_Description__c = 'Batch Process Successfully Completed';
                                
                                //Decode base64 data to blob
                                Blob blobDecodeBase64 = EncodingUtil.base64decode(responseResult.b64ResultFileData);
                                system.debug('blobDecodeBase64:::::::'+blobDecodeBase64);
                                //convet blob to string
                                String decodedCSV = blobDecodeBase64.toString();
                                system.debug('decodedCSV:::::::'+decodedCSV);
                                //csv sting split into rows(string array)
                                String[] csvFileLines = decodedCSV.split('\r\n');
                                system.debug('csvFileLinessixe:::::::'+csvFileLines.size());
                                system.debug('csvFileLines:::::::'+csvFileLines);
                                
                                //Response csv file added to RG processing batch record 
                                String fileName ='Bambora Response-'+Datetime.now().format('yyyyMMddHHmm');
                                attachment.Body = Blob.valueOf(decodedCSV);
                                attachment.Name = String.valueOf(fileName+'.csv');
                                attachment.ParentId = rgProcessBatch.Id;
                                system.debug('attachment:::::::'+attachment);
                                
                                if(csvFileLines.size() > 1){
                                    rgProcessBatch.Total_Processed_Transactions__c = csvFileLines.size() - 2;
                                    Integer i;                                
                                    if(rgProcessBatch.Payment_Method__c == 'Direct Debit'){
                                        
                                        for(i = 1 ; i< csvFileLines.size() - 1 ; i++){
                                            //Direct Debit
                                            String[] paymentCSVRowsDD = csvFileLines[i].split(',');
                                            //Initialize PaymentResponseWrapper wrapper class
                                            PaymentResponseWrapper paymentresponseResult = new PaymentResponseWrapper(paymentCSVRowsDD[1],paymentCSVRowsDD[2],paymentCSVRowsDD[3],paymentCSVRowsDD[7]);
                                            //add payment ID to Key
                                            paymentResponseMap.put(paymentCSVRowsDD[5].replaceAll('"','') ,paymentresponseResult);
                                            
                                        }
                                    }else if(rgProcessBatch.Payment_Method__c == 'Credit Card'){
                                        //Credit Card
                                        for(i = 1 ; i< csvFileLines.size() - 1 ; i++){
                                            String[] paymentCSVRowsCC = csvFileLines[i].split(',');
                                            //Initialize PaymentResponseWrapper wrapper class
                                            PaymentResponseWrapper paymentresponseResult = new PaymentResponseWrapper(paymentCSVRowsCC[2],paymentCSVRowsCC[3],paymentCSVRowsCC[4],paymentCSVRowsCC[8]);
                                            //add payment ID to Key
                                            paymentResponseMap.put(paymentCSVRowsCC[6].replaceAll('"','') ,paymentresponseResult);
                                        }
                                    } 
                                    system.debug('paymentResponseMap:::::::'+paymentResponseMap);
                                    
                                }else{
                                    System.debug(':::::No Data Retrieved::::');
                                    rgProcessBatch.Batch_Status__c = 'Authorize';
                                    rgProcessBatch.Status_Description__c ='No Data Retrieved';
                                }
                                
                                
                            }else{
                                rgProcessBatch.Batch_Status__c = 'Authorized';
                                //batch responseResult not 0
                                switch on responseResult.batchStatus {
                                    when '1' {
                                        System.debug(':::::Invalid username/password::::');
                                        rgProcessBatch.Status_Description__c ='Invalid username/password';
                                    }
                                    when '2' {
                                        System.debug(':::::User does not have permission to retrieve batch files::::');
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
                                        System.debug(':::::Batch is pending, waiting for authorisation::::');
                                        rgProcessBatch.Status_Description__c ='Batch is pending, waiting for authorisation';
                                    }
                                    when '6' {
                                        System.debug(':::::Processing::::');
                                        rgProcessBatch.Status_Description__c ='Processing';
                                    }
                                    when '7' {
                                        System.debug(':::::Processing::::');
                                        rgProcessBatch.Status_Description__c ='Processing';
                                    }
                                    when '99' {
                                        System.debug(':::::Exception encountered::::');
                                        rgProcessBatch.Status_Description__c ='Batch exception threshold exceeded';
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
                            rgProcessBatch.Batch_Status__c = 'Authorized';
                            rgProcessBatch.Status_Description__c ='Failed - '+ e.getMessage();
                        }
                    }else{
                        //HTTP failed response (no equals 200)
                        System.debug('Error responseResult'+response);
                        rgProcessBatch.Batch_Status__c = 'Authorized';
                        rgProcessBatch.Status_Description__c ='Failed - '+ response;
                    }
                }catch(exception e){
                    //HTTP Error
                    System.debug('exception:::::::'+e.getMessage());
                    rgProcessBatch.Batch_Status__c = 'Authorized';
                    rgProcessBatch.Status_Description__c ='Failed - '+ e.getMessage();
                } 
            }
            try{
                //check payment Id keyset
                if(paymentResponseMap.keySet() != null){
                    Integer PaymentLimit = Integer.valueOf(rgProcessValue.Payment_Limit__c);
                    paymentList =  [SELECT Id,Name,npe01__Opportunity__c,Donor_Name__c,npe01__Opportunity__r.npe03__Recurring_Donation__c,
                                    npe01__Opportunity__r.Retry_Attempt__c,Payment_Result__c,npe01__Payment_Date__c,Merchant_Category__c,Response_Code__c,
                                    Result_Description__c,npe01__Payment_Amount__c, npe01__Payment_Method__c, 
                                    npe01__Scheduled_Date__c, npsp__Card_Expiration_Month__c, npsp__Card_Expiration_Year__c, Payee_Name__c,
                                    Account_BSB__c, Account_Number__c, Card_Number_Masked__c, Card_Token__c, Card_Type__c, RG_Processing_Batch__c,
                                    Financial_Institution__c FROM npe01__OppPayment__c where Id IN:  paymentResponseMap.keySet() and 
                                    Payment_Result__c ='Processing' and npe01__Written_Off__c = false limit : PaymentLimit ];
                    for(RG_Processing_Batch__c rgProcessBatch  : scope){
                        
                        
                        if(paymentResponseMap.keySet() != null){
                            System.debug('rgProcessBatch.Id:::::::'+rgProcessBatch.Id);
                            for(npe01__OppPayment__c payment : paymentList ){
                                
                                if(payment.RG_Processing_Batch__c == rgProcessBatch.Id ){
                                    //success response
                                    if(paymentResponseMap.get(payment.Id).Result == '0'){
                                        payment.npe01__Payment_Date__c  = date.today();
                                        payment.npe01__Paid__c = true;
                                        payment.Payment_Result__c = 'Success';
                                        payment.npe01__Check_Reference_Number__c = paymentResponseMap.get(payment.Id).Receipt;
                                        payment.Merchant_Category__c = 'Bambora';
                                        payment.Response_Code__c = '0';
                                        payment.Result_Description__c = rgresponseResultMap.get('0').Result_Description__c;
                                        //reset failed consecutive opportunities to 0
                                        resetRDIDList.add(payment.npe01__Opportunity__r.npe03__Recurring_Donation__c);
                                        
                                    }else{
                                        //Fail Hard or Fail Soft response
                                        if(paymentResponseMap.get(payment.Id).ErrorCode != null){
                                            String errorCode = paymentResponseMap.get(payment.Id).ErrorCode;
                                            if(rgresponseResultMap.get(errorCode) != null){
                                                payment.npe01__Payment_Date__c  = date.today();
                                                payment.Payment_Result__c = rgresponseResultMap.get(errorCode).Payment_Result__c ;
                                                payment.npe01__Check_Reference_Number__c = paymentResponseMap.get(payment.Id).Receipt;
                                                payment.Merchant_Category__c = rgresponseResultMap.get(errorCode).Merchant_Category__c;
                                                payment.Response_Code__c = rgresponseResultMap.get(errorCode).Response_Code__c;
                                                payment.Result_Description__c = rgresponseResultMap.get(errorCode).Result_Description__c;
                                                if(rgresponseResultMap.get(errorCode).Payment_Result__c == 'Fail Hard'){
                                                    failHardRDIDList.add(payment.npe01__Opportunity__r.npe03__Recurring_Donation__c);
                                                    //payment.npe01__Written_Off__c = true;
                                                    closeOppIDList.add(payment.npe01__Opportunity__c);
                                                }
                                                if(rgresponseResultMap.get(errorCode).Payment_Result__c == 'Fail Soft'){
                                                    Decimal Retry_Attempt = 1;
                                                    if(payment.npe01__Opportunity__r.Retry_Attempt__c != null){
                                                        Retry_Attempt = payment.npe01__Opportunity__r.Retry_Attempt__c +1;
                                                    }
                                                    
                                                    if(Retry_Attempt < rgProcessValue.Retry_Attempt__c   && rgProcessBatch.Payment_Method__c == 'Credit Card'){
                                                        failSoftRetryOppIDList.add(payment.npe01__Opportunity__c);
                                                        // Create new payment record;
                                                        
                                                        
                                                        paymentListToCreate.add(new npe01__OppPayment__c (npe01__Opportunity__c = payment.npe01__Opportunity__c,
                                                                                                          Payment_Result__c = 'Not Processed',
                                                                                                          npe01__Payment_Amount__c = payment.npe01__Payment_Amount__c, 
                                                                                                          npe01__Payment_Method__c = payment.npe01__Payment_Method__c, 
                                                                                                          npe01__Scheduled_Date__c = scheduledDate, 
                                                                                                          npsp__Card_Expiration_Month__c = payment.npsp__Card_Expiration_Month__c, 
                                                                                                          npsp__Card_Expiration_Year__c = payment.npsp__Card_Expiration_Year__c,
                                                                                                          Payee_Name__c = payment.Payee_Name__c, 
                                                                                                          Card_Number_Masked__c = payment.Card_Number_Masked__c, 
                                                                                                          Card_Token__c = payment.Card_Token__c, 
                                                                                                          Card_Type__c = payment.Card_Type__c));
                                                        
                                                        
                                                        
                                                        
                                                    }else{
                                                        
                                                        closeOppIDList.add(payment.npe01__Opportunity__c);
                                                        failSoftRDIDList.add(payment.npe01__Opportunity__r.npe03__Recurring_Donation__c);
                                                        //close Lost opportunity
                                                        //Increment Failed Consecutive Opportunities by 1
                                                    }
                                                    
                                                }
                                                
                                                
                                            }else{
                                                //ERROR response
                                                payment.npe01__Payment_Date__c  = date.today();
                                                payment.Payment_Result__c = 'ERROR' ;
                                                //payment.npe01__Written_Off__c = true;
                                                payment.npe01__Check_Reference_Number__c = paymentResponseMap.get(payment.Id).Receipt;
                                                payment.Merchant_Category__c ='Bambora';
                                                payment.Response_Code__c = paymentResponseMap.get(payment.Id).ErrorCode;
                                                payment.Result_Description__c = 'Payment Gateway Error (Bambora): '+' - '+ paymentResponseMap.get(payment.Id).ErrorDescription;
                                                closeOppIDList.add(payment.npe01__Opportunity__c);
                                            }
                                            
                                        }else{
                                            system.debug(':::::::::ErrorCode is Null:::::::'); 
                                        }
                                        
                                    } 
                                }
                            }    
                        }else{
                            system.debug(':::::::::paymentResponseMap.keySet() is Null:::::::'); 
                            rgProcessBatch.Batch_Status__c = 'Authorized';
                            rgProcessBatch.Status_Description__c ='Failed - payment responseResult is Null';
                        }
                    }
                    
                }
                //reset RD Failed Consecutive Opportunities
                if(resetRDIDList != null){
                    system.debug(':::::::::resetRDIDList:::::::'+resetRDIDList.size());
                    for(npe03__Recurring_Donation__c rd : [Select Id,Failed_Consecutive_Opportunities__c,npsp__Status__c ,npsp__ClosedReason__c
                                                           From npe03__Recurring_Donation__c where Id IN:resetRDIDList and Failed_Consecutive_Opportunities__c != 0])
                    {											
                        rd.Failed_Consecutive_Opportunities__c = 0;
                        rdListtoResetFailedOpp.add(rd) ;                                                            
                    }  
                    
                }
                
                //update RD to Held
                if(failHardRDIDList != null){
                    system.debug(':::::::::failHardRDIDList:::::::'+failHardRDIDList);
                    for(npe03__Recurring_Donation__c rd : [Select Id,On_Held_Date__c,npsp__Status__c ,npsp__ClosedReason__c
                                                           From npe03__Recurring_Donation__c where Id IN:failHardRDIDList])
                    {											
                        rd.npsp__ClosedReason__c = 'Failed Hard Payment Transaction';
                        rd.npsp__Status__c = 'Held';
                        rd.On_Held_Date__c = date.today();
                        rdListtoUpdateHeldStatus.add(rd) ;                                                            
                    }  
                }
                //update RD Failed Consecutive Opportunities
                if(failSoftRDIDList != null){
                    system.debug(':::::::::failSoftRDIDList:::::::'+failSoftRDIDList);
                    for(npe03__Recurring_Donation__c rd : [Select Id,Failed_Consecutive_Opportunities__c,npsp__Status__c 
                                                           From npe03__Recurring_Donation__c where Id IN:failSoftRDIDList])
                    {
                        if(rd.Failed_Consecutive_Opportunities__c != null){
                            rd.Failed_Consecutive_Opportunities__c += 1;
                        }else{
                            rd.Failed_Consecutive_Opportunities__c = 1;
                        }
                        rdListtoUpdateFailedOpp.add(rd) ;                                                                
                    } 
                    
                }
                
                //update Opportunity Retry Attempt
                if(failSoftRetryOppIDList != null){
                    system.debug(':::::::::failSoftRetryOppIDList:::::::'+failSoftRetryOppIDList);
                    for(Opportunity opp : [Select Id, StageName,Retry_Attempt__c From Opportunity where Id IN:failSoftRetryOppIDList]){
                        
                        if(opp.Retry_Attempt__c != null){
                            opp.Retry_Attempt__c += 1;
                        }else{
                            opp.Retry_Attempt__c = 1;
                        }           
                        oppListToUpdateRetry.add(opp) ;                                                                
                    } 	
                }
                //update Opportunity Closed Lost
                if(closeOppIDList != null){
                    system.debug(':::::::::closeOppIDList:::::::'+closeOppIDList);
                    
                    for(Opportunity opp : [Select Id, StageName,Retry_Attempt__c,npsp__Closed_Lost_Reason__c From Opportunity where Id IN:closeOppIDList]){
                        
                        opp.StageName = 'Closed Lost'; 
                        opp.npsp__Closed_Lost_Reason__c = 'Payment Transaction was unsuccessful' ;
                        oppListToUpdateCloseStatus.add(opp) ;                                                                
                    } 	
                }
                system.debug(':::::::::paymentListToCreate:::::::'+paymentListToCreate); 
                system.debug(':::::::::paymentListToCreate.size():::::::'+paymentListToCreate.size());
                
                system.debug(':::::::::rdListtoResetFailedOpp:::::::'+rdListtoResetFailedOpp);
                system.debug(':::::::::rdListtoResetFailedOpp.size():::::::'+rdListtoResetFailedOpp.size());
                
                system.debug(':::::::::rdListtoUpdateHeldStatus:::::::'+rdListtoUpdateHeldStatus);
                system.debug(':::::::::rdListtoUpdateHeldStatus.size():::::::'+rdListtoUpdateHeldStatus.size());
                
                system.debug(':::::::::rdListtoUpdateFailedOpp:::::::'+rdListtoUpdateFailedOpp);
                system.debug(':::::::::rdListtoUpdateFailedOpp.size():::::::'+rdListtoUpdateFailedOpp.size());
                
                system.debug(':::::::::oppListToUpdateRetry:::::::'+oppListToUpdateRetry);
                system.debug(':::::::::oppListToUpdateRetry.size():::::::'+oppListToUpdateRetry.size());
                
                system.debug(':::::::::oppListToUpdateCloseStatus:::::::'+oppListToUpdateCloseStatus);
                system.debug(':::::::::oppListToUpdateCloseStatus.size():::::::'+oppListToUpdateCloseStatus.size());
                
                system.debug(':::::::::paymentList:::::::'+paymentList); 
                system.debug(':::::::::paymentList.size():::::::'+paymentList.size());
                
                if(paymentList != null){
                    update paymentList ;
                }
                if(oppListToUpdateCloseStatus != null){
                    update oppListToUpdateCloseStatus; 
                }
                if(oppListToUpdateRetry != null){
                    update oppListToUpdateRetry; 
                }
                if(rdListtoUpdateHeldStatus != null){
                    update rdListtoUpdateHeldStatus; 
                }
                if(rdListtoUpdateFailedOpp != null){
                    update rdListtoUpdateFailedOpp; 
                }
                if(rdListtoResetFailedOpp != null){
                    update rdListtoResetFailedOpp; 
                }
                
                
                if(paymentListToCreate != null){
                    insert paymentListToCreate;    
                }
                system.debug(':::::::::paymentList:::::::'+paymentList); 
                system.debug(':::::::::attachment:::::::'+attachment); 
                if(attachment.ParentId != null){
                    insert attachment;
                }
                
                //processing paymentList
                
               /* List<npe01__OppPayment__c> processingPaymentList = [SELECT Id,Payment_Result__c,RG_Processing_Batch__c 
                                                                    FROM npe01__OppPayment__c where RG_Processing_Batch__c IN:scope and Payment_Result__c ='Processing'];
                system.debug(':::::::::processingPaymentList:::::::'+processingPaymentList.size()); */
                
            } catch(exception e){
                //paymentList update Error
                System.debug('exception:::::::'+e.getMessage());
                for(RG_Processing_Batch__c rgProcessBatch  : scope ){
                    rgProcessBatch.Batch_Status__c = 'Authorized';
                    rgProcessBatch.Status_Description__c ='Failed - '+ e.getMessage() + 'StackTrace : '+e.getStackTraceString();
                }
            }
            try{
                update scope;
            }catch(exception e){
                System.debug('RG Batch Process Update exception:::::::'+e.getMessage());
            }
        }
    }
    global void finish(Database.BatchableContext bc) {
        // finish code
        System.debug('Finished');
    }
    global void execute(SchedulableContext sc) {
        database.executebatch(new RetrievePaymentBatch(),1);
    }
    public class RetrieveBatchJson{
        public Envelope Envelope{get;set;}  
    }
    public class RetrieveBatchResultFileResult{
        public String fileCRC32{get;set;}
        public String fileLength{get;set;}
        public String b64ResultFileData{get;set;}
        public String batchStatus{get;set;}
    }
    public class RetrieveBatchResultFileResponse{
        public RetrieveBatchResultFileResult RetrieveBatchResultFileResult{get;set;}
    }
    public class Envelope{
        public Body Body{get;set;}
    }
    public class Body{
        public RetrieveBatchResultFileResponse RetrieveBatchResultFileResponse{get;set;}
    }
    
    public class PaymentResponseWrapper{
        public String Result{get;set;}
        public String ErrorCode{get;set;}
        public String ErrorDescription{get;set;}
        public String Receipt{get;set;}
        public PaymentResponseWrapper(String Result,String ErrorCode, String ErrorDescription, String Receipt ){
            this.Result = Result;
            this.ErrorCode = ErrorCode;
            this.ErrorDescription = ErrorDescription;
            this.Receipt = Receipt;
            
        }
    }
}