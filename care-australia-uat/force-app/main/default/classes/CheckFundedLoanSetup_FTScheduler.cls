/**
* Name			:		CheckFundedLoanSetup_FTScheduler
* Date			:		01/08/2023
* Author		:		Amit Goyal
* Description	:		MAD-478: the Finance team has not set the funded loans yet, 
							the Finance team should receive a reminder (chatter)
*/
global class CheckFundedLoanSetup_FTScheduler Implements Schedulable{
    @TestVisible private static string lwcAdminGrpId;
	global void execute(SchedulableContext sc)
    {
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        
        // Get the first day of the month
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        // Get the last day of the month
        Integer lastDayOfMonth = Date.daysInMonth(year, month);
        Date lastDayDate = Date.newInstance(year, month, lastDayOfMonth);
        list<Loan__c> loans = [Select Id, Name, Stage__c, Funded_Date__c, Include_in_Offset_Calculation__c 
                               From Loan__c 
                               Where Stage__c='Active' 
                               AND (Funded_Date__c >=: firstDayOfMonth AND Funded_Date__c <=: lastDayDate)];
        Boolean notificationRequired=false;
        if(loans != null && loans.size()>0){
            for(Loan__c l: loans){
                if(!l.Include_in_Offset_Calculation__c){
                    notificationRequired=true;
                }
            }
            
            if(notificationRequired){
                list<Report> reports = [Select Id, Name From Report Where Name='LoanFullyFunded_LastMonth_CAFinance' limit 1];
                String lwcAdminGroupId;
                list<CollaborationGroup> groups = [SELECT Id FROM CollaborationGroup WHERE Name = 'LWC Admin' LIMIT 1];
                if(groups != null && groups.size()>0){
                    lwcAdminGroupId=groups[0].Id;
                }else{
                    if(Test.isRunningTest()){
                        lwcAdminGroupId=lwcAdminGrpId;
                    }
                }
                FeedItem post = new FeedItem();
                post.ParentId = lwcAdminGroupId;
                post.Type = 'LinkPost';
                post.Body = 'Some of the funded loan in last month are not set to get processed, please take action in 24 hours.';
                post.Title = 'Funded Loans need to set for Last month';
                if(reports != null && reports.size()>0){
                    post.LinkUrl = '/lightning/r/Report/' + reports[0].Id + '/view';
                    insert post;
                }
            }
        }
    }
    
}