public without sharing class FSP_UpdateRepaymentsCtrl {
    public string nameFile {get;set;}
    public Blob contentFile {get;set;}
    
    public String documentName;
    public boolean readSuccess {get;set;}
    String rsContent;
    public String[] rsDataLines {get;set;}
    public list<RSModal1> rsList {get;set;}
    Map<String, Integer> fieldNumberMap = new Map <String, Integer>();
    public List<String> lstFieldNames {get;set;}
    public list<SelectOption> nonPerformingOptions {get;set;}
    @AuraEnabled(cacheable=true)
    public static List<RSModal> processCSVFile(String csvContent) {
        system.debug('%%% '+csvContent);
        List<RSModal> rsList = new List<RSModal>();
        
        List<String> csvLines = csvContent.split('\n');
        if (csvLines.size() > 1) {
            String[] headerTokens = csvLines[0].split(',');
            
            for (Integer i = 1; i < csvLines.size(); i++) {
                String[] fieldTokens = csvLines[i].split(',');
                
                if (fieldTokens.size() >= headerTokens.size()) {
                    RSModal rsModal = new RSModal();
                    rsModal.repaymentScheduleID = fieldTokens[0];
                    rsModal.careLoanID = fieldTokens[1];
                    rsModal.fspLoanID = fieldTokens[2];
                    rsModal.location = fieldTokens[3];
                    rsModal.loanAmount = parseDecimal(fieldTokens[4]);
                    rsModal.loanCurrency = fieldTokens[5];
                    rsModal.cumulativeAmountReceivedSoFar = parseDecimal(fieldTokens[6]);
                    rsModal.totalExpectedIncLastMonth = parseDecimal(fieldTokens[7]);
                    rsModal.lastMonthsExpectedRepayment = parseDecimal(fieldTokens[8]);
                    rsModal.cumulativeAmountReceivedThisMonth = parseDecimal(fieldTokens[9]);
                    rsModal.writeOffRequest = Boolean.valueOf(fieldTokens[10]);
                    rsModal.comment = fieldTokens[11];
                    system.debug('cumu--> '+rsModal.cumulativeAmountReceivedThisMonth);
                    rsList.add(rsModal);
                }
            }
        }
        
        return rsList;
    }
    @auraenabled
    public static List<RSModal1> readCSVFile1(String csvContent) {
        system.debug('csvContent'+csvContent);
        Map<String, Integer> fieldNumberMap = new Map <String, Integer>();
        boolean readSuccess;
        List <RSModal1> rsList = new List <RSModal1>();
        String[] rsDataLines = csvContent.split('\n');
        for (String line : rsDataLines) {
            if (line.contains('"')) {
                RSModal1 errorRsm = new RSModal1();
                errorRsm.errorMessage = 'Please upload a file of type CSV Unicode(UTF-8)';
                List<RSModal1> errorList = new List<RSModal1>{errorRsm};
                    return errorList;   
            } 
        }
        list<String> csvFieldNames = rsDataLines[0].split(',');
        for(Integer i=0;i<csvFieldNames.size();i++){
            system.debug('%%% '+csvFieldNames[i]);
            csvFieldNames[i]=csvFieldNames[i].trim();
        }
        Boolean isValidDoc = true;
        if(!csvFieldNames.contains('﻿Repayment Schedule: ID') && !csvFieldNames.contains('Repayment Schedule: ID')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Loan: ID')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('FSP Loan ID')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Location')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Loan Principal Disbursed (LC)')){isValidDoc=false;}
        if(!csvFieldNames.contains('Loan: Currency')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Cumulative Amount Received To Date (LC)')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Total Expected Inc Last Month')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Last Month\'s Expected Repayment')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Cumulative Amount Received This Month')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Write Off Request')){isValidDoc=false;}//system.debug('isValidDoc-->'+isValidDoc);
        if(!csvFieldNames.contains('Comments')){isValidDoc=false;}
        system.debug('isValidDoc-->'+isValidDoc);
        if(isValidDoc){
            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumberMap.put(csvFieldNames[i], i);
            }
            set<String> repaymentScheduleId = new set<String>();
            set<String> careLoanId = new set<String>();
            set<String> fspLoanId = new set<String>();
            System.debug('>>> Total Records: '+rsDataLines.size());
            for(Integer i = 1; i < rsDataLines.size(); i++)
            { 
                String val = rsDataLines[i];
                System.debug('@@@ Line Data '+i+': '+val);
                RSModal1 rsm = new RSModal1();
                rsm.isSelected=false;
                rsm.srNo=String.valueOf(i);
                rsm.message='';
                String sub1='';
                
                String addvalues='';
                
                String val0,val1,val2,val3,val4,val5,val6,val7,val8,val9,val10,val11;
                val = val.remove('\n');
                val = val.remove('<br/>');
                
                val0=val.substring(0,val.indexOf(',')+1);
                sub1 = val.substring(val.indexOf(',')+1);
                val1=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val2=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val3=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val4=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val5=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val6=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val7=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val8=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val9=sub1.substring(0,sub1.indexOf(',')+1);
                system.debug('cumu--> '+val9);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                val10=sub1.substring(0,sub1.indexOf(',')+1);
                sub1 = sub1.substring(sub1.indexOf(',')+1);
                if(val11 == NULL){
                    val11=sub1; 
                }else{
                    val11=sub1.substring(0,sub1.indexOf(',')+1);
                    sub1 = sub1.substring(sub1.indexOf(',')+1);
                    if(sub1=='0'){
                        val11='0';
                    }
                }
                
                addvalues= val0+val1+val2+val3+val4+val5+val6+val7+val8+val9+val10+val11;
                
                string[] csvRecordData;
                if(addvalues == ''){
                    csvRecordData= rsDataLines[i].split(',');
                }else{
                    addvalues= addvalues.trim();
                    rsDataLines[i] = addvalues;
                    csvRecordData=rsDataLines[i].split(',');
                }                
                for(String fieldName: csvFieldNames) {
                    Integer fieldNumber = fieldNumberMap.get(fieldName);
                    String fieldValue = '';
                    if(fieldNumber>csvRecordData.size()-1){
                        fieldValue='';
                    }else{
                        fieldValue=csvRecordData[fieldNumber];
                    }
                    
                    if(fieldName.trim()=='﻿Repayment Schedule: ID' || fieldName.trim()=='Repayment Schedule: ID'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            repaymentScheduleId.add(fieldValue);
                            rsm.repaymentScheduleID=fieldValue;
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Repayment schedule ID';
                            }else{
                                rsm.message+='Repayment schedule ID';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Loan: ID'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            careLoanId.add(fieldValue);
                            rsm.careLoanID=fieldValue;
                            system.debug('rsm.careLoanID--> '+rsm.careLoanID);
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Loan: ID';
                            }else{
                                rsm.message+='Loan: ID';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='FSP Loan ID'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            fspLoanId.add(fieldValue);
                            rsm.fspLoanID=fieldValue;
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', FSP Loan ID';
                            }else{
                                rsm.message+='FSP Loan ID';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Location'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            rsm.location=fieldValue;
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Location';
                            }else{
                                rsm.message+='Location';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Loan Principal Disbursed (LC)'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            if(fieldValue != null){
                                rsm.loanAmount=Decimal.valueOf(fieldValue);
                            }
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Loan amount';
                            }else{
                                rsm.message+='Loan amount';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Loan: Currency'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            rsm.loanCurrency=fieldValue;
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Loan currency';
                            }else{
                                rsm.message+='Loan currency';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Cumulative Amount Received To Date (LC)'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            if(fieldValue != null){
                                rsm.cumulativeAmountReceivedSoFar=Decimal.valueOf(fieldValue);
                            }
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Cumulative Amount Received To Date';
                            }else{
                                rsm.message+='Cumulative Amount Received To Date';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Total Expected Inc Last Month'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            if(fieldValue != null){
                                rsm.totalExpectedIncLastMonth=Decimal.valueOf(fieldValue);
                            }
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Total Expected Inc Last Month';
                            }else{
                                rsm.message+='Total Expected Inc Last Month';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Last Month\'s Expected Repayment'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            if(fieldValue != null){
                                rsm.lastMonthsExpectedRepayment=Decimal.valueOf(fieldValue);
                            }
                        }else{
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Last Month\'s Expected Repayment';
                            }else{
                                rsm.message+='Last Month\'s Expected Repayment';
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Cumulative Amount Received This Month'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            if(fieldValue != null){
                                rsm.cumulativeAmountReceivedThisMonth=Decimal.valueOf(fieldValue);
                                system.debug('  rsm.cumulativeAmountReceivedThisMonth--> '+  rsm.cumulativeAmountReceivedThisMonth);
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Write Off Request'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            if(fieldValue=='true'){
                                rsm.writeOffRequest=true;
                            }
                        }
                    }
                    
                    if(fieldName.trim()=='Comments'){
                        if(fieldValue != null && fieldValue.trim().length()>0){
                            rsm.comment=fieldValue;
                        }
                    }
                    
                }
                rsList.add(rsm);
            }
            
            system.debug('### rsList size: '+rsList);
            if(rsList != null && rsList.size()>0){
                map<String, Loan__c> loansMap = new map<String, Loan__c>();
                list<Loan__c> loans = [Select Id, Name, FSP_Loan_Id__c, Loan_Principal_Disbursed__c, Is_NonPerforming__c,
                                       First_Date_NonPerforming__c, Last_Months_Expected_Repayment__c, Total_Expected_Inc_Last_Month__c,
                                       Cumulative_Amount_Received_To_Date__c, CurrencyISOCode, FSP_Name__c, FSP_Name__r.Name 
                                       From Loan__c Where  Id IN: careLoanId OR Name IN: careLoanId];
                system.debug('### loans: '+loans.size());
                if(loans != null && loans.size()>0){
                    for(Loan__c l: loans){
                        String ids = l.Id;
                        String idtoUse = ids.substring(0, 15);
                        loansMap.put(idtoUse, l);
                        //   loansMap.put(l.Name, l);
                    }
                }
                system.debug('### loansMap: '+loansMap);
                
                map<String, Repayment_Schedule__c> repaymentsMap = new map<String, Repayment_Schedule__c>([Select Id, Name, Principal_Repaid__c,Status__c,
                                                                                                           Cumulative_Amount_Received_This_Month__c, 
                                                                                                           Write_Off_Request__c, Non_performing_loan_options__c, 
                                                                                                           Non_performing_loan_options_other__c, Loan__c
                                                                                                           From Repayment_Schedule__c 
                                                                                                           Where Id IN: repaymentScheduleId
                                                                                                           Order By Due_Date__c]);
                system.debug('### repaymentsMap: '+repaymentsMap.size());
                if((loansMap != null && loansMap.size()>0) && (repaymentsMap != null && repaymentsMap.size()>0)){
                    for(RSModal1 rsm: rsList)
                    {
                        system.debug('### Entered in Logic part...'+rsm.repaymentScheduleID);
                        Id repaymentId=rsm.repaymentScheduleID;
                        if(repaymentsMap.containsKey(repaymentId)){
                            rsm.rs=repaymentsMap.get(repaymentId);
                            //rsm.loan=repaymentsMap.get(repaymentId).Loan__c;
                            //system.debug('rs-->'+rsm.rs);
                            if(rsm.rs.Status__c==null||rsm.rs.Cumulative_Amount_Received_This_Month__c==null||rsm.rs.Principal_Repaid__c==null){
                                rsm.isEditable=true;
                                rsm.comment='';
                            }else{
                                rsm.isEditable=false;
                                rsm.cumulativeAmountReceivedThisMonth=rsm.rs.Cumulative_Amount_Received_This_Month__c;
                                rsm.writeOffRequest=rsm.rs.Write_Off_Request__c;
                                rsm.nonPerformingOptions=rsm.rs.Non_performing_loan_options__c;
                                rsm.comment=rsm.rs.Non_performing_loan_options_other__c;
                            }
                        }else{
                            // Repayment Schedule record not found.
                            if(rsm.message.trim().length()>0){
                                rsm.message+=', Repayment Scheule';
                            }else{
                                rsm.message+='Repayment Scheule';
                            }
                        }
                        Boolean found = false;
                        system.debug('rsm.loansMap.keySet()'+loansMap.keySet());
                        set<string> loansMapids = new  set<string>(loansMap.keySet());
                        for (String key : loansMapids) {
                            if(key.length()>=15){
                                String first15Characters = key.substring(0, 15);
                                if (first15Characters == (rsm.careLoanID)) {
                                    found = true;
                                    break; // Exit the loop since we found a match
                                }
                            }
                            
                            if(loansMap.containsKey(rsm.careLoanID)){
                                found = true;
                                break;
                            }
                        }
                        if (found) {
                            rsm.loan=loansMap.get(rsm.careLoanID);
                            system.debug('rsm.loan'+rsm.loan);
                            rsm.cumulativeAmountReceivedSoFar = rsm.loan.Cumulative_Amount_Received_To_Date__c;
                            system.debug('rsm.cumulativeAmountReceivedSoFar'+rsm.cumulativeAmountReceivedSoFar);
                        } else {
                            // Loan record not found.
                            if (rsm.message.trim().length() > 0) {
                                rsm.message += ', Loan';
                            } else {
                                rsm.message += 'Loan';
                            }
                        }
                    }
                    return  rsList;                    
                }else{
                    //return  'No record found.';
                    RSModal1 errorRsm = new RSModal1();
                    errorRsm.errorMessage = 'No record found.';
                    List<RSModal1> errorList = new List<RSModal1>{errorRsm};
                        return errorList;
                }
            }
            //system.debug('### final list size : '+rsList.size());
        }else{
            RSModal1 errorRsm = new RSModal1();
            errorRsm.errorMessage = 'Invalid Document.';
            List<RSModal1> errorList = new List<RSModal1>{errorRsm};
                return errorList;          
        }
        return null; 
    }
    @testvisible
    private static Decimal parseDecimal(String value) {
        Decimal result = null;
        if (!String.isEmpty(value)) {
            try {
                result = Decimal.valueOf(value);
            } catch (Exception ex) {
                // Handle the parsing error
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static  List<RepaymentWrapperSuccess> saveRepayments(string rsList) { 
        Boolean isError = false;
        Boolean isValidToSave = true;
        Integer selectedCount = 0;
        List<String> rsIds = new List<String>();
        List<String> loanIds = new List<String>();
        Map<String, String> fspMap = new Map<String, String>();
        List<RepaymentWrapperSuccess> successList = new List<RepaymentWrapperSuccess>();
        try{
            List<RepaymentWrapper> loanDataList = (List<RepaymentWrapper>) JSON.deserialize(rsList, List<RepaymentWrapper>.class);
            //system.debug('rsList--> '+loanDataList);
            for (RepaymentWrapper rsm : loanDataList)
            {
                if (rsm.Id != null) {
                    rsIds.add(rsm.Id); 
                    loanIds.add(rsm.careLoanID);
                }
                if (rsm.careLoanID == null || rsm.Id == null || rsm.cumulativeAmountReceivedThisMonth == null) {
                    isError = true;
                }
            }
            map<String, Loan__c> loansMap = new map<String, Loan__c>();
            list<Loan__c> loans = [Select Id, Name, FSP_Loan_Id__c, Loan_Principal_Disbursed__c, Is_NonPerforming__c,
                                   First_Date_NonPerforming__c, Last_Months_Expected_Repayment__c, Total_Expected_Inc_Last_Month__c,
                                   Cumulative_Amount_Received_To_Date__c, CurrencyISOCode, FSP_Name__c, FSP_Name__r.Name 
                                   From Loan__c Where Id IN: loanIds];
            system.debug('### loans: '+loans.size());
            if(loans != null && loans.size()>0){
                for(Loan__c l: loans)
                {
                    String idAsString = String.valueOf(l.Id);
                    String truncatedId = idAsString.substring(0, 15);
                    system.debug('truncatedId '+truncatedId);
                    loansMap.put(truncatedId, l);
                }
            }
            map<String, Repayment_Schedule__c> repaymentsMap = new map<String, Repayment_Schedule__c>([
                Select Id, Name, Principal_Repaid__c,
                Cumulative_Amount_Received_This_Month__c, 
                Write_Off_Request__c, Non_performing_loan_options__c, 
                Non_performing_loan_options_other__c,Due_Date__c
                From Repayment_Schedule__c 
                Where Id IN :rsIds
                Order By Due_Date__c
            ]);
            system.debug('### loanDataList: '+loanDataList);
            for (RepaymentWrapper rsm : loanDataList)
            {
                
                Id repaymentId=rsm.id;
                system.debug('rsm.careLoanID '+rsm.careLoanID);
                if(repaymentsMap.containsKey(repaymentId)){
                    rsm.rs=repaymentsMap.get(repaymentId);
                    system.debug('rsm.rs '+rsm.rs);
                }
                /*  if(loansMap.containsKey(rsm.careLoanID)){
rsm.loan=loansMap.get(rsm.careLoanID);
system.debug('rsm.loan '+rsm.loan);
}*/ 
                Boolean found = false;
                system.debug('loansMap.keySet() '+loansMap.keySet());
                set<string> loansMapids = new  set<string>(loansMap.keySet());
                for (String key : loansMap.keySet()) {
                    system.debug('key '+key);
                    String first15Characters = key.substring(0, 15);
                    system.debug('first15Characters '+first15Characters);
                    
                    if (first15Characters == (rsm.careLoanID)) {
                        found = true;
                        break; // Exit the loop since we found a match
                    }
                }
                system.debug('loansMap '+loansMap);
                system.debug('found '+loansMap.get(rsm.careLoanID));
                if (found) {
                    rsm.loan=loansMap.get(rsm.careLoanID);
                }
                system.debug('rsm.loan '+rsm.loan);
            }
            //system.debug('loanDataList--> '+loanDataList);  
            system.debug('isError '+isError);
            if (!isError) {
                Map<String, Loan__c> loansMaps = new Map<String, Loan__c>();
                Map<String, Repayment_Schedule__c> rsMap = new Map<String, Repayment_Schedule__c>();
                
                for (RepaymentWrapper rsm : loanDataList)
                {
                    if(rsm.rs.Id != null){
                        fspMap.put(rsm.loan.FSP_Name__c, rsm.loan.FSP_Name__r.Name);
                    }
                    system.debug('rsm.loan '+rsm.loan);
                    system.debug('rsm.cumulativeAmountReceivedThisMonth '+rsm.cumulativeAmountReceivedThisMonth);
                    if(rsm.loan.Cumulative_Amount_Received_To_Date__c!=null&&rsm.loan!=null){
                        if(rsm.cumulativeAmountReceivedThisMonth >= rsm.loan.Cumulative_Amount_Received_To_Date__c){
                            if (rsm.cumulativeAmountReceivedThisMonth != null) {
                                rsm.rs.Cumulative_Amount_Received_This_Month__c = rsm.cumulativeAmountReceivedThisMonth;
                                rsm.rs.Repayment_Date__c = System.Today();
                            }
                            
                            if(rsm.nonPerformingOptions != ''){
                                rsm.rs.Non_performing_loan_options__c=rsm.nonPerformingOptions;
                                rsm.rs.Comments__c=rsm.nonPerformingOptions;
                            }
                            
                            if(rsm.comment != null){
                                rsm.rs.Non_performing_loan_options_other__c=rsm.comment;
                                rsm.rs.Comments__c=rsm.comment; 
                            }
                            
                            if(rsm.writeOffRequest != null){
                                rsm.rs.Write_Off_Request__c=rsm.writeOffRequest;
                            }
                            
                            if(rsm.cumulativeAmountReceivedThisMonth != null && rsm.cumulativeAmountReceivedThisMonth >= 0){
                                Decimal amountReceived=0;
                                Decimal expectedAmount=0;
                                if(rsm.cumulativeAmountReceivedThisMonth != null){
                                    amountReceived=rsm.cumulativeAmountReceivedThisMonth;
                                }
                                
                                if(rsm.loan.Cumulative_Amount_Received_To_Date__c != null){
                                    amountReceived=amountReceived-rsm.loan.Cumulative_Amount_Received_To_Date__c;
                                }
                                
                                if(rsm.loan.Total_Expected_Inc_Last_Month__c != null){
                                    expectedAmount=rsm.loan.Total_Expected_Inc_Last_Month__c;
                                }
                                
                                if(rsm.loan.Cumulative_Amount_Received_To_Date__c != null){
                                    expectedAmount=expectedAmount-rsm.loan.Cumulative_Amount_Received_To_Date__c;
                                }
                                amountReceived=amountReceived.setScale(2);
                                expectedAmount=expectedAmount.setScale(2);
                                if(amountReceived==0)
                                {
                                    system.debug('### Skipped Section');
                                    //IF 'Cumulative amount expected this month' = Cumulative amount received to date
                                    //THEN Is NonPerforming should be ticked AND IF 'First Date NonPerforming' is empty, 
                                    //update with today’s date AND repayment status should change to 'Skipped'
                                    rsm.loan.Is_NonPerforming__c=true;
                                    if(rsm.loan.First_Date_NonPerforming__c==null){
                                        rsm.loan.First_Date_NonPerforming__c=System.Today();
                                    }
                                    loansMaps.put(rsm.loan.Id, rsm.loan);
                                    rsm.rs.Principal_Repaid__c=0;
                                    rsm.rs.Status__c='Skipped';
                                    rsMap.put(rsm.rs.Id, rsm.rs);
                                }
                                
                                if(amountReceived>0 && (expectedAmount-amountReceived)>0.05){
                                    system.debug('### Underpaid Section');
                                    //IF “Cumulative amount expected this month” > Cumulative amount received to date AND 
                                    //“Cumulative amount expected this month” < (Cumulative amount received to date + last month scheduled repayment)
                                    //THEN repayment status should be updated to “Underpaid”
                                    rsm.loan.Is_NonPerforming__c=true;
                                    if(rsm.loan.First_Date_NonPerforming__c==null){
                                        rsm.loan.First_Date_NonPerforming__c=System.Today();
                                    }
                                    loansMaps.put(rsm.loan.Id, rsm.loan);
                                    rsm.rs.Principal_Repaid__c=rsm.cumulativeAmountReceivedThisMonth-rsm.loan.Cumulative_Amount_Received_To_Date__c;
                                    rsm.rs.Status__c='Underpaid';
                                    rsMap.put(rsm.rs.Id, rsm.rs);
                                }
                                
                                if(expectedAmount-amountReceived < 0.05){
                                    system.debug('### Paid Section');
                                    //IF “Cumulative amount expected this month” = (Cumulative amount received to date + last month scheduled repayment)
                                    //THEN repayment status should be updated to “Repaid”
                                    if(rsm.loan.Is_NonPerforming__c){
                                        rsm.loan.Is_NonPerforming__c=false;
                                        loansMaps.put(rsm.loan.Id, rsm.loan);
                                    }
                                    rsm.rs.Principal_Repaid__c=rsm.cumulativeAmountReceivedThisMonth-rsm.loan.Cumulative_Amount_Received_To_Date__c;
                                    rsm.rs.Status__c='Paid';
                                    rsMap.put(rsm.rs.Id, rsm.rs);
                                }
                                
                                system.debug('### Overpaid Section'+rsm.loan.Total_Expected_Inc_Last_Month__c);
                                if(rsm.loan.Total_Expected_Inc_Last_Month__c!=null){
                                    if(rsm.loan.Total_Expected_Inc_Last_Month__c.setScale(2)<rsm.cumulativeAmountReceivedThisMonth){
                                        system.debug('### Overpaid Section');
                                        //IF “Cumulative amount expected this month” > (Cumulative amount received to date + last month scheduled repayment)
                                        //THEN repayment status should be updated to “Overpaid”
                                        rsm.rs.Principal_Repaid__c=rsm.cumulativeAmountReceivedThisMonth-rsm.loan.Cumulative_Amount_Received_To_Date__c;
                                        rsm.rs.Status__c='Overpaid';
                                        rsMap.put(rsm.rs.Id, rsm.rs);
                                        system.debug('rsMap: '+rsMap);
                                    } 
                                }
                                
                                system.debug('rsMap: '+rsMap);
                                if(rsm.loan.Loan_Principal_Disbursed__c < rsm.cumulativeAmountReceivedThisMonth){
                                    system.debug('### amount is greater than expected.');
                                    isValidToSave=false;
                                    RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                                    errorRsm.errorMessage = 'Amount is greater than expected in row '+rsm.srNo;
                                    List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                                        return errorList; 
                                }
                                
                                if(rsm.loan.Is_NonPerforming__c==true && (rsm.nonPerformingOptions == null||rsm.nonPerformingOptions =='')){
                                    system.debug('### non-perfoming reason is mandatory');
                                    isValidToSave=false;
                                    RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                                    errorRsm.errorMessage = 'Please specify the non-perfoming reason in row '+rsm.srNo;
                                    List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                                        return errorList; 
                                }
                                
                                if(rsm.nonPerformingOptions=='Comment' && (rsm.comment == null || rsm.comment =='')){
                                    system.debug('### comments is mandatory');
                                    isValidToSave=false;
                                    RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                                    errorRsm.errorMessage = 'Please specify reason for non-perfoming loan in row '+rsm.srNo;
                                    List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                                        return errorList; 
                                }
                                if(rsm.writeOffRequest==true && (rsm.nonPerformingOptions == null||rsm.nonPerformingOptions =='')){
                                    system.debug('### non-perfoming reason is mandatory on writeof request');
                                    isValidToSave=false;
                                    RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                                    errorRsm.errorMessage = 'Please specify the non-perfoming reason in row '+rsm.srNo;
                                    List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                                        return errorList; 
                                }
                                if(rsm.writeOffRequest==true && rsm.nonPerformingOptions != null && (rsm.comment==null||rsm.comment=='')){
                                    system.debug('### comments is mandatory on writeof request');
                                    isValidToSave=false;
                                    RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                                    errorRsm.errorMessage = 'Please specify the reason for writeoff request in row '+rsm.srNo;
                                    List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                                        return errorList;   
                                }
                            }
                            if(isValidToSave){
                                RepaymentWrapperSuccess successRsm = new RepaymentWrapperSuccess();
                                successRsm.repaymentId=rsm.rs.Id;
                                successList.add(successRsm);  
                            }
                        }else{
                            RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                            errorRsm.errorMessage = 'Amount entered should be greater than Cumulative Amount Received To Date in row '+rsm.srNo;
                            List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                                return errorList;   
                        }
                    }  else{
                        RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                        errorRsm.errorMessage = 'Either Loan OR Cumulative Amount Received This Month is Empty.';
                        List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                            return errorList; 
                    }
                }
                
                if (isValidToSave) {
                    if (loansMap != null && loansMap.size() > 0) {
                        system.debug('updateloan-->'+loansMap.values());
                        update loansMap.values();
                    }
                    
                    if (rsMap != null && rsMap.size() > 0) {
                        system.debug('updaters-->'+rsMap.values());
                        update rsMap.values();
                    }
                    
                    if (loanDataList.size() == rsIds.size()) {
                        validateIsLoanRepaymentsAllSet(rsIds, fspMap);
                    }
                    return successList;
                } else {
                    RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                    errorRsm.errorMessage = 'Please correct the entries first.';
                    List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                        return errorList; 
                }
                
            } else {
                RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
                errorRsm.errorMessage = 'Either Loan or Payment not found OR Cumulative Amount Received This Month is Empty.';
                List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                    return errorList; 
            }  
        }catch(Exception e){
            system.debug('### e: '+e+' - '+e.getStackTraceString());
            RepaymentWrapperSuccess errorRsm = new RepaymentWrapperSuccess();
            if(e.getMessage().contains('N/A')){
                errorRsm.errorMessage = 'Please enter some values before hitting save button.';
            }else if(e.getMessage().contains('neither a decimal digit number'))
            {
                errorRsm.errorMessage = 'Please enter only numbers in Cumulative Amount Received This Month field';   
            }else{
                errorRsm.errorMessage=e.getMessage();
            }
            system.debug('error--> '+e);
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='FSP_UpdateRepaymentsCtrl', MethodName__c='saveRepayments', 
                                                        Exception_Type__c='Error', Description__c=e.getMessage(), 
                                                        StackTrace__c=e.getStackTraceString());
            insert err;
            List<RepaymentWrapperSuccess> errorList = new List<RepaymentWrapperSuccess>{errorRsm};
                return errorList; 
        }
        
        
    }
    
    @AuraEnabled
    public static void validateIsLoanRepaymentsAllSet(List<String> rsIds, Map<String, String> fspMap) {
        //   system.debug('');
        
        List<FeedItem> feedItemList = new List<FeedItem>();
        List<Repayment_Schedule__c> rsList = [SELECT Id, Name, Loan__c, Principal_Repaid__c, Cumulative_Amount_Received_This_Month__c,  Write_Off_Request__c, Non_performing_loan_options__c, 
                                              Non_performing_loan_options_other__c, Loan__r.FSP_Name__c, Loan__r.FSP_Name__r.Name FROM Repayment_Schedule__c WHERE Id IN :rsIds];
        
        if (rsList != null && !rsList.isEmpty()) {
            CollaborationGroup groups = [SELECT Id FROM CollaborationGroup WHERE Name = 'LWC Admin' LIMIT 1];
            for (String fspId : fspMap.keySet()) {
                feedItemList.add(LWCUtility.createChatterFeed_LoanRepayment(groups.Id, fspId, fspMap.get(fspId)));
            }
            
            if (!feedItemList.isEmpty()) {
                insert feedItemList;
                //    system.debug('feedItemList-->'+feedItemList);
            }
        }
    }
    
    @AuraEnabled
    public static Boolean isNumeric(String s) {
        try {
            Decimal.valueOf(s);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    public class RSModal1{
        @AuraEnabled
        public String srNo {get; set;}
        @AuraEnabled
        public Boolean isEditable {get; set;}
        @AuraEnabled
        public Boolean isSelected {get; set;}
        @AuraEnabled
        public Loan__c loan;
        @AuraEnabled
        public Repayment_Schedule__c rs;
        @AuraEnabled
        public String repaymentScheduleID { get; set; }
        @AuraEnabled
        public String careLoanID { get; set; }
        @AuraEnabled
        public String fspLoanID { get; set; }
        @AuraEnabled
        public String location { get; set; }
        @AuraEnabled
        public Decimal loanAmount { get; set; }
        @AuraEnabled
        public String loanCurrency { get; set; }
        @AuraEnabled
        public Decimal cumulativeAmountReceivedSoFar { get; set; }
        @AuraEnabled
        public Decimal totalExpectedIncLastMonth { get; set; }
        @AuraEnabled
        public Decimal lastMonthsExpectedRepayment { get; set; }
        @AuraEnabled
        public Decimal cumulativeAmountReceivedThisMonth { get; set; }
        @AuraEnabled
        public Boolean writeOffRequest { get; set; }
        @AuraEnabled
        public String nonPerformingOptions { get; set; }
        @AuraEnabled
        public String comment { get; set; }
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }
        @AuraEnabled
        public Boolean isValidDoc { get; set; }
    }
    public class RSModal {
        
        @AuraEnabled
        public Loan__c loan;
        @AuraEnabled
        public Repayment_Schedule__c rs;
        @AuraEnabled
        public String repaymentScheduleID { get; set; }
        @AuraEnabled
        public String careLoanID { get; set; }
        @AuraEnabled
        public String fspLoanID { get; set; }
        @AuraEnabled
        public String location { get; set; }
        @AuraEnabled
        public Decimal loanAmount { get; set; }
        @AuraEnabled
        public String loanCurrency { get; set; }
        @AuraEnabled
        public Decimal cumulativeAmountReceivedSoFar { get; set; }
        @AuraEnabled
        public Decimal totalExpectedIncLastMonth { get; set; }
        @AuraEnabled
        public Decimal lastMonthsExpectedRepayment { get; set; }
        @AuraEnabled
        public Decimal cumulativeAmountReceivedThisMonth { get; set; }
        @AuraEnabled
        public Boolean writeOffRequest { get; set; }
        @AuraEnabled
        public String nonPerformingOptions { get; set; }
        @AuraEnabled
        public String comment { get; set; }
        @AuraEnabled
        public String message { get; set; }
    }
    public  class RepaymentWrapper {
        @AuraEnabled
        public String srNo {get; set;}
        @AuraEnabled
        public Loan__c loan;
        @AuraEnabled
        public Repayment_Schedule__c rs;
        public String id;
        public String careLoanID;
        public String fspLoanID;
        public String location;
        public Decimal loanAmount;
        public String loanCurrency;
        public Decimal cumulativeAmountReceivedSoFar;
        public Decimal totalExpectedIncLastMonth;
        public Decimal lastMonthsExpectedRepayment;
        public Decimal cumulativeAmountReceivedThisMonth;
        public Boolean writeOffRequest;
        public String nonPerformingOptions;
        public String comment;
        public String message;
        
    }
    public  class RepaymentWrapperSuccess {
        @AuraEnabled
        public String repaymentId;
        @AuraEnabled
        public String errorMessage;
    }
}