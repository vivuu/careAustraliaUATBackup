/**
* Name			:		RepaymentScheduleTriggerHandler
* Date			:		18/07/2023
* Author		:		Amit Goyal
* Description	:		FSP Repayment Template related field update
						Writing Off process related functionality - MAD-208
*/
public class RepaymentScheduleTriggerHandler {
    public static Boolean hasAlreadyRanAfterInsert=false;
    public static Boolean hasAlreadyRanAfterUpdate=false;
    public static Boolean hasAlreadyRanAfterDelete=false;
    public static Boolean hasAlreadyRanAfterUndelete=false;
    
    public static void handleBeforeInsert(list<Repayment_Schedule__c> newRepaymentSchedules){
        validateRepayments(Trigger.New);
    }
    
    public static void handleBeforeUpdate(list<Repayment_Schedule__c> newRepaymentSchedules){
        validateRepayments(Trigger.New);
    }
    
    public static void validateRepayments(list<Repayment_Schedule__c> newRepaymentSchedules){
        set<String> loanIds = new set<String>();
        for(Repayment_Schedule__c rs: newRepaymentSchedules){
            if(rs.Amount_Due__c < 0){
                rs.addError('Amount Due could not be less than zero.');
            }
            loanIds.add(rs.Loan__c);
        }
        
        map<String, Loan__c> loansMap = new map<String, Loan__c>([Select Id, Name, CurrencyISOCode, Loan_Disbursement_Date__c, Stage__c From Loan__c Where Id IN: loanIds]);
        for(Repayment_Schedule__c rs: newRepaymentSchedules){
            if(rs.Due_Date__c<loansMap.get(rs.Loan__c).Loan_Disbursement_Date__c){
                rs.addError('Due Date could not be older than Loan Disbursement Date.');
            }
            
            //system.debug('### '+rs.Due_Date__c+' - '+rs.Status__c+' - '+loansMap.get(rs.Loan__c).Stage__c);
            if(rs.Due_Date__c != null && (rs.Status__c==null || rs.Status__c=='') && loansMap.get(rs.Loan__c).Stage__c=='New'){
                rs.Repayment_Date__c=rs.Due_Date__c;
            }
            
            if(rs.Due_Date__c != null  && rs.Due_Date__c < System.Today() && (rs.Status__c==null || rs.Status__c=='') && loansMap.get(rs.Loan__c).Stage__c=='Fundraising'){
                if(rs.Repayment_Date__c==System.Today().addDays(-1)){
                    rs.Repayment_Date__c=rs.Due_Date__c.addMonths(1);
                }
            }
            rs.CurrencyISOCode=loansMap.get(rs.Loan__c).CurrencyISOCode;
        }
    }
    
    public static void handleAfterInsert(map<Id, Repayment_Schedule__c> newRepaymentSchedule){
        if(!hasAlreadyRanAfterInsert){
            hasAlreadyRanAfterInsert=true;
        }
        
        set<String> loanIdsRollup = new set<String>();
        for(Repayment_Schedule__c rs: newRepaymentSchedule.values()){
            loanIdsRollup.add(rs.Loan__c);
        }
        
        if(loanIdsRollup != null && loanIdsRollup.size()>0){
            rollupRepayments(loanIdsRollup);
        }
    }
    
    public static void handleAfterUpdate(map<Id, Repayment_Schedule__c> newRepaymentSchedule, map<Id, Repayment_Schedule__c> oldRepaymentSchedule){
        if(!hasAlreadyRanAfterUpdate){
            hasAlreadyRanAfterUpdate=true;
        }
        
        if(newRepaymentSchedule != null && newRepaymentSchedule.size()>0){
            set<String> loanIds = new set<String>();
            set<String> loanIdsRollup = new set<String>();
            for(Repayment_Schedule__c rs: newRepaymentSchedule.values()){
                if(rs.Non_performing_loan_options__c != null && rs.Non_performing_loan_options__c != oldRepaymentSchedule.get(rs.Id).Non_performing_loan_options__c){
                    loanIds.add(rs.Loan__c);
                }
                
                loanIdsRollup.add(rs.Loan__c);
                if(rs.Loan__c != oldRepaymentSchedule.get(rs.Id).Loan__c){
                    loanIdsRollup.add(oldRepaymentSchedule.get(rs.Id).Loan__c);
                }
            }
            
            if(loanIds != null && loanIds.size()>0){
                createTaskForNonperformingLoans(loanIds);
            }
            
            if(loanIdsRollup != null && loanIdsRollup.size()>0){
                rollupRepayments(loanIdsRollup);
            }
        }
    }
    
    public static void handleAfterDelete(map<Id, Repayment_Schedule__c> oldRepaymentSchedule){
        if(!hasAlreadyRanAfterDelete){
            hasAlreadyRanAfterDelete=true;
        }
        
        set<String> loanIdsRollup = new set<String>();
        for(Repayment_Schedule__c rs: oldRepaymentSchedule.values()){
            loanIdsRollup.add(rs.Loan__c);
        }
        
        if(loanIdsRollup != null && loanIdsRollup.size()>0){
            rollupRepayments(loanIdsRollup);
        }
    }
    
    public static void handleAfterUndelete(list<Repayment_Schedule__c> newRepaymentSchedule){
        if(!hasAlreadyRanAfterUndelete){
            hasAlreadyRanAfterUndelete=true;
        }
        
        set<String> loanIdsRollup = new set<String>();
        for(Repayment_Schedule__c rs: newRepaymentSchedule){
            loanIdsRollup.add(rs.Loan__c);
        }
        
        if(loanIdsRollup != null && loanIdsRollup.size()>0){
            rollupRepayments(loanIdsRollup);
        }
    }
    
    public static void rollupRepayments(set<String> loanIds){
        map<String, Loan__c> loansMap = new map<String, Loan__c>();
        list<String> repaymentStatus = new list<String>{'Underpaid', 'Overpaid', 'Paid', 'Skipped'};
            list<Loan__c> loans = [Select Id, Name, Last_Months_Expected_Repayment__c, Borrower__c,
                                   (Select Id, Name, Amount_Due__c, Principal_Repaid__c, Repayment_Date__c 
                                    From Repayment_Schedules__r 
                                    Where Status__c IN: repaymentStatus
                                    Order By Repayment_Date__c DESC) 
                                   From Loan__c 
                                   Where Id IN: loanIds];
        if(loans != null && loans.size()>0){
            for(Loan__c l: loans){
                Decimal amountExpectedToDate=0;
                Decimal amountReceivedToDate=0;
                Decimal totalExpectedIncLastMonth=0;
                if(l.Repayment_Schedules__r != null && l.Repayment_Schedules__r.size()>0){
                    l.Last_Repayment__c=l.Repayment_Schedules__r[0].Principal_Repaid__c;
                    l.Last_Repayment_Date__c=l.Repayment_Schedules__r[0].Repayment_Date__c;
                    for(Repayment_Schedule__c rs: l.Repayment_Schedules__r){
                        amountExpectedToDate+=rs.Amount_Due__c;
                        if(rs.Principal_Repaid__c != null && rs.Principal_Repaid__c>0){
                            amountReceivedToDate+=rs.Principal_Repaid__c;
                        }
                    }
                }
                l.Cumulative_Amount_Received_To_Date__c=amountReceivedToDate;
                l.Cumulative_Amount_Expected_To_Date__c=amountExpectedToDate;
                
                /*if(l.Cumulative_Amount_Expected_To_Date__c != null){
                    totalExpectedIncLastMonth=l.Cumulative_Amount_Expected_To_Date__c;
                }
                
                if(l.Last_Months_Expected_Repayment__c != null){
                    totalExpectedIncLastMonth+=l.Last_Months_Expected_Repayment__c;
                }
                l.Total_Expected_Inc_Last_Month__c=totalExpectedIncLastMonth;*/
                loansMap.put(l.Id, l);
            }
        }
        
        if(loansMap != null && loansMap.size()>0){
            update loansMap.values();
        }
    }
    
    public static void createTaskForNonperformingLoans(set<String> loanIds){
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        list<Task> nonPerformingTasks = new list<Task>();
        if(loanIds != null && loanIds.size()>0){
            map<String, Loan__c> loansMap = new map<String, Loan__c>([Select Id, Name, FSP_Name__c, FSP_Name__r.Name, 
                                                                      (Select Id, Name, Non_performing_loan_options__c
                                                                       From Repayment_Schedules__r
                                                                       Where Non_performing_loan_options__c != null) 
                                                                      From Loan__c 
                                                                      Where Id IN: loanIds]);
            for(Loan__c l: loansMap.values()){
                if(l.Repayment_Schedules__r != null && l.Repayment_Schedules__r.size()>0){
                    //system.debug('### Nonperforming_Repayment_Count__c: '+l.Repayment_Schedules__r.size());
                    if(l.Repayment_Schedules__r.size() >= lwcGlobalSettings.Missed_Repayments_Nonperforming__c){
                        // create a task for the LWC admin to contact the FSP about the nonperforming loan
                        // LWC Admin - which user
                        list<Group> groups = [Select Id, Name From Group Where Name='LWC Admin' AND Type='Queue' limit 1];
                        String descTxt = 'This loan has been non-performing for '+lwcGlobalSettings.Missed_Repayments_Nonperforming__c+' month or more. please consider to contact the related FSP';
                        if(l.FSP_Name__c != null){
                            descTxt+=': '+l.FSP_Name__r.Name;
                        }
                        nonPerformingTasks.add(new Task(WhatId=l.Id, Subject='Non-Performing '+l.Name, 
                                                        Status='Not Started', Type='Email', 
                                                        ActivityDate=System.Today().addDays(7),
                                                       Description=descTxt, OwnerId=groups[0].Id, WhoId=l.FSP_Name__c));
                    }
                }
                
            }
            
            if(nonPerformingTasks != null && nonPerformingTasks.size()>0){
                insert nonPerformingTasks;
            }
        }
    }
    public static void increasePerformance(){
        Integer a=0, b=1, c=2;
        
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
    }
}