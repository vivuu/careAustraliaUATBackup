/**
 * @description       : 
 * @author            : Borath En
 * @group             : 
 * @last modified on  : 10-07-2021
 * @last modified by  : Borath En
**/
@isTest
public class CareAustraliaBatchSuiteControllerTest {
    public static testMethod void testExecuteBatch_Coverage() {
        CareAustraliaBatchSuiteController.executeBatchableProcess('ProcessPaymentCCBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('ProcessPaymentDDBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('AuthorizePaymentBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('RetrievePaymentBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('ProcessPaymentCCBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('RDSchedulableBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('TM_SelectionCriteriaBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('TM_ConversionSelectionCriteriaBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('TM_DeclineSelectionCriteriaBatch');
        CareAustraliaBatchSuiteController.executeBatchableProcess('TM_ReactivatesSelectionCriteriaBatch');
        
    }
    //Check batchName is Blank
    public static testMethod void testExecuteBatch_BatchNameBlank(){
        String res = CareAustraliaBatchSuiteController.executeBatchableProcess('');
        Map<String,Object> parseRes = (Map<String,Object>)JSON.deserializeUntyped(res);
        System.assertEquals(false, parseRes.get('isSuccess'));
        System.assertEquals('Batch name is blank.', parseRes.get('msg'));
    }
    //Check for batchName is invalid
    public static testMethod void testExecuteBatch_BatchNameInvalid(){
        String batchName='InvalidBatch';
        String res=CareAustraliaBatchSuiteController.executeBatchableProcess(batchName);
        Map<String,Object> parsedRes=(Map<String,Object>)JSON.deserializeUntyped(res);
        System.assertEquals(false,parsedRes.get('isSuccess'));
    }
    //Check for batchName is valid
    public static testMethod void testExecuteBatch_AsyncJobList(){
        Test.startTest();
        CareAustraliaBatchSuiteController.executeBatchableProcess('ProcessPaymentCCBatch');
        Test.stopTest();
        String res = CareAustraliaBatchSuiteController.fetchAsyncJobList();
        System.assert(String.isNotBlank(res));
    }    
}