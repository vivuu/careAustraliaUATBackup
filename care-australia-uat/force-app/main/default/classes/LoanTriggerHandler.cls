/**
* Name			:		LoanTriggerHandler
* Date			:		07/07/2023
* Author		:		Amit Goyal
* Description	:		To Update Loan Rejection Reason Comments when the Loan Proposal Status becomes System Rejected
* 						To Blank Out Loan Rejection Reason and Comments when the Loan Proposal Status becomes Under Review
*/
public without sharing class LoanTriggerHandler {
    public static Boolean hasRanAfterInsert=false;
    public static Boolean hasRanAfterUpdate=false;
    public static Boolean hasRanAfterDelete=false;
    public static Boolean hasRanAfterUndelete=false;
    
    public static void handleBeforeInsert(list<Loan__c> newLoans){
        map<String, Decimal> currencyConversionMap = LWCUtilityFX.getCurrencyConversionMap();
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        set<String> fspIds = new set<String>();
        for(Loan__c l : newLoans){
            fspIds.add(l.FSP_Name__c);
        }
        
        if(fspIds != null && fspIds.size()>0){
            map<String, Contact> fspMap = new map<String, Contact>([Select Id, CurrencyISOCode From Contact Where Id IN: fspIds]);
            for(Loan__c l : newLoans){
                if(fspMap.containsKey(l.FSP_Name__c)){
                    l.CurrencyIsoCode=fspMap.get(l.FSP_Name__c).CurrencyISOCode;
                }else{
                    l.CurrencyIsoCode='VND';
                }
                String localCurrency=l.CurrencyIsoCode;
                if(l.Loan_Principal_Disbursed_FSP_Txt__c != null && l.Loan_Principal_Disbursed_FSP_Txt__c.trim().length()>0){
                    if(l.Loan_Principal_Disbursed_FSP_Txt__c.contains(',')){
                        l.Loan_Principal_Disbursed_FSP_Txt__c=l.Loan_Principal_Disbursed_FSP_Txt__c.replaceAll(',', '');
                    }
                    l.Loan_Principal_Disbursed__c =  Integer.valueOf(l.Loan_Principal_Disbursed_FSP_Txt__c);
                }
                
                if(l.Loan_Principal_Disbursed__c != null && l.Loan_Principal_Disbursed__c > 0 && l.Loan_Principal_Disbursed_USD__c == null){
                    // Convert the Loan in USD
                    if(l.Loan_Principal_Disbursed__c != null && l.Loan_Principal_Disbursed__c > 0){
                        l.Loan_Principal_Disbursed_USD__c=LWCUtilityFX.conversionfromLCtoUSD(l.Loan_Principal_Disbursed__c, localCurrency, currencyConversionMap);
                        l.FX_Rate_VND_To_USD__c=LWCUtilityFX.conversionfromLCtoUSD(1, localCurrency, currencyConversionMap);
                    }
                    //system.debug('### l.Loan_Principal_Disbursed_USD__c: '+l.Loan_Principal_Disbursed_USD__c);
                    //system.debug('### currencyConversionMap size: '+currencyConversionMap.size());
                    if(l.Loan_Principal_Disbursed_USD__c != null && l.Loan_Principal_Disbursed_USD__c > 0){
                        l.Loan_Principal_Disbursed_AUD__c=LWCUtilityFX.conversionfromUSDtoAUD(l.Loan_Principal_Disbursed_USD__c, currencyConversionMap);
                    }
                    if(l.Loan_Principal_Disbursed_AUD__c != null && l.Loan_Principal_Disbursed_AUD__c > 0){
                        l.Buffer_AUD__c=l.Loan_Principal_Disbursed_AUD__c / lwcGlobalSettings.Lending_Buffer__c;
                        l.Buffer_AUD__c=l.Buffer_AUD__c.setScale(3);
                        l.Published_Amount_AUD__c=l.Loan_Principal_Disbursed_AUD__c+l.Buffer_AUD__c;
                        l.Published_Amount_AUD__c=l.Published_Amount_AUD__c.setScale(3);
                    }
                }
            }
        }
    }
    
    public static void handleAfterInsert(list<Loan__c> newLoans){
        if(!hasRanAfterInsert){
            hasRanAfterInsert=true;
        }
        
        //createLoanSharing(newLoans);
    }
    
    public static void handleBeforeUpdate(map<Id, Loan__c> newLoans, map<Id, Loan__c> oldLoans){
        map<String, Decimal> currencyConversionMap = LWCUtilityFX.getCurrencyConversionMap();
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        map<Id, Loan__c> validateLoansMap = new map<Id, Loan__c>();
        set<String> borrowerIds = new set<String>();
        
        for(Loan__c l: newLoans.values()){
            String localCurrency=l.CurrencyIsoCode;
            if(l.Include_in_Offset_Calculation__c){
                l.Future_Offset_Inclusion_Date__c=System.Today();
            }
            
            if(l.Loan_Principal_Disbursed_FSP_Txt__c != oldLoans.get(l.Id).Loan_Principal_Disbursed_FSP_Txt__c){
                if(l.Loan_Principal_Disbursed_FSP_Txt__c.contains(',')){
                    l.Loan_Principal_Disbursed_FSP_Txt__c=l.Loan_Principal_Disbursed_FSP_Txt__c.replaceAll(',', '');
                }
                l.Loan_Principal_Disbursed__c =  Integer.valueOf(l.Loan_Principal_Disbursed_FSP_Txt__c);
            }
            
            if(oldLoans.get(l.Id).Include_in_Offset_Calculation__c==true && l.Include_in_Offset_Calculation__c != oldLoans.get(l.Id).Include_in_Offset_Calculation__c){
                l.addError('The loan is set for offset calculation, you can not modify');
            }
            
            // Reset fields in case of Loan Proposal resubmission
            if(l.Loan_Proposal_Status__c == 'Under Review' && l.Loan_Proposal_Status__c != oldLoans.get(l.Id).Loan_Proposal_Status__c){
                l.Loan_Proposal_Rejection_Reason__c=null;
                l.Loan_Proposal_Rejection_Reason_Comments__c=null;
                l.Manager_Approval_Request__c = false;
            }
            
            if(l.Loan_Principal_Disbursed__c != null && ((l.Loan_Principal_Disbursed__c != oldLoans.get(l.Id).Loan_Principal_Disbursed__c) || 
                                                         (l.CurrencyIsoCode != oldLoans.get(l.Id).CurrencyIsoCode) || 
                                                         l.Loan_Principal_Disbursed_USD__c == null) || 
              l.Loan_Proposal_Status__c == 'Under Review' && l.Loan_Proposal_Status__c != oldLoans.get(l.Id).Loan_Proposal_Status__c){
                // Convert the Loan in USD
                l.Loan_Principal_Disbursed_USD__c=LWCUtilityFX.conversionfromLCtoUSD(l.Loan_Principal_Disbursed__c, localCurrency, currencyConversionMap);
                l.FX_Rate_VND_To_USD__c=LWCUtilityFX.conversionfromLCtoUSD(1, localCurrency, currencyConversionMap);
                l.Loan_Principal_Disbursed_AUD__c=LWCUtilityFX.conversionfromUSDtoAUD(l.Loan_Principal_Disbursed_USD__c, currencyConversionMap);
                l.Buffer_AUD__c=l.Loan_Principal_Disbursed_AUD__c / lwcGlobalSettings.Lending_Buffer__c;
                l.Buffer_AUD__c=l.Buffer_AUD__c.setScale(3);
                l.Published_Amount_AUD__c=l.Loan_Principal_Disbursed_AUD__c+l.Buffer_AUD__c;
                l.Published_Amount_AUD__c=l.Published_Amount_AUD__c.setScale(3);
            }
            
            if(l.Loan_Proposal_Status__c=='System Rejected'){
                //system.debug('### Rejected Loan: '+l.Name);
                validateLoansMap.put(l.Id, l);
                borrowerIds.add(l.Borrower__c);
            }
            
            // Update Expected_Funded_Date__c to check Expiration of Loan
            if((l.Stage__c=='Scheduled' && l.Stage__c != oldLoans.get(l.Id).Stage__c) || ((l.Stage__c=='Fundraising' && l.Stage__c != oldLoans.get(l.Id).Stage__c) && (l.Loan_Proposal_Status__c=='Published' && l.Loan_Proposal_Status__c != oldLoans.get(l.Id).Loan_Proposal_Status__c))){
                if(l.Published_Date__c != null && lwcGlobalSettings.Loan_Publish_Limit_Days__c != null){
                    l.Expected_Funded_Date__c=l.Published_Date__c.addDays(Integer.valueOf(lwcGlobalSettings.Loan_Publish_Limit_Days__c));
                }
            }
            
            // Update Loan Stage and Date when the Loan get Fully Funded, it will help to payments and acknowledgements
            if((((l.Amount_Left_Before_Fully_Funded__c==0 || (l.Amount_Left_Before_Fully_Funded__c>=-0.05 && l.Amount_Left_Before_Fully_Funded__c<=0.05)) && l.Published_Amount_AUD__c != null && l.Published_Amount_AUD__c > 0) || (l.Amount_Funded__c==l.Published_Amount_AUD__c) && l.Amount_Funded__c > 0) && l.Stage__c=='Fundraising'){
                l.Funded_Date__c=System.Today();
                l.Stage__c='Active';
                // MAD216 - Sending Email on Loan is getting fully funded - active
                if(!Test.isRunningTest()){
                    LWC_SendEmailWithTemplateCtrl.sendEmail(null, l.Id, null, 'Loan Fully Funded');
                }
            }
            
            if((l.Loan_Principal_Disbursed__c != null && l.Loan_Principal_Disbursed__c>0) && (l.Cumulative_Amount_Received_To_Date__c != null && l.Cumulative_Amount_Received_To_Date__c>0)){
                Decimal repaymentLeft=l.Loan_Principal_Disbursed__c-l.Cumulative_Amount_Received_To_Date__c;
                if(repaymentLeft >= 0 && repaymentLeft<=0.05){
                    l.Repaid_Date__c=System.Today();
                    l.Stage__c='Repaid';
                }
                
                system.debug('### Amount: '+l.Loan_Principal_Disbursed__c+' - '+l.Cumulative_Amount_Received_To_Date__c+' - '+String.valueOf(repaymentLeft));
                if(repaymentLeft.setScale(3)<0){
                    l.addError('You can not make over repayments for '+l.Name+' - '+String.valueOf(repaymentLeft)+'.');
                }                                             
            }
            
            if((l.Actual_Loan_Principle_Disbursed_AUD__c != null || l.Published_Amount_AUD__c != null) && l.Total_Repaid_Amount_AUD__c != null){
                Decimal repaymentLeft=0;
                if(l.Actual_Loan_Principle_Disbursed_AUD__c != null){
                    repaymentLeft = l.Actual_Loan_Principle_Disbursed_AUD__c;
                }
                
                if(repaymentLeft == null && l.Published_Amount_AUD__c != null){
                    repaymentLeft = l.Published_Amount_AUD__c;
                }
                
                if(repaymentLeft != null && repaymentLeft > 0){
                    repaymentLeft=repaymentLeft-l.Total_Repaid_Amount_AUD__c;
                    if(repaymentLeft<0){
                        l.addError('You can not make over repayments for '+l.Name+' - '+String.valueOf(repaymentLeft)+'.');
                    }
                }
            }
            
            // Update FX Rate in USD, AUD, Buffer and Published Amount once the Loan Proposal is Approved.
            if((l.Stage__c=='Scheduled' || l.Stage__c=='Fundraising') && l.Stage__c != oldLoans.get(l.Id).Stage__c){
                l.Loan_Principal_Disbursed_AUD__c=LWCUtilityFX.conversionfromUSDtoAUD(l.Loan_Principal_Disbursed_USD__c, currencyConversionMap);
                l.Buffer_AUD__c=l.Loan_Principal_Disbursed_AUD__c / lwcGlobalSettings.Lending_Buffer__c;
                l.Buffer_AUD__c=l.Buffer_AUD__c.setScale(3);
                l.Published_Amount_AUD__c=l.Loan_Principal_Disbursed_AUD__c+l.Buffer_AUD__c;
                l.Published_Amount_AUD__c=l.Published_Amount_AUD__c.setScale(3);
            }
            
            //if(l.Loan_Proposal_Status__c=='Published' && l.Loan_Proposal_Status__c != oldLoans.get(l.Id).Loan_Proposal_Status__c){
                //l.Loan_Principal_Disbursed_AUD__c=LWCUtilityFX.conversionfromUSDtoAUD(l.Loan_Principal_Disbursed_USD__c, currencyConversionMap);
                //l.Buffer_AUD__c=l.Loan_Principal_Disbursed_AUD__c / lwcGlobalSettings.Lending_Buffer__c;
                //l.Buffer_AUD__c=l.Buffer_AUD__c.setScale(3);
                //l.Published_Amount_AUD__c=l.Loan_Principal_Disbursed_AUD__c+l.Buffer_AUD__c;
                //l.Published_Amount_AUD__c=l.Published_Amount_AUD__c.setScale(3);
            //}
        }
        
        //system.debug('### validateLoansMap: '+validateLoansMap.size());
        if((validateLoansMap != null && validateLoansMap.size()>0) && (borrowerIds != null && borrowerIds.size()>0)){
            // Update the Rejection Reason and Comments on Loan in case the Loan Proposal Acceptance Criteria does not meet.
            updateSystemRejectedReason(validateLoansMap.values(), borrowerIds);
        }
    }
    
    public static void handleAfterUpdate(Map<Id, Loan__c> newLoans,  Map<Id, Loan__c> oldLoans)
    {
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        //set<String> loanIds = new set<String>();
        map<Id, Loan__c> fspChangedLoansMap = new map<Id, Loan__c>();
        set<String> rejectedLoanIds = new set<String>();
        list<FeedItem> fiList = new list<FeedItem>();
        set<String> loansIds = new set<String>();
        set<String> fundraisingLoansIds = new set<String>();
		set<String> repaidLoanIds = new set<String>();
        
        for(Loan__c l : newLoans.values()){
            if(l.Stage__c=='Repaid'){
                repaidLoanIds.add(l.Id);
            }
            
            if((l.Loan_Proposal_Status__c=='Rejected' || l.Loan_Proposal_Status__c=='Content Approved') && l.Loan_Proposal_Status__c != oldLoans.get(l.Id).Loan_Proposal_Status__c){
                loansIds.add(l.Id);
            }
        	
            if(l.Loan_Proposal_Status__c != oldLoans.get(l.Id).Loan_Proposal_Status__c && l.Loan_Proposal_Status__c=='Rejected'){
                // Send Chatter Notification to FSP
                if(l.Loan_Proposal_Status__c=='Rejected'){
                    fiList.add(LWCUtility.createChatterFeed_LoanRejection(l.FSP_Name__c, l.Id));
                }
            }
            
            if(l.Stage__c=='Fundraising' && l.Stage__c != oldLoans.get(l.Id).Stage__c){
                fundraisingLoansIds.add(l.Id);
            }
            
            if(l.FSP__c != oldLoans.get(l.Id).FSP__c) {
                fspChangedLoansMap.put(l.Id, l);
            }
        }
        
        if(repaidLoanIds != null && repaidLoanIds.size()>0){
            closeLoanOnRepaid(repaidLoanIds);
        }
        
        if(fiList != null && fiList.size()>0){
            insert fiList;
        }
        
        if(fundraisingLoansIds != null && fundraisingLoansIds.size()>0){
            updateRepaymentScheduleRepaidDates(fundraisingLoansIds);
        }
        
        if(loansIds != null && loansIds.size()>0){
            sendLoanforManagerApproval(loansIds);
        }
        
        if(fspChangedLoansMap != null && fspChangedLoansMap.size()>0){
            //deleteLoanSharing(fspChangedLoansMap.keyset());
            //createLoanSharing(fspChangedLoansMap.values());
        }
    }
    
    public static void handleBeforeDelete(map<Id, Loan__c> oldLoans) {
        //deleteLoanSharing(oldLoans.keyset());
    }
    
    public static void closeLoanOnRepaid(set<String> loanIds){
        list<Repayment_Schedule__c> rsList = [Select Id, Name From Repayment_Schedule__c Where Loan__c =: loanIds AND Status__c=NULL];
        for(Repayment_Schedule__c rs: rsList){
            rs.Status__c='Skipped';
            rs.Repayment_Date__c=System.Today();
            rs.Principal_Repaid__c=0;
        }
        update rsList;
    }
    
   /* public static void createLoanSharing(list<Loan__c> newLoans){
        map<String, list<User>> fspUsersByFSP = new map<String, list<User>>();
        map<String, Contact> fspStaffMap = new map<String, Contact>(LWCUtility.getAllActiveFSPs());
        List<User> fspUserList=[SELECT Id, ContactId FROM User 
                                       WHERE ContactId IN: fspStaffMap.keyset() 
                                       AND IsActive=TRUE];
        for(User usr: fspUserList){
            if(fspStaffMap.containsKey(usr.ContactId)){
                Contact con = fspStaffMap.get(usr.ContactId);
                if(con.AccountId != null){
                    list<User> result = fspUsersByFSP.get(con.AccountId);
                    if(result == null){
                        result = new list<User>();
                    }
                    result.add(usr);
                    fspUsersByFSP.put(con.AccountId, result);
                }
            }
        }
        
        List<Loan__Share> loanShare=new List<Loan__Share>();
        for(Loan__c cur_Loan: newLoans)
        {
            if(fspUsersByFSP.containsKey(cur_Loan.FSP__c)){
                list<User> fspUsers = fspUsersByFSP.get(cur_Loan.FSP__c);
                if(fspUsers != null && fspUsers.size()>0){
                    for(User fspStaff: fspUsers){
                        system.debug('### fspStaff: '+fspStaff.Id);
                        if(fspStaff.ContactId != cur_Loan.FSP_Name__c){
                            Loan__Share ls=new Loan__Share();
                            ls.ParentId=cur_Loan.Id;
                            ls.AccessLevel='Edit';
                            ls.UserOrGroupId=fspStaff.Id;
                            ls.RowCause= Schema.Loan__Share.rowCause.FSPStaff__c;
                            System.debug('Shared'+cur_Loan.Id);
                            loanShare.add(ls);
                        }
                    }
                }
            }
        }
        try {
            if(!loanShare.isEmpty())
            {
                System.debug('Inserted Loan Share');
                insert loanShare;
            }
        } catch(Exception e) {
            System.debug('Error-->'+e.getMessage());
        }
    }
    
   public static void deleteLoanSharing(set<Id> loanIds){
        List<Loan__Share> delLoanShare=[SELECT Id FROM Loan__Share WHERE ParentId IN: loanIds AND RowCause != 'Owner'];
        //system.debug('Deleting Loan Share --->'+delLoanShare);
        if(!delLoanShare.isEmpty()) {
            try {
                delete delLoanShare;
            } catch(Exception e) {
                System.debug('Error-->'+e.getMessage());
            }
        }
    }*/
    
    public static void updateRepaymentScheduleRepaidDates(set<String> loanIds){
        map<String, Repayment_Schedule__c> rsMap = new map<String, Repayment_Schedule__c>();
        if(loanIds != null && loanIds.size()>0){
            list<Loan__c> loans = [Select Id, Name, Stage__c, (Select Id, Due_Date__c, Status__c, Repayment_Date__c From Repayment_Schedules__r) 
                                   From Loan__c Where Id IN: loanIds];
            if(loans != null && loans.size()>0){
                for(Loan__c l: loans){
                    if(l.Stage__c=='Fundraising'){
                        for(Repayment_Schedule__c rs: l.Repayment_Schedules__r){
                            if(rs.Due_Date__c != null && rs.Due_Date__c < System.Today() && (rs.Status__c==null || rs.Status__c=='')){
                                rs.Repayment_Date__c=rs.Due_Date__c.addMonths(1);
                                rsMap.put(rs.Id, rs);
                            }
                        }
                    }
                }
            }
            
            if(rsMap != null && rsMap.size()>0){
                update rsMap.values();
            }
        }
    }
    
    public static void updateSystemRejectedReason(list<Loan__c> newLoans, set<String> borrowerIds){
        if(borrowerIds != null && borrowerIds.size()>0){
            // Update the Rejection Reason and Comments on Loan in case the Loan Proposal Acceptance Criteria does not meet.
            map<String, Contact> borrowersMap = new map<String, Contact>([Select Id, Name, Borrower_Type__c
                                                                          From Contact 
                                                                          Where Id IN: borrowerIds]);
            //system.debug('@@@ borrowersMap size: '+borrowersMap.size());
            LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
            //system.debug('@@@ Individual_Borrower_Limit_AUD__c: '+lwcGlobalSettings.Individual_Borrower_Limit_AUD__c);
            //system.debug('@@@ Group_Borrower_Limit_AUD__c: '+lwcGlobalSettings.Group_Borrower_Limit_AUD__c);
            //system.debug('@@@ Loan_Acceptance_Days__c: '+lwcGlobalSettings.Loan_Acceptance_Days__c);
            for(Loan__c l: newLoans){
                
                if(l.Loan_Proposal_Status__c=='System Rejected'){
                    l.Loan_Proposal_Rejection_Reason__c='System Rejected';
                    String rejectionReasonComments='';
                    Contact borrower = borrowersMap.get(l.Borrower__c);
                    //system.debug('@@@ Borrower Type: '+borrower.Borrower_Type__c);
                    //system.debug('@@@ Loan_Principal_Disbursed_USD__c: '+l.Loan_Principal_Disbursed_USD__c);
                    if(borrower.Borrower_Type__c != null){
                        if(borrower.Borrower_Type__c=='Individual' && l.Loan_Principal_Disbursed_USD__c > lwcGlobalSettings.Individual_Borrower_Limit_AUD__c){
                            rejectionReasonComments='Principal Amount can not be greater than '+lwcGlobalSettings.Individual_Borrower_Limit_AUD__c+'.';
                        }
                        
                        if(borrower.Borrower_Type__c=='Group' && l.Loan_Principal_Disbursed_USD__c > lwcGlobalSettings.Group_Borrower_Limit_AUD__c){
                            rejectionReasonComments='Principal Amount can not be greater than '+lwcGlobalSettings.Group_Borrower_Limit_AUD__c+'.';
                        }
                    }else{
                        rejectionReasonComments='Borrower Type is not defined.';
                    }
                    
                    
                    if(l.Loan_Disbursement_Date__c != null){
                        Integer dayDifference = l.Loan_Disbursement_Date__c.daysBetween(l.CreatedDate.Date());
                        //system.debug('@@@ dayDifference: '+dayDifference);
                        if(dayDifference > lwcGlobalSettings.Loan_Acceptance_Days__c){
                            if(rejectionReasonComments.trim().length()>0){
                                rejectionReasonComments+=' & ';
                            }
                            rejectionReasonComments+='Loan could not be submitted after '+lwcGlobalSettings.Loan_Acceptance_Days__c+' days of disbursal.';
                        }
                    }
                    
                    if(l.Loan_Principal_Disbursed__c != l.Total_Repayment_Scheduled_Amount__c){
                        if(rejectionReasonComments.trim().length()>0){
                            rejectionReasonComments+=' & ';
                        }
                        rejectionReasonComments+='Loan Repayment does not match the amount of repayments.';
                    }
                    
                    if(l.Loan_Term_Months__c != l.Number_of_Repayments__c){
                        if(rejectionReasonComments.trim().length()>0){
                            rejectionReasonComments+=' & ';
                        }
                        rejectionReasonComments+='Number of Repayments does not match with the count of repayments.';
                    }
                    system.debug('@@@ rejectionReasonComments: '+rejectionReasonComments);
                    l.Loan_Proposal_Rejection_Reason_Comments__c=rejectionReasonComments;
                }
            }
        }
    }
    
    public static void sendLoanforManagerApproval(set<String> loanIds){
        // Manage to update loan reject reason and comments on Rejection or to submit the loan for manager approval
        if(loanIds != null && loanIds.size()>0){
            for(Integer i=0; i<100; i++){}
            System.enqueueJob(new LWC_ManageLoanApprovalQueueable(loanIds));
        }
    }
}