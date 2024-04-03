/**
* @class             : ProcessPaymentCCBatch
* @description       : Processing recurring donation Credit Card payments.
* @created on        : 09-06-2021
* @group             : 
* @last modified on  : 09-06-2021
**/
global class ProcessPaymentCCBatch implements Database.Batchable<sObject>,  Database.AllowsCallouts ,schedulable {
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,Name,npe01__Opportunity__c,Donor_Name__c ,npe01__Opportunity__r.npe03__Recurring_Donation__c, npe01__Check_Reference_Number__c,';
        query +=' npe01__Custom_Payment_Field__c, npe01__Paid__c, npe01__Payment_Amount__c, npe01__Payment_Date__c, npe01__Payment_Method__c, ';
        query +='npe01__Scheduled_Date__c, npe01__Written_Off__c, npsp__Payment_Acknowledged_Date__c, Payment_Status__c, npsp__Batch_Number__c, ';
        query +='Receipted_On__c, Card_Token__c, Card_Number_Masked__c, Card_Type__c, Payee_Name__c, Payment_Result__c, Response_Code__c,npsp__Card_Expiration_Month__c,npsp__Card_Expiration_Year__c ';
        query +='FROM npe01__OppPayment__c where npe01__Opportunity__r.npe03__Recurring_Donation__c != Null and Payment_Result__c = \'Not Processed\' and ';
        query +='npe01__Scheduled_Date__c <= today and npe01__Paid__c= false and npe01__Payment_Method__c =\'Credit Card\' and npe01__Written_Off__c = false and Card_Token__c != null ';
        query +=' and npe01__Opportunity__r.npe03__Recurring_Donation__r.npsp__Status__c = \'Active\' ';
        query +=' and npe01__Opportunity__r.npe03__Recurring_Donation__r.Payment_Gateway__c != \'Stripe\' ';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<npe01__OppPayment__c> scope) {
        if(scope!=null && !scope.isEmpty()) {
            BamboraAPI__c bamboraSettings = BamboraAPI__c.getValues('Bambora');
            RG_Processing_Batch__c rgProcessBatch = new RG_Processing_Batch__c();
            rgProcessBatch.Batch_Status__c = 'Submitted';
            rgProcessBatch.Scheduled_Date__c = Date.today();
            rgProcessBatch.Payment_Method__c = 'Credit Card';
            //insert rgProcessBatch;
            //rgProcessBatch = [SELECT Id, Name, Payment_Method__c, Scheduled_Date__c, 
            //                Batch_Unique_Identifier__c, Batch_Status__c, Total_Transactions__c, Total_Amount__c FROM RG_Processing_Batch__c where Id=:rgProcessBatch.Id limit 1];
            system.debug('rgProcessBatch::::::::::'+rgProcessBatch);
            List<npe01__OppPayment__c>paymentList = scope;
            rgProcessBatch.Batch_Unique_Identifier__c ='CC_'+Datetime.now().format('yyyyMMddHHmmSS');
            //String  header = rgProcessBatch.Name + ',' + rgProcessBatch.Name+'_'+rgProcessBatch.Payment_Method__c +'_'+ Datetime.now().format('yyyyMMdd');
            String  header = rgProcessBatch.Batch_Unique_Identifier__c+',RegularGiving_'+rgProcessBatch.Payment_Method__c +'_'+ Datetime.now().format('yyyyMMdd');
            String details = '';
            String payeeName = '';
            Decimal totalAmount = 0;
            for(npe01__OppPayment__c oppPay : paymentList ){
                if(oppPay.Payee_Name__c != null){
                    payeeName = oppPay.Payee_Name__c.replace(',','-');
                }
                details += bamboraSettings.RG_Account_Number__c+',1,'+''+oppPay.Card_Token__c +','+oppPay.npsp__Card_Expiration_Month__c+''+oppPay.npsp__Card_Expiration_Year__c;
                details +=','+payeeName+','+oppPay.Name+','+oppPay.Id+','+integer.valueof(oppPay.npe01__Payment_Amount__c*100)+',,,,,,';
                totalAmount += oppPay.npe01__Payment_Amount__c;
                details += '\r\n';
                //oppPay.RG_Processing_Batch__c = rgProcessBatch.Id;
                //oppPay.Payment_Result__c = 'Processing';
            }
            system.debug('details::::::::::'+details);
            if(details != ''){
                String footer = ''+integer.valueof(paymentList.size())+','+integer.valueof(totalAmount*100)+'';
                system.debug('footer::::::::::'+footer);
                String finalString = header +'\r\n'+details+''+footer;
                system.debug('finalString::::::::::'+finalString);
                
                rgProcessBatch.Total_Amount__c =totalAmount;
                rgProcessBatch.Total_Transactions__c =paymentList.size();
                String fileName = Datetime.now().format('yyyyMMddHHmm');
                Attachment attachment = new Attachment();
                attachment.Body = Blob.valueOf(finalString);
                attachment.Name = String.valueOf(fileName+'.csv');
                
                // insert attachment;
                system.debug('attachment::::::::::'+attachment);
                String base64String = EncodingUtil.base64Encode(Blob.valueof(finalString));
                Integer filelength = Blob.valueof(finalString).size();
                system.debug('base64String::::::::::'+base64String);
                system.debug('filelength::::::::::'+filelength);
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(bamboraSettings.Batch_API__c);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
                requestXML += 'xmlns:bat="http://www.ippayments.com.au/interface/api/batch">';
                requestXML += '<soapenv:Header/>';
                requestXML += '<soapenv:Body>';
                requestXML += '<bat:SubmitBatchTrnFile>';
                requestXML += '<bat:trn>';
                requestXML += '<bat:userName>'+bamboraSettings.Username__c+'</bat:userName>';
                requestXML += '<bat:password>'+bamboraSettings.Password__c+'</bat:password>';
                requestXML += '<bat:description>upload_batch</bat:description>';
                requestXML += '<bat:batchNumber>'+rgProcessBatch.Batch_Unique_Identifier__c+'</bat:batchNumber>';
                requestXML += '<bat:trnTypes>1</bat:trnTypes>';
                requestXML += '<bat:zipped>false</bat:zipped>';
                requestXML += '<bat:fileLength>'+filelength+'</bat:fileLength>';
                requestXML += '<bat:fileCRC32>0</bat:fileCRC32>';
                requestXML += '<bat:b64TransactionFileData>'+base64String+'</bat:b64TransactionFileData>';
                requestXML += '</bat:trn>';
                requestXML += '</bat:SubmitBatchTrnFile>';
                requestXML += '</soapenv:Body>';
                requestXML += '</soapenv:Envelope>';
                system.debug('requestXML::::::::::'+requestXML);
                request.setBody(requestXML);
                HttpResponse response = http.send(request);
                // If the request is successful, parse the JSON response.
                if(response.getStatusCode() == 200) {
                    System.debug('body'+response.getBody());
                    System.debug('R'+response);
                    try {
                        String jsonStr = XMLParser.xmlToJson(response.getBody());
                        System.debug('jsonStr'+jsonStr);
                        
                        CCSubmitBatchJson obj = new CCSubmitBatchJson();
                        obj = (CCSubmitBatchJson) System.JSON.deserialize(jsonStr, CCSubmitBatchJson.class);        
                        
                        
                        System.debug('obj'+obj);
                        SubmitBatchTrnFileResult result = obj.Envelope.Body.SubmitBatchTrnFileResponse.SubmitBatchTrnFileResult;
                        System.debug('result'+result);
                        
                        
                        if(result.resultSummary == '0'){
                            try {
                                insert rgProcessBatch;
                                attachment.ParentId = rgProcessBatch.Id; 
                                insert attachment;
                                
                                list<Id> oppIdList = new list<Id>();
                                for(npe01__OppPayment__c oppPay : paymentList ){
                                    oppPay.RG_Processing_Batch__c = rgProcessBatch.Id;
                                    oppPay.Payment_Result__c = 'Processing';
                                    oppIdList.add(oppPay.npe01__Opportunity__c);
                                    
                                }
                                System.debug('paymentList:::::::'+paymentList);
                                
                                
                                try {
                                    update paymentList;
                                }catch(exception e){
                                    //paymentList update error
                                    System.debug('paymentList - exception:::::::'+e.getMessage());
                                }
                                list<opportunity> oppListToUpdate = [Select Id, StageName From Opportunity Where Id IN:oppIdList];
                                if(oppListToUpdate != null){
                                    for(opportunity opp : oppListToUpdate ){  
                                        opp.StageName = 'Processing';
                                    } 
                                }
                                 System.debug('oppListToUpdate:::::::'+oppListToUpdate);
                                
                                
                                try {
                                    update oppListToUpdate;
                                }catch(exception e){
                                    //oppListToUpdate update error
                                    System.debug('oppListToUpdate - exception:::::::'+e.getMessage());
                                }
                            }catch(exception e){
                                //RG_Processing_Batch insert error
                                System.debug('exception:::::::'+e.getMessage());
                            }
                        }else{
                            System.debug('resultSummary:::::::'+result.resultSummary);
                            System.debug('resultMessage:::::::'+result.resultMessage);
                        }
                        
                    }catch(exception e){
                        //Json Error
                        System.debug('exception:::::::'+e.getMessage());
                    }
                    
                    
                }else{
                    //HTTP error
                    System.debug('Error Responce'+response);
                }
                
            }
            
            
            
            
        }
    }
    global void finish(Database.BatchableContext bc) {
        // finish code
        System.debug('Finished');
    }
    global void execute(SchedulableContext sc) {
        database.executebatch(new ProcessPaymentCCBatch(),50);
    }
    public class CCSubmitBatchJson{
        public Envelope Envelope{get;set;} 
    }
    public class SubmitBatchTrnFileResult{
        public String resultMessage{get;set;}
        public String uniqueBatchIdentifier{get;set;}
        public String resultSummary{get;set;}
    }
    public class SubmitBatchTrnFileResponse{
        public SubmitBatchTrnFileResult SubmitBatchTrnFileResult{get;set;}
    }
    public class Envelope{
        public Body Body{get;set;}
    }
    public class Body{
        public SubmitBatchTrnFileResponse SubmitBatchTrnFileResponse{get;set;}
    }
}