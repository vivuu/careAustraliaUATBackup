@isTest
public class LWC_ManageLoanApprovalQueueableTest {
    @TestSetup
    private static void testData(){
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
        Loan__c l = new Loan__c(Borrower__c=borrowers[0].Id, FSP_Name__c=borrowers[0].FSP_Name__c, FSP_Loan_ID__c='L-'+borrowers[0].FSP_Client_ID__c, 
                                Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-29), 
                                Loan_Principal_Disbursed__c=24000000, Loan_Schedule__c='Monthly', CurrencyISOCode='VND', 
                                Consent_Provided__c=true, Number_of_Employees__c=1, Jobs_Created__c=1, Female_Employees_Count__c=1,
                                Loan_Purpose__c='Farming', CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                Loan_Proposal_Status__c='Draft', Stage__c='New');
        insert l;
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        Decimal amount = l.Loan_Principal_Disbursed__c/l.Loan_Term_Months__c;
        for(Integer j=1; j<=l.Loan_Term_Months__c; j++){
            Date dt = System.Today();
            if(j==1){
                dt=dt.addDays(-20);
            }else if(j==2){
                
            }else{
                dt=dt.addDays(30);
            }
            Repayment_Schedule__c rs = LWCTestUtility.getRepaymentRecord(l.Id, amount, dt);
            rs.Loan_Repayment_Number__c=j;
            rsList.add(rs);
        }
        insert rsList;
    }
       public testmethod static void testApprovedNegative(){
        
                   
            Loan__c l = [Select Id, Name, CreatedById From Loan__c limit 1];
            
            // Submit the record for approval
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setSubmitterId(l.CreatedById);
            req.setSkipEntryCriteria(true);
            
             Test.startTest();
           try{
                Approval.ProcessResult result = Approval.process(req);
           }catch(Exception e){
               
           }
            Test.stopTest();
        
    }   
    public testmethod static void testApprovedPositive(){
        
                   
            Loan__c l = [Select Id, Name, CreatedById From Loan__c limit 1];
            
            // Submit the record for approval
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setSubmitterId(l.CreatedById);
            req.setObjectId(l.Id);
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            
            // Verify that the record is now in the approval process
            System.assert(result.isSuccess());
            
            // Simulate the approval step
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            Test.setMock(HttpCalloutMock.class, new MockProcessWorkitemRequest());
            Approval.ProcessWorkitemRequest approveReq = new Approval.ProcessWorkitemRequest();
            approveReq.setComments('Test approval');
            approveReq.setAction('Approve');
            approveReq.setWorkitemId(newWorkItemIds.get(0));
            
             Test.startTest();
            Approval.ProcessResult approveResult = Approval.process(approveReq);
            Test.stopTest();
        
    }    
  
    public testmethod static void testApproved(){
        
        user usersR = [select id, email from user where Email='arnaud.charlier@care.org.au' AND isActive=true limit 1];
        if(usersR!=null)
        {
              System.runAs(usersR) {
            Test.startTest();
            Loan__c l = [Select Id, Name, CreatedById From Loan__c limit 1];
            
            // Submit the record for approval
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setSubmitterId(l.CreatedById);
            req.setObjectId(l.Id);
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            
            // Verify that the record is now in the approval process
            System.assert(result.isSuccess());
            
            // Simulate the approval step
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            Test.setMock(HttpCalloutMock.class, new MockProcessWorkitemRequest());
            Approval.ProcessWorkitemRequest approveReq = new Approval.ProcessWorkitemRequest();
            approveReq.setComments('Test approval');
            approveReq.setAction('Approve');
            approveReq.setWorkitemId(newWorkItemIds.get(0));
            
            
            Approval.ProcessResult approveResult = Approval.process(approveReq);
            Test.stopTest();
        }
            
        }
      
    }    
    public testmethod static void testRejected(){
        Loan__c l = [Select Id, Name, CreatedById From Loan__c limit 1];
        
        // Submit the record for approval
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setSubmitterId(l.CreatedById);
        req.setObjectId(l.Id);
        req.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req);
        
        // Verify that the record is now in the approval process
        System.assert(result.isSuccess());
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Test.setMock(HttpCalloutMock.class, new MockProcessWorkitemRequest());
        Approval.ProcessWorkitemRequest rejectReq = new Approval.ProcessWorkitemRequest();
        rejectReq.setComments('Test Photo rejection Missing Information');
        rejectReq.setAction('Reject');
        rejectReq.setWorkitemId(newWorkItemIds.get(0));
        Test.startTest();
        try{
            Approval.ProcessResult rejectResult = Approval.process(rejectReq);
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public class MockProcessWorkitemRequest implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response for the approval process request
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":true}');
            res.setStatusCode(200);
            return res;
        }
    }
}