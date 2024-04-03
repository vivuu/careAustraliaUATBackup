global class LWC_UpdateLoanRSScheduler Implements Schedulable{
	global void execute(SchedulableContext sc){
        list<Repayment_Schedule__c> rsList = [Select Id, Name, Status__c, Due_Date__c, Repayment_Date__c, Loan__r.Stage__c 
                                              From Repayment_Schedule__c 
                                              Where Due_Date__c != NULL AND Due_Date__c =: System.Today().addDays(-1)
                                              AND Status__c=NULL AND Loan__r.Stage__c='Fundraising'];
        if(rsList != null && rsList.size()>0){
            for(Repayment_Schedule__c rs: rsList){
                rs.Repayment_Date__c=rs.Due_Date__c.addMonths(1);
            }
            update rsList;
        }
    }
}