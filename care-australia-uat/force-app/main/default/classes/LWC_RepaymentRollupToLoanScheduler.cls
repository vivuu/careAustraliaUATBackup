/**
* Name			:		LWC_RepaymentRollupToLoanScheduler
* Date			:		21/07/2023
* Author		:		Amit Goyal
* Description	:		MAD-79: To update the due payment last month on Loan on 1st day of Every Month
						This will help to calculate the 'Total Expected Inc Last Month' field value on Loan
						The above field is critical to calculate the FSP Repayment calculation at the time processing the CSV,
						which will be uploaded and processed by FSPs between 1-7 every month.
						Note: Important and Critical Scheduler to run on 1st midnight every month before 4AM for sure

						This will cover the Larger payment story as well
*/
global class LWC_RepaymentRollupToLoanScheduler Implements Database.Batchable<sObject>, Schedulable{
    global void execute(SchedulableContext sc)
    {
        LWC_RepaymentRollupToLoanScheduler b = new LWC_RepaymentRollupToLoanScheduler();
        database.executebatch(b, 20);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        
        // Get the first day of the month
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        // Get the last day of the month
        Integer lastDayOfMonth = Date.daysInMonth(year, month);
        Date lastDayDate = Date.newInstance(year, month, lastDayOfMonth);
        
        String query = 'Select Id, Name, ';
        query += '(Select Id, Amount_Due__c, Due_Date__c, Status__c, Loan__c, Repayment_Date__c, Principal_Repaid__c From Repayment_Schedules__r Where Due_Date__c <=: lastDayDate Order By Due_Date__c DESC)';
        query += ' From Loan__c Where Stage__c=\'Active\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Loan__c> loanRecords) {
        SavePoint sp = Database.setSavepoint();
        try {
            Integer month=System.Today().addMonths(-1).Month();
            Integer year=System.Today().addMonths(-1).Year();
            Date firstDayOfLastMonth = Date.newInstance(year, month, 1);
            
            map<String, Repayment_Schedule__c> rsMap = new map<String, Repayment_Schedule__c>();
            map<String, Loan__c> loansMap = new map<String, Loan__c>();
            map<String, Boolean> loansPaidAnytime = new map<String, Boolean>();
            
            //system.debug('### loanRecords size: '+loanRecords.size());
            if(loanRecords != null && loanRecords.size()>0){
                for(Loan__c l: loanRecords){
                    System.debug('details about loan -> ' + l);
                    if(l.Repayment_Schedules__r != null && l.Repayment_Schedules__r.size()>0){
                        for(Repayment_Schedule__c rs: l.Repayment_Schedules__r){
                            if(rs.Status__c != null && rs.Status__c != 'Skipped' && rs.Repayment_Date__c != null){
                                loansPaidAnytime.put(rs.Loan__c, true);
                            }
                        }
                    }
                }
                
                for(Loan__c l: loanRecords){
                    //system.debug('### Loan Name: '+l.Name);
                    Decimal amountDueLastMonth=0;
                    Decimal totalExpectedIncLastMonth=0;
                    if(l.Repayment_Schedules__r != null && l.Repayment_Schedules__r.size()>0){
                        for(Repayment_Schedule__c rs: l.Repayment_Schedules__r){
                            if(!loansPaidAnytime.containsKey(l.Id)){
                                if(rs.Due_Date__c<firstDayOfLastMonth){
                                    rs.Status__c='Skipped';
                                    rs.Principal_Repaid__c=0;
                                    rs.Repayment_Date__c=firstDayOfLastMonth.addDays(-1);
                                    rsMap.put(rs.Id, rs);
                                }
                                
                            	amountDueLastMonth+=rs.Amount_Due__c;
                            }
                            totalExpectedIncLastMonth+=rs.Amount_Due__c;
                        }
                        
                        if(loansPaidAnytime.containsKey(l.Id)){
                            amountDueLastMonth=l.Repayment_Schedules__r[0].Amount_Due__c;
                        }
                    }
                    //system.debug('### amountDueLastMonth: '+amountDueLastMonth);
                    //system.debug('### totalExpectedIncLastMonth: '+totalExpectedIncLastMonth);
                    l.Last_Months_Expected_Repayment__c=amountDueLastMonth;
                    l.Total_Expected_Inc_Last_Month__c=totalExpectedIncLastMonth;
                    loansMap.put(l.Id, l);
                }
            }
            
            if(loansMap != null && loansMap.size()>0){
                update loansMap.values();
            }
            
            if(rsMap != null && rsMap.size()>0){
                update rsMap.values();
            }
            
            if(Test.isRunningTest()) {
                upsert loansMap.values();
            }
        } catch(Exception e) {
            system.debug('### exception: '+e+' - '+e.getStackTraceString());
            Database.rollback(sp);
            System.debug(e.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_RepaymentRollupToLoanScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=e.getMessage(), 
                                                        StackTrace__c=e.getStackTraceString());
            insert err;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}