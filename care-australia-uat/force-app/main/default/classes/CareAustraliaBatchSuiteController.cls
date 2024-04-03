/**
 * @description       : 
 * @author            : Borath En
 * @group             : 
 * @last modified on  : 10-12-2021
 * @last modified by  : Borath En
**/
public with sharing class CareAustraliaBatchSuiteController {
    //Wrapper class for ApexJobWrapper
    class apexJobWrapper{
        String Id;
        String Status;
        String ApexClass;
        Integer JobItemsProcessed;
        Integer TotalJobItems;
        Integer NumberOfErrors;
        String SubmittedBy;
        DateTime CreatedDate;
    }

    @AuraEnabled(cacheable=true)
    public static String fetchAsyncJobList(){
        Map<String,Object> resMap = new Map<String,Object>();
        List<ApexJobWrapper> apexJobWrapperList = new List<apexJobWrapper>();
        for(AsyncApexJob  asyncJob : [SELECT Id, Status, ApexClass.Name, JobItemsProcessed, TotalJobItems, 
        NumberOfErrors, CreatedBy.Name, CreatedDate
        FROM AsyncApexJob 
        WHERE ApexClassId != null AND JobType='BatchApex'
        ORDER BY CreatedDate DESC 
        LIMIT 20]){
            apexJobWrapper apexJob = new apexJobWrapper();
            apexJob.Id = asyncJob.Id;
            apexJob.Status = asyncJob.Status;
            apexJob.ApexClass = asyncJob.ApexClass.Name;
            apexJob.JobItemsProcessed = asyncJob.JobItemsProcessed;
            apexJob.TotalJobItems = asyncJob.TotalJobItems;
            apexJob.NumberOfErrors = asyncJob.NumberOfErrors;
            apexJob.SubmittedBy = asyncJob.CreatedBy.Name;
            apexJob.CreatedDate = asyncJob.CreatedDate;
            apexJobWrapperList.add(apexJob);
        }
        resMap.put('apexJobLst',apexJobWrapperList);
        return JSON.serialize(resMap);
    }
    @AuraEnabled(cacheable=true)
    public static String executeBatchableProcess(String batchName){
        Map<String,Object> resMap = new Map<String,Object>();
        Boolean isSuccess = false;
        String msg ='';
        Decimal batchSize = 25;

        try{
            if(batchName==NULL || batchName==''){
                msg='Batch name is blank.';
                isSuccess = false;
            }
            else{
                List<ApexClass> apexClassList = [SELECT Id, Name FROM ApexClass WHERE Name=:batchName ORDER BY CreatedDate DESC LIMIT 1];
                List<AsyncApexJob> asyncJobLst = [SELECT Id, ApexClassId, Status FROM AsyncApexJob where ApexClassId=:ApexClassList[0].Id 
                AND JobType='BatchApex' AND Status IN ('Processing', 'Queued', 'Holding')];
                if(asyncJobLst.size()>0){
                    msg='Select Batch '+ batchName +' is already in progress.';
                    isSuccess = false;
                }
                else{
                    msg = batchName+ 'is submitted sucessfully for.';
                    isSuccess = true;
                    switch on batchName {
                        when  'ProcessPaymentCCBatch' {
                            //submit Credit Card payments
                            ProcessPaymentCCBatch ppccb = new ProcessPaymentCCBatch();
                            Database.executeBatch(ppccb,50);
                        }
                        when 'ProcessPaymentDDBatch' {
                            //submit Direct Debit payments
                            ProcessPaymentDDBatch ppddb = new ProcessPaymentDDBatch();
                            Database.executeBatch(ppddb,50);
                        }
                        when 'AuthorizePaymentBatch' {
                            //Authorise batch process
                            AuthorizePaymentBatch apb= new AuthorizePaymentBatch();
                            Database.executeBatch(apb,5);
                        }
                        when 'RetrievePaymentBatch' {
                            //Retrieve Payment Batches and update payment records
                            RetrievePaymentBatch rpb = new RetrievePaymentBatch();
                            Database.executeBatch(rpb,1);                         
                        }
                        when 'RDSchedulableBatch' {
                            //Retrieve Payment Batches and update payment records
                            RDSchedulableBatch rdsb = new RDSchedulableBatch();
                            Database.executeBatch(rdsb);  
                        }
                        when 'TM_ConversionSelectionCriteriaBatch' {
                            //Retrieve Payment Batches and update payment records
                            TM_ConversionSelectionCriteriaBatch tmConversion = new TM_ConversionSelectionCriteriaBatch();
                            Database.executeBatch(tmConversion);  
                        }                        
                        when 'TM_SelectionCriteriaBatch' {
                            //Retrieve Payment Batches and update payment records
                            TM_SelectionCriteriaBatch tmUpdate = new TM_SelectionCriteriaBatch();
                            Database.executeBatch(tmUpdate);  
                        }
                        when 'TM_ReactivatesSelectionCriteriaBatch' {
                            //Retrieve Payment Batches and update payment records
                            TM_ReactivatesSelectionCriteriaBatch tmReactivates = new TM_ReactivatesSelectionCriteriaBatch();
                            Database.executeBatch(tmReactivates);  
                        }
                        when 'TM_DeclineSelectionCriteriaBatch' {
                            //Retrieve Payment Batches and update payment records
                            TM_DeclineSelectionCriteriaBatch tmDecline = new TM_DeclineSelectionCriteriaBatch();
                            Database.executeBatch(tmDecline);  
                        }                                                                        
                        
                        when else {
                            msg = 'Batch not found: '+batchName;
                            isSuccess = false;
                        }
                    }
                }
            }
        }
        catch(Exception ex){
            msg = 'Exception: '+ex.getMessage();
        }
        resMap.put('isSuccess', isSuccess);
        resMap.put('msg',msg);
        return JSON.serialize(resMap);
    }
}