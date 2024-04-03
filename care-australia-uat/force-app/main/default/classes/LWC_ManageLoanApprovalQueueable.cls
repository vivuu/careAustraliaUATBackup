/**
* Name          :       LWC_ManageLoanApprovalQueueable
* Date          :       17/09/2023
* Author        :       Amit Goyal
* Description   :       To Manage Loan Approvals and Result on Loan Record
*/

global class LWC_ManageLoanApprovalQueueable Implements Queueable{
	map<String, Loan__c> updatedLoansMap = new map<String, Loan__c>();
    public LWC_ManageLoanApprovalQueueable(set<String> loanIds){
        this.updatedLoansMap = new map<String, Loan__c>([Select Id, Name, Stage__c, Loan_Proposal_Status__c From Loan__c Where Id IN: loanIds 
                                                         AND (Loan_Proposal_Status__c='Rejected' OR Loan_Proposal_Status__c='Content Approved')]);
    }
    
    public void execute(QueueableContext qc){
        try{
            //system.debug('### updatedLoansMap size: '+updatedLoansMap.size());
            map<String, Loan__c> loansMap = new map<String, Loan__c>();
            if(updatedLoansMap != null && updatedLoansMap.size()>0){
                map<String, ProcessInstance> piMap = new map<String, ProcessInstance>();
                ProcessInstance[] processInstances = [SELECT Id, TargetObjectId, TargetObject.Name, CreatedBy.Name, Status,
                                                      (SELECT Id, StepStatus, OriginalActorId, ActorId, Actor.Name, Comments, CreatedById 
                                                       FROM Steps Where StepStatus='Approved' OR StepStatus='Rejected' ORDER BY CreatedDate DESC LIMIT 1) 
                                                      From ProcessInstance 
                                                      Where TargetObjectId IN: updatedLoansMap.keyset() 
                                                      Order By CreatedDate DESC];
                //system.debug('### processInstances size: '+processInstances.size());
                if(processInstances != null && processInstances.size()>0){
                    for(ProcessInstance pi: processInstances){
                        //system.debug('### processInstances TargetObjectId: '+pi.TargetObjectId);
                        if(!piMap.containsKey(pi.TargetObjectId)){
                            piMap.put(pi.TargetObjectId, pi);
                        }
                    }
                }
                
                for(String lId: updatedLoansMap.keyset()){
                    Loan__c resultLoan = updatedLoansMap.get(lId);
                    if(piMap.containsKey(lId)){
                        //system.debug('### LoanId: '+lId+' - '+resultLoan.Name);
                        ProcessInstance pi = piMap.get(lId);
                        //system.debug('### LoanId: '+pi.TargetObjectId+' - '+pi.Status);
                        if(pi.Status == 'Approved' || pi.Status=='Rejected'){
                            if(pi.Steps != null && pi.Steps.size()>0){
                                //system.debug('### Rejection Comment: '+pi.Steps[0].Comments);
                                if(pi.Steps[0].StepStatus=='Approved'){
                                    // will be executed whenever gets approved by Loan Reviewer and Status becomes Content Approved
                                    //system.debug('Approver--> '+pi.Steps[0].ActorId+' - '+pi.Steps[0].Actor.Name);
                                    Boolean isManager = LWCUtility.checkIfLoanReviewerIsManager(pi.Steps[0].ActorId);
                                    //system.debug('### isManager: '+isManager);
                                    if(isManager){
                                        // Schedule the loan to publish a day later as the Reviewer is a Manager
                                        Loan__c l = new Loan__c(Id=pi.TargetObjectId);
                                        if(l.Published_Date__c == null){
                                            l.Published_Date__c=System.Today().addDays(1);
                                            l.Loan_Proposal_Status__c='Ready To Publish';
                                            l.Stage__c='Scheduled';
                                        }
                                        loansMap.put(pi.TargetObjectId, l);
                                    }else{
                                        // submit the loan for manager's approval
                                        //loansMap.put(pi.TargetObjectId, new Loan__c(Id=pi.TargetObjectId, Manager_Approval_Request__c=true));
                                        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
                                        submitRequest.setObjectId(pi.TargetObjectId);
                                        if(!Test.isRunningTest()){
                                            Approval.ProcessResult result = Approval.process(submitRequest);
                                            if (result.isSuccess()) {
                                                System.debug('@@@  Approval Process Submitted Successfully.');
                                            } else {
                                                System.debug('@@@  Approval Process Submission Failed.');
                                            }
                                        }
                                    }
                                }
                                
                                if(pi.Steps[0].StepStatus=='Rejected'){
                                    // will be executed when Rejected by Loan Reviewer or Loan Manager
                                    Loan__c l = new Loan__c(Id=pi.TargetObjectId);
                                    l.Loan_Proposal_Rejection_Reason_Comments__c=pi.Steps[0].Comments;
                                    String rejectionReason='Other';
                                    if(pi.Steps[0].Comments.contains('Photo')){
                                        l.Loan_Proposal_Rejection_Reason__c='Photo';
                                    }
                                    
                                    if(pi.Steps[0].Comments.contains('Missing Information')){
                                        l.Loan_Proposal_Rejection_Reason__c='Missing Information';
                                    }
                                    loansMap.put(pi.TargetObjectId, l);
                                }
                            }else{
                                system.debug('### No Step Found for: '+lId+' - '+resultLoan.Name);
                            }
                        }else{
                            system.debug('### Already in another approval process: '+lId+' - '+resultLoan.Name);
                        }
                    }else{
                        system.debug('### ProcessInstance not found for: '+lId+' - '+resultLoan.Name);
                    }
                    
                }
            }
            
            if(loansMap != null && loansMap.size()>0){
                update loansMap.values();
            }
        }catch(Exception e){
            system.debug('### Exception: '+e.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_ManageLoanApprovalQueueable', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=e.getMessage(), 
                                                        StackTrace__c=e.getStackTraceString());
            insert err;
        }
    }
}