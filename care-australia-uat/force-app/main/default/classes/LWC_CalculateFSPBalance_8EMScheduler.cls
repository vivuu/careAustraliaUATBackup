/**
* Name			:		LWC_CalculateFSPBalance_8EMScheduler
* Date			:		15/07/2023
* Author	0	:		Amit Goyal
* Description	:		USBP33: As a care manager, I want to know on a per FSP basis, have the total value of the loan received converted to USD 
						and total loan funded converted to USD on the 8th of each month, have the system tell me if Care owes money to the FSP or 
						vice versa.
						USBP37: As a care manager, I want to update FX rate once fund transfer has happened, ensure accurate reporting and 
						book keeping.
*/
global class LWC_CalculateFSPBalance_8EMScheduler Implements Database.Batchable<sObject>, Schedulable{
    @TestVisible private static string fspTestAccountId;
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
        
        Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        Integer lastDayOfThisMonth = Date.daysInMonth(System.today().year(), System.today().month());
        Date lastDayDateOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), lastDayOfThisMonth);
        
        list<Loan__c> loans = [Select Id, Include_in_Offset_Calculation__c From Loan__c 
                               Where Stage__c='Active' AND Loan_Principal_Disbursed_AUD__c>0 
                               AND Repaid_Date__c=NULL
                               AND Include_in_Offset_Calculation__c=true 
                               AND Actual_Loan_Principle_Disbursed_AUD__c=NULL
                               AND ((Funded_Date__c >=: firstDayOfMonth AND Funded_Date__c <=: lastDayDate)
                                    OR (Future_Offset_Inclusion_Date__c >: firstDayOfThisMonth AND Future_Offset_Inclusion_Date__c <=: lastDayDateOfThisMonth))];
        Boolean offsetCalcReady=false;
        if(loans != null && loans.size()>0){
            for(Loan__c l: loans){
                //system.debug('### Include_in_Offset_Calculation__c: '+l.Include_in_Offset_Calculation__c);
                if(l.Include_in_Offset_Calculation__c){
                    offsetCalcReady=true;
                }
            }
        }
        //system.debug('### offsetCalcReady: '+offsetCalcReady);
        if(offsetCalcReady){
            LWC_CalculateFSPBalance_8EMScheduler b = new LWC_CalculateFSPBalance_8EMScheduler();
            database.executebatch(b, 20);
        }else{
            // Send a email to finance team and the LWC admin team
            Set<String> userIds = new Set<String>();
            list<GroupMember> gmList = [Select UserOrGroupId From GroupMember where Group.Type='Queue' AND (Group.Name = 'LWC Admin' OR Group.Name = 'Finance Team')];
            for (GroupMember gm : gmList) {
                if (String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                    userIds.add(gm.UserOrGroupId);
                }
            }
            if(userIds != null && userIds.size()>0){
                LWCUtility.sendEmailToUsers(userIds);
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id, Name, CurrencyISOCode, (Select Id, Name From Contacts Where RecordType.Name=\'FSP Staff\') From Account Where RecordType.Name=\'FSP\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> fspRecords) {
        System.debug('FSP::'+fspRecords);
        SavePoint sp = Database.setSavepoint();
        try {
            map<String, Decimal> currencyConversionMap = LWCUtilityFX.getCurrencyConversionMap();
            map<String, List<Repayment_Schedule__c>> fspRSTag=new  map<String, List<Repayment_Schedule__c>>(); 
            map<String, FSP_Monthly_Settlement__c> fspMSTag=new  map<String,FSP_Monthly_Settlement__c>(); 
            map<String, Repayment_Schedule__c> autosetRepaymentsMap = new map<String, Repayment_Schedule__c>();
            List<FeedItem> feedItemList = new List<FeedItem>();
            map<String, Loan__c> loansMap = new map<String, Loan__c>();
            list<Transaction__c> fxGainTransactions = new list<Transaction__c>();
            LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
            Integer month=System.Today().addMonths(-1).Month();
            Integer year=System.Today().addMonths(-1).Year();
            
            // Get the first day of the month
            Date firstDayOfMonth = Date.newInstance(year, month, 1);
            // Get the last day of the month
            Integer lastDayOfMonth = Date.daysInMonth(year, month);
            Date lastDayDate = Date.newInstance(year, month, lastDayOfMonth);
            
            Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
            Integer lastDayOfThisMonth = Date.daysInMonth(System.today().year(), System.today().month());
            Date lastDayDateOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), lastDayOfThisMonth);
            //map<String, User> fspUsersMap = new map<String, User>(fspRecords);
            set<String> fspAccountIds = new set<String>();
            set<String> fspStaffIds = new set<String>();
            for(Account acc: fspRecords){
                system.debug('### FSP Id: '+acc.Name);
                fspAccountIds.add(acc.Id);
                if(acc.Contacts != null && acc.Contacts.size()>0){
                    for(Contact con: acc.Contacts){
                        system.debug('### FSP StaffId: '+con.Name);
                        fspStaffIds.add(con.Id);
                    }
                }
            }
            /*System.debug('ids'+[Select Id, Name, AccountId, CurrencyISOCode From Contact]);
            for( COntact c : [Select Id, Name, AccountId, CurrencyISOCode From Contact] ){
                System.debug( 'FSP:::::'+c.Id );
            }*/
            map<String, Contact> fspStaffMap = new map<String, Contact>([Select Id, Name, AccountId, CurrencyISOCode 
                                                                     From Contact Where ID IN: fspStaffIds]);
            system.debug('### firstDayOfMonth: '+firstDayOfMonth);
            system.debug('### lastDayDate: '+lastDayDate);
            system.debug('### firstDayOfThisMonth: '+firstDayOfThisMonth);
            system.debug('### lastDayDateOfThisMonth: '+lastDayDateOfThisMonth);
            String fxGainLenderId=lwcGlobalSettings.FX_Gain_Lender__c;
            if(lwcGlobalSettings.FX_Gain_Lender__c != null && lwcGlobalSettings.FX_Gain_Lender__c.trim().length()>0){
                Contact fxGainLender = [Select Id, Name From Contact Where Name=: lwcGlobalSettings.FX_Gain_Lender__c];
                fxGainLenderId=fxGainLender.Id;
            }
            
            map<String, list<Loan__c>> fundedLoansByFSP = new map<String, list<Loan__c>>();
            map<String, Decimal> caTofsp_USDMap = new map<String, Decimal>();
            map<String, Decimal> fspToca_VNDMap = new map<String, Decimal>();
            map<String, Repayment_Schedule__c> repaymentsMap = new map<String, Repayment_Schedule__c>();
            list<String> repaymentStatus = new list<String>();
            repaymentStatus.addAll(new list<String>{'Underpaid', 'Overpaid', 'Paid'});
            // Get all the loans which got fully funded in last month and got set by finance team
            list<Loan__c> loans = [Select Id, Name, FSP__c, FSP_Name__c,FSP_Monthly_Settlement__c, FSP_Name__r.Name, Loan_Principal_Disbursed_USD__c, 
                                   Loan_Principal_Disbursed_AUD__c, Published_Amount_AUD__c, Buffer_AUD__c, Include_in_Offset_Calculation__c,
                                   Future_Offset_Inclusion_Date__c,
                                   (Select Id, Name, Amount_Due__c, Due_Date__c, Principal_Repaid__c, 
                                    Repayment_Date__c, Status__c, Loan__c, Loan__r.FSP_Name__c 
                                    From Repayment_Schedules__r 
                                    Where (Status__c = NULL OR Status__c =: repaymentStatus) 
                                    AND ((Due_Date__c >=: firstDayOfMonth AND Due_Date__c <=: lastDayDate)
                                         OR ((Repayment_Date__c >=: firstDayOfThisMonth AND Repayment_Date__c <=: lastDayDateOfThisMonth) AND Principal_Repaid__c != NULL AND Status__c != NULL))) 
                                   From Loan__c 
                                   Where FSP__c IN: fspAccountIds 
                                   AND Stage__c='Active' AND Loan_Principal_Disbursed_AUD__c>0 
                                   AND Repaid_Date__c=NULL
                                   AND Include_in_Offset_Calculation__c=true
                                   AND Actual_Loan_Principle_Disbursed_AUD__c=NULL
                                   AND ((Funded_Date__c >=: firstDayOfMonth AND Funded_Date__c <=: lastDayDate)
                                        OR (Future_Offset_Inclusion_Date__c >: firstDayOfThisMonth AND Future_Offset_Inclusion_Date__c <=: lastDayDateOfThisMonth))];
            system.debug('### loans size: '+loans.size());
            /*for(Loan__c l: [SELECT Id, FSP_Name__c FROM Loan__c]){
                System.debug('### FSP NAME: '+l.FSP_Name__c);
            }*/
            // prepare a map of all funded loans for each FSP
            if(loans != null && loans.size()>0){
                for(Loan__c l: loans){
                    //system.debug('### Loan: '+l.Name);
                    if(l.Repayment_Schedules__r != null && l.Repayment_Schedules__r.size()>0){
                        for(Repayment_Schedule__c rs: l.Repayment_Schedules__r){
                            repaymentsMap.putAll(l.Repayment_Schedules__r);
                        }
                    }
                    list<Loan__c> result = fundedLoansByFSP.get(l.FSP__c);
                    if(result==null){
                    	result = new list<Loan__c>();
                    }
                    result.add(l);
                    fundedLoansByFSP.put(l.FSP__c, result);
                }
            }
            
            // prepare a map of the funded loan amount in AUD for each FSP
            set<Id> fspContactIds = new set<Id>();
            for(Account fsp: fspRecords){
                list<Loan__c> fundedLoans = fundedLoansByFSP.get(fsp.Id);
                if(fundedLoans != null && fundedLoans.size()>0){
                    for(Loan__c l: fundedLoans){
                        if(caTofsp_USDMap.containsKey(fsp.Id)){
                            l.Loan_Principal_Disbursed_USD__c = l.Loan_Principal_Disbursed_USD__c==null?0:l.Loan_Principal_Disbursed_USD__c;
                            Decimal caTofsp_USD = caTofsp_USDMap.get(fsp.Id)+l.Loan_Principal_Disbursed_USD__c;
                            caTofsp_USDMap.put(fsp.Id, caTofsp_USD);
                        }else{
                            caTofsp_USDMap.put(fsp.Id, l.Loan_Principal_Disbursed_USD__c);
                        }
                        
                        Decimal audConversion = LWCUtilityFX.conversionfromUSDtoAUD(l.Loan_Principal_Disbursed_USD__c, currencyConversionMap);
                        l.Actual_Loan_Principle_Disbursed_AUD__c=audConversion;
                        
                        l.Buffer_To_Repay__c = l.Published_Amount_AUD__c - l.Actual_Loan_Principle_Disbursed_AUD__c;
                        if(l.Buffer_To_Repay__c > l.Buffer_AUD__c){
                            Decimal diffAmount=l.Buffer_To_Repay__c-l.Buffer_AUD__c;
                            // create fxGainTransactions if required
                            fxGainTransactions.add(new Transaction__c(Loan__c=l.Id, Lender__c=fxGainLenderId, CurrencyIsoCode='AUD', 
                                                                      Completed_Date__c=System.Today(),Amount__c=diffAmount.setScale(2), 
                                                                      Type__c='FX Gain', Status__c='Completed', 
                                                                      Transaction_Date__c=System.Today()));
                            l.Buffer_To_Repay__c=l.Buffer_AUD__c;
                        }
                        
                        if(l.Buffer_To_Repay__c < 0){
                            // create fxGainTransactions with negative value
                            fxGainTransactions.add(new Transaction__c(Loan__c=l.Id, Lender__c=fxGainLenderId, CurrencyIsoCode='AUD', Completed_Date__c=System.Today(),
                                                                      Amount__c=l.Buffer_To_Repay__c.setScale(2), Type__c='FX Gain',
                                                                      Status__c='Completed', Transaction_Date__c=System.Today()));
                            l.Buffer_To_Repay__c=0;
                        }
                        
                        if(l.Include_in_Offset_Calculation__c==false && l.Future_Offset_Inclusion_Date__c!=null){
                            l.Include_in_Offset_Calculation__c=true;
                            l.Future_Offset_Inclusion_Date__c=null;
                        }
                        
                        loansMap.put(l.Id, l);
                    }
                }
            }
            system.debug('### caTofsp_USDMap size: '+caTofsp_USDMap.size());
            
            // get all the due repayment whichever has been set by FSP or not set by FSP to automatically set by the system
            // as a part of offset calculation
            map<String, String> fspAutoSetRepaymentMap = new map<String, String>();
            list<Repayment_Schedule__c> rsList = [Select Id, Name, Amount_Due__c, Due_Date__c, Loan__r.FSP_Name__r.Name, Loan__r.FSP__c,
                                                  Principal_Repaid__c, Repayment_Date__c, Status__c, Loan__c, Loan__r.Name, Loan__r.FSP_Name__c,
                                                  Loan__r.Include_in_Offset_Calculation__c
                                                  From Repayment_Schedule__c 
                                                  Where Loan__r.FSP__c IN: fspAccountIds
                                                  AND Loan__r.Stage__c='Active'
                                                  AND Loan__r.Loan_Principal_Disbursed_AUD__c>0 
                                                  AND Loan__r.Repaid_Date__c=NULL
                                                  AND Loan__r.Include_in_Offset_Calculation__c=true
                                                  AND (Status__c = NULL OR Status__c =: repaymentStatus) 
                                                  AND ((Due_Date__c >=: firstDayOfMonth AND Due_Date__c <=: lastDayDate)
                                                       OR ((Repayment_Date__c >=: firstDayOfThisMonth AND Repayment_Date__c <=: lastDayDateOfThisMonth) 
                                                           AND Principal_Repaid__c != NULL AND Status__c != NULL))];
            //system.debug('### rsList size: '+rsList.size());
            if(rsList != null && rsList.size()>0){
                repaymentsMap.putAll(rsList);
                for(Repayment_Schedule__c rs: repaymentsMap.values()){
                    system.debug('### Loan: '+rs.Loan__r.Name);
                     List<Repayment_Schedule__c> result = fspRSTag.get(rs.Loan__r.FSP__c);
                                if(result==null)
                                {
                                    result = new List<Repayment_Schedule__c>();
                                }
                                result.add(rs);
                                fspRSTag.put(rs.Loan__r.FSP__c, result);
                    // Automatically set the due repayment for last month
                    if(rs.Due_Date__c >= firstDayOfMonth && rs.Due_Date__c <= lastDayDate){
                        // we don't want to consider larger payment to automatically set if FSP didn't set as per schedule
                        if(rs.Status__c==NULL && rs.Principal_Repaid__c==NULL){
                            rs.Status__c='Paid';
                            rs.Repayment_Date__c=System.Today();
                            rs.Principal_Repaid__c=LWCUtilityFX.conversionfromLCtoAUD(rs.Amount_Due__c,'VND',currencyConversionMap);
                            autosetRepaymentsMap.put(rs.Id, rs);
                            fspAutoSetRepaymentMap.put(rs.Loan__r.FSP_Name__c, rs.Loan__r.FSP_Name__r.Name);
                        }
                        if(rs.Status__c!=NULL &rs.Principal_Repaid__c!=NULL)
                        {
                            
                        }
                    }
                    
                    if(fspToca_VNDMap.containsKey(rs.Loan__r.FSP__c)){
                        Decimal fspToca_VND = fspToca_VNDMap.get(rs.Loan__r.FSP__c)+rs.Principal_Repaid__c;
                        fspToca_VNDMap.put(rs.Loan__r.FSP__c, fspToca_VND);
                    }else{
                        fspToca_VNDMap.put(rs.Loan__r.FSP__c, rs.Principal_Repaid__c);
                    }
                }
            }
            system.debug('### repaymentsMap size: '+repaymentsMap.size());
            system.debug('### fspToca_VNDMap size: '+fspToca_VNDMap.size());
            
            // Check for Non-Clearance or Settlement records
            map<String, list<FSP_Monthly_Settlement__c>> existingSettlementsMap = new map<String, list<FSP_Monthly_Settlement__c>>();
            list<FSP_Monthly_Settlement__c> existingSettlements = [Select Id, Name, FSP__c, FSP_Staff__c, Below_Threshold__c, Month__c, 
                                                                   Year__c, Offset_Clearance__c, Offset_Balance_for_FSP_USD__c 
                                                                   From FSP_Monthly_Settlement__c
                                                                   Where FSP__c IN: fspAccountIds
                                                                   AND ((Month__c =: month AND Year__c =: year) 
                                                                        OR (Below_Threshold__c=true AND Offset_Clearance__c=false))];
            if(existingSettlements != null && existingSettlements.size()>0){
                for(FSP_Monthly_Settlement__c ems: existingSettlements){
                    list<FSP_Monthly_Settlement__c> result = existingSettlementsMap.get(ems.FSP__c);
                    if(result==null){
                        result = new list<FSP_Monthly_Settlement__c>();
                    }
                    result.add(ems);
                    existingSettlementsMap.put(ems.FSP__c, result);
                }
            }
            
            // get FX Rates from Integration before Offset calculation
            Decimal fxAUDToUSD=LWCUtilityFX.getConversionRate('USD');
            map<String, FSP_Monthly_Settlement__c> fmsMapToBeProcessed = new map<String, FSP_Monthly_Settlement__c>();
            for(Account fsp: fspRecords){
                Boolean isValidLocalCurrency=false;
                String localCurrency='';
                if(fsp.CurrencyISOCode != null){
                    if(fundedLoansByFSP.containsKey(fsp.Id) || fspToca_VNDMap.containsKey(fsp.Id)){
                        isValidLocalCurrency=true;
                    }
                    localCurrency = fsp.CurrencyISOCode;
                }else{
                    system.debug('### Local Currency is not defined for '+fsp.Name);
                }
                
                if(isValidLocalCurrency){
                    system.debug('### Local Currency '+localCurrency);
                    //system.debug('### currencyConversionMap '+currencyConversionMap.size());
                    Decimal fxLCToUSD=LWCUtilityFX.getConversionRateLCToUSD(localCurrency, currencyConversionMap);
                    //system.debug('### fxLCToUSD '+fxLCToUSD);
                    Boolean isAlreadyProcessed=false;
                    Boolean hasPendingClearance=false;
                    Decimal previousMonthClearanceAmount=0.0;
                    String monthYear=LWCUtility.getMonth(month)+'-'+year;
                    // Check for Offset Clearance Balance which Below Threashold in previous months
                    if(existingSettlementsMap.containsKey(fsp.Id)){
                        list<FSP_Monthly_Settlement__c> emsList = existingSettlementsMap.get(fsp.Id);
                        if(emsList != null && emsList.size()>0){
                            for(FSP_Monthly_Settlement__c efms: emsList){
                                if(efms.Month__c==month && efms.Year__c==year){
                                    // Balance Offset for this FSP has been processed for this month already
                                    isAlreadyProcessed=true;
                                    fspMSTag.put(efms.FSP__c,efms);
                                    
                                }
                                
                                if(efms.Below_Threshold__c==true && efms.Offset_Clearance__c==false){
                                    hasPendingClearance=true;
                                    if(efms.Offset_Balance_for_FSP_USD__c!=null)
                                    	previousMonthClearanceAmount+=efms.Offset_Balance_for_FSP_USD__c;
                                    else
                                        previousMonthClearanceAmount+=0.0;
                                    fmsMapToBeProcessed.put(efms.FSP__c, new FSP_Monthly_Settlement__c(Id=efms.Id, Offset_Clearance__c=true));
                                }
                            }
                        }
                    }
                    
                    if(!isAlreadyProcessed){
                        system.debug('### To be processed: '+fsp.Name);
                        FSP_Monthly_Settlement__c fms = new FSP_Monthly_Settlement__c();
                        if(fmsMapToBeProcessed.containsKey(fsp.Id)){
                            fms=fmsMapToBeProcessed.get(fsp.Id);
                        }else{
                            fms = new FSP_Monthly_Settlement__c(FSP__c=fsp.Id, Offset_Calculation_Date__c=System.Today(), Month__c=month, 
                                                                Year__c=year, Offset_Month_Year__c=monthYear);
                        }
                        
                        //FSP should be able to see how much conversion rate was used in offset calculation (Local currency > AUD).
                        if(fms.FX_AUD_To_USD__c==null){
                            fms.FX_AUD_To_USD__c=fxAUDToUSD;
                        }else{
                            fms.FX_AUD_To_USD__c+=fxAUDToUSD;
                        }
                        
                        //FSP should be able to see how much conversion rate was used in offset calculation (Local currency > USD).
                        if(fms.FX_LC_To_USD__c==null){
                        	fms.FX_LC_To_USD__c=fxLCToUSD;
                        }else{
                            fms.FX_LC_To_USD__c+=fxLCToUSD;
                        }
                        
                        Decimal caTofsp_USD=0;
                        Decimal fspToca_VND=0;
                        if(caTofsp_USDMap.containsKey(fsp.Id)){
                            caTofsp_USD = caTofsp_USDMap.get(fsp.Id);
                            
                            if(fms.Funded_Loan_Amount_USD__c==null){
                                fms.Funded_Loan_Amount_USD__c=caTofsp_USD.setScale(10);
                            }else{
                                fms.Funded_Loan_Amount_USD__c+=caTofsp_USD.setScale(10);
                            }
                            
                            if(fms.Funded_Loan_Amount_USD__c > 0){
                                fms.Funded_Loan_Amount_USD__c=fms.Funded_Loan_Amount_USD__c.setScale(10);
                            }
                            /*if(fms.Funded_Loan_Amount_AUD__c != null && fms.Funded_Loan_Amount_AUD__c>0){
                                //convert the fully funded loan amount from AUD to USD
                                fms.Funded_Loan_Amount_USD__c= fms.Funded_Loan_Amount_AUD__c*fms.FX_AUD_To_USD__c;
                            }*/
                            
                            //system.debug('### Funded_Loan_Amount_AUD__c: '+fms.Funded_Loan_Amount_AUD__c);
                            //system.debug('### Funded_Loan_Amount_USD__c: '+fms.Funded_Loan_Amount_USD__c);
                        }
                        
                        for(String str: fspToca_VNDMap.keyset()){
                            system.debug('### fspToca_VNDMap FSPId: '+str+'-'+fspToca_VNDMap.get(str));
                        }
                        if(fspToca_VNDMap.containsKey(fsp.Id)){
                            fspToca_VND = fspToca_VNDMap.get(fsp.Id);
                            fms.FSP_Repayment_Amount_LC__c=fspToca_VND.setScale(2);
                            // convert the repayment amount from VND to USD
                            if(fms.FSP_Repayment_Amount_LC__c!=null){
                                Decimal fspUSDAmount=(fms.FSP_Repayment_Amount_LC__c*fms.FX_LC_To_USD__c);
                                fms.FSP_Repayment_Amount_USD__c=fspUSDAmount.setScale(10);
                            }
                            
                            //system.debug('### FSP_Repayment_Amount_VND__c: '+fms.FSP_Repayment_Amount_LC__c);
                            //system.debug('### FSP_Repayment_Amount_USD__c: '+fms.FSP_Repayment_Amount_USD__c);
                            // FSP should be able to set the below field value manually from the FSP Portal to inform what FX Rate they got from Bank
                            // at the time of sending the money to CA
                            //fms.FSP_VND_To_USD__c=0;
                            // CA should be able to set the below field value to inform what FX Rate they have got from their bank upon receival
                            //fms.CA_USD_To_AUD__c=0;
                        }
                        
                        // calculate the difference in fully funded loans and repayments for the FSP in USD
                        Decimal offsetBalanceUSD=0;
                        if(fms.Funded_Loan_Amount_USD__c != null && fms.Funded_Loan_Amount_USD__c > 0){
                            offsetBalanceUSD = fms.Funded_Loan_Amount_USD__c;
                        }
                        
                        if(previousMonthClearanceAmount != null && previousMonthClearanceAmount > 0){
                            offsetBalanceUSD += previousMonthClearanceAmount;
                        }
                        
                        if(fms.FSP_Repayment_Amount_USD__c != null && fms.FSP_Repayment_Amount_USD__c > 0){
                            offsetBalanceUSD = offsetBalanceUSD - fms.FSP_Repayment_Amount_USD__c;
                        }
                        
                        if(offsetBalanceUSD != null){
                            if(offsetBalanceUSD > 0){
                                //FSP should be able to see how much they will receive from CA in USD 
                                if(fms.Offset_Balance_for_FSP_USD__c==null){
                                    fms.Offset_Balance_for_FSP_USD__c=offsetBalanceUSD;
                                }else{
                                    fms.Offset_Balance_for_FSP_USD__c+=offsetBalanceUSD;
                                }
                            }else{
                                //FSP should be able to see how much CA needs to receive in USD 
                                if(fms.Offset_Balance_for_CA_USD__c==null){
                                    fms.Offset_Balance_for_CA_USD__c= offsetBalanceUSD * (-1);
                                }else{
                                    fms.Offset_Balance_for_CA_USD__c+= (offsetBalanceUSD * (-1));
                                }
                                
                            }
                        }
                        
                        system.debug('### Offset_Balance_for_FSP_USD__c: '+fsp.Name+' - '+fms.Offset_Balance_for_FSP_USD__c);
                        system.debug('### Offset_Balance_for_CA_USD__c: '+fsp.Name+' - '+fms.Offset_Balance_for_CA_USD__c);
                        //system.debug('### FSP_Payment_Threshold_USD__c: '+lwcGlobalSettings.FSP_Payment_Threshold_USD__c);
                        
                        if(lwcGlobalSettings.FSP_Payment_Threshold_USD__c < fms.Offset_Balance_for_FSP_USD__c){
                            // Send money to FSP
                            // create record for FSP in FSP_Monthly_Settlement__c for current month
                            fms.Offset_Clearance__c=true;
                        }else{
                            // should be added to the offset report next month, in favor of FSP
                            fms.Below_Threshold__c=true;
                            fms.Offset_Clearance__c=false;
                        }
                        
                        if((fms.Offset_Balance_for_FSP_USD__c != null && fms.Offset_Balance_for_FSP_USD__c > 0) || (fms.Offset_Balance_for_CA_USD__c != null && fms.Offset_Balance_for_CA_USD__c > 0)){
                            fmsMapToBeProcessed.put(fsp.Id, fms);
                        }
                    }else{
                        system.debug('### Balance Offset for FSP: '+fsp.Name+' has been processed for this month already...');
                    }
                }
            }
            
            system.debug('### fmsMapToBeProcessed size: '+fmsMapToBeProcessed.size());
            if(fmsMapToBeProcessed != null && fmsMapToBeProcessed.size()>0){
                upsert fmsMapToBeProcessed.values();
                for(FSP_Monthly_Settlement__c fms: fmsMapToBeProcessed.values()){
                    fspMSTag.put(fms.FSP__c, fms);
                }
            }
            
            List<Repayment_Schedule__c> repaymentsToUpdate=new List<Repayment_Schedule__c>();
            for(String fspId: fspMSTag.keySet())
            {
                for(Repayment_Schedule__c rs: fspRSTag.get(fspId))
                {
                    rs.FSP_Monthly_Settlement__c=fspMSTag.get(fspId).Id;
                    repaymentsToUpdate.add(rs);
                }
                
                for(Loan__c l: fundedLoansByFSP.get(fspId))
                {
                    if(loansMap.containsKey(l.Id))
                    {
                        Loan__c resultLoan=loansMap.get(l.Id);
                        resultLoan.FSP_Monthly_Settlement__c=fspMSTag.get(fspId).Id;
                        loansMap.put(l.Id,resultLoan);
                    }
                    
                }
            }
            
            if(repaymentsToUpdate!=null && repaymentsToUpdate.size()>0)
            {
                update repaymentsToUpdate;
            }
            
            system.debug('### loansMap size: '+loansMap.size());
            if(loansMap != null && loansMap.size()>0){
                update loansMap.values();
            }
            
            if(fxGainTransactions != null && fxGainTransactions.size()>0){
                insert fxGainTransactions;
            }
                        
            system.debug('### autosetRepaymentsMap size: '+autosetRepaymentsMap.size());
            if(autosetRepaymentsMap != null && autosetRepaymentsMap.size()>0){
                update autosetRepaymentsMap.values();
            }
            
            if(fspAutoSetRepaymentMap != null && fspAutoSetRepaymentMap.size()>0){
                String lwcAdminGroupId;
                list<CollaborationGroup> groups = [SELECT Id FROM CollaborationGroup WHERE Name = 'LWC Admin' LIMIT 1];
                if(groups != null && groups.size()>0){
                    lwcAdminGroupId=groups[0].Id;
                }else{
                    if(Test.isRunningTest()){
                        lwcAdminGroupId=lwcAdminGrpId;
                    }
                }
                
                for(String fspId: fspAutoSetRepaymentMap.keyset()){
                    feedItemList.add(LWCUtility.createChatterFeed_LoanRepayment(lwcAdminGroupId, fspId, fspAutoSetRepaymentMap.get(fspId)));
                }
                
                if (!feedItemList.isEmpty()) {
                    insert feedItemList;
                    system.debug('### feedItemList Size-->'+feedItemList.size());
                }
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            System.debug(ex);
            System.debug(ex.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_CalculateFSPBalance_8EMScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=ex.getStackTraceString());
            insert err;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}