/**
* Name          :       LWCUtility
* Date          :       14/07/2023
* Author        :       Amit Goyal
* Description   :       all utility methods will be here
*/

public class LWCUtility {
    /*public static void getCurrencyConversionXE(){
        String apiKey = 'lggan0to6h7m8lh6upa6nqi8jh';
        String endpoint = 'https://xecdapi.xe.com/v1/convert_from.json';
        String fromCurrency = 'AUD';
        String toCurrency = 'VND,USD';
        Decimal amount = 1.0;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        String queryString = 'from=' + EncodingUtil.urlEncode(fromCurrency, 'UTF-8') +
                             '&to=' + EncodingUtil.urlEncode(toCurrency, 'UTF-8') +
                             '&amount=' + String.valueOf(amount);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            // Handle the response here
            String responseBody = response.getBody();
            System.debug('### Response: ' + responseBody);
        } else {
            System.debug('API callout failed with status code: ' + response.getStatusCode());
        }
    }*/
    public static String getFSPRecordTypeId(){
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get('FSP').getRecordTypeId();
    }
    
    public static String getCustomerRecordTypeId(){
        return Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Supporter').getRecordTypeId();
    }
    
    public static String getFSPStaffRecordTypeId(){
        return Schema.SObjectType.Contact.getRecordTypeInfosByName().get('FSP Staff').getRecordTypeId();
    }
    
    public static String getBorrowerRecordTypeId(){
        return Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Borrower').getRecordTypeId();
    }
    
    public static String getKYCRecordTypeId(){
        return Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
    }
    
    
    public static String getFSPBorrowerRecordTypeId(){
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get('FSP (Borrower)').getRecordTypeId();
    }
    
    public static Transaction__c getLenderTransaction(Contact lenderRec, String loanType, Decimal amount, String loanId, String status)
    {
        return new Transaction__c(Lender__c=lenderRec.Id, Type__c=loanType, Amount__c=amount, 
                                  Transaction_Date__c=System.Now(), Status__c=status, Completed_Date__c=System.Now(), 
                                  CurrencyIsoCode=lenderRec.CurrencyISOCode, Loan__c=loanId,Allow_Deletion__c=true);
    }
    
    
    public static list<Contact> getAllActiveLenders(){
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        Id customerRTId = getCustomerRecordTypeId();
        return [Select Id, Name, Lender_Balance__c, CurrencyISOCode, AccountId 
                From Contact 
                Where RecordTypeId=:customerRTId 
                AND IsLender__c=true];
        //AND (Id IN (SELECT ContactId FROM User WHERE Profile.Name = 'Lender') 
        //OR Name =: lwcGlobalSettings.FX_Gain_Lender__c
        //OR Name =: lwcGlobalSettings.LWC_GuestLender__c)
    }
    
    public static list<Contact> getAllActiveFSPs(){
        Id fspStaffRTId = getFSPStaffRecordTypeId();
        return [Select Id, Lender_Balance__c, CurrencyISOCode, AccountId 
                From Contact Where RecordTypeId=:fspStaffRTId];
        //AND Id IN (SELECT ContactId FROM User WHERE Profile.Name = 'FSP Staff')
    }
    
    public static list<Contact> getLenderContacts(set<String> lenderIds){
        Id customerRTId = getCustomerRecordTypeId();
        return [Select Id, Name, Lender_Balance__c, CurrencyISOCode
                From Contact Where Id IN: lenderIds 
                AND RecordTypeId=:customerRTId 
                AND IsLender__c=true];
    }
    
     public static Map<String,boolean> AMLCheck(Map<String, list<Repayment_Schedule__c>> loanRepaymentsMap,List<String> LenderIds)
    {
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        Date firstDayOfLastMonth = Date.newInstance(year, month, 1);     
        // Get the last day of the current month
        System.debug('Loan Repayments from Utility-->'+ loanRepaymentsMap);
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        Map<String,Decimal> curr_map=LWCUtilityFX.getCurrencyConversionMap();
        Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        Date midDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 15);
        Integer lastDayOfThisMonth = Date.daysInMonth(System.today().year(), System.today().month());
        Date lastDayDateOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), lastDayOfThisMonth);
        List<String> loanIds=new List<String>();
        Group CaseGroup =[SELECT Id, Name, Type FROM Group WHERE Type='Queue' AND Name='LWC Admin' LIMIT 1] ;
        Map<String,boolean> contwithAML=new Map<String,boolean>();
        Id customerRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Supporter').getRecordTypeId();             
            map<String, Contact> contactsMap = new map<String, Contact>([Select Id, Name, CurrencyISOCode, Lender_Balance__c,KYC_Required__c,
                                                                         (Select Id, Name, Loan__c,Status__c,Type__c,Transaction_Date__c,
                                                                          Amount__c From Transactions__r 
                                                                          Where (Status__c='Completed' AND Type__c='Loan') 
                                                                          OR (Status__c=:lwcGlobalSettings.LWC_AML_Transaction_Status__c AND (Type__c='Repayment' OR Type__c='Expired Loan')))
                                                                         From Contact Where RecordTypeId =: customerRTId 
                                                                         AND IsLender__c=true AND Id IN:lenderIds]);
            map<String, List<String>> lenderLoansMap = new map<String, List<String>>();
            System.debug('Contacts map from Utility-->'+contactsMap);
            map<String, Decimal> repaymentLoansMap = new map<String, Decimal>();
            map<String, Decimal> lendLoanMap = new map<String, Decimal>();
            if(contactsMap != null && contactsMap.size()>0)
            {
                for(String lenderId: contactsMap.keySet())
                {
                    Decimal repayment_amt=0.0;
                    Decimal lendl_amt=0.0;
                    if(contactsMap.get(lenderId).Transactions__r != null && contactsMap.get(lenderId).Transactions__r.size()>0){
                        System.debug('Contact transactions-->'+contactsMap.get(lenderId).Transactions__r);
                        for(Transaction__c trans: contactsMap.get(lenderId).Transactions__r)
                        {
                            System.debug('Transaction type-->'+trans.Id+'//////'+trans.Type__c);
                            // collecting contributed loans for lender
                            if(trans.Type__c=='Loan')
                            {
                                String lendloan=lenderId+'~'+trans.Loan__c;
                                lendl_amt+=trans.Amount__c;
                                lendLoanMap.put(lendloan,lendl_amt);
                                loanIds.add(trans.Loan__c);
                                
                                List<String> result = lenderLoansMap.get(lenderId);
                                if(result==null)
                                {
                                    result = new List<String>();
                                }
                                result.add(trans.Loan__c);
                                lenderLoansMap.put(lenderId, result);
                            }
                            
                            if(trans.Type__c=='Repayment'||trans.Type__c=='Expired Loan')
                            {   
                                repayment_amt+=trans.Amount__c;
                                repaymentLoansMap.put(lenderId,repayment_amt);
                            }
                        }
                    }
                }
            }
        	System.debug('Lend Loan Map-->'+lendLoanMap);
            Map<String,Loan__c> loanMap=new Map<String,Loan__c>([SELECT Id, Name,Actual_Loan_Principle_Disbursed_AUD__c,Published_Amount_AUD__c FROM Loan__c WHERE Id In :loanIds]);
            Map<String,Double> lenderAmt=new Map<String,Double>();
        	List<Case> addCases=new List<Case>();
            if((lendLoanMap!=null)&&(lendLoanMap.size()>0))
            {
                 for(String llId: lendLoanMap.keySet())
                {
                    Decimal fractional_repayment=0.0;
                    String LenderId=llId.substringBefore('~');
                    String LoanId=llId.substringAfter('~');
                    Double loanProportion=0.0;
                    
                    if(loanMap.get(LoanId).Actual_Loan_Principle_Disbursed_AUD__c==null)
                    	 loanProportion= lendLoanMap.get(llId)/ loanMap.get(LoanId).Published_Amount_AUD__c;
                    else
                         loanProportion= lendLoanMap.get(llId)/ loanMap.get(LoanId).Actual_Loan_Principle_Disbursed_AUD__c;
                    System.debug('lendLoanMap get-->'+lendLoanMap.get(llId));
                    System.debug('loanproportion-->'+loanProportion);
                 	System.debug('Fractional repayment id-->'+llId);
                    List<Repayment_Schedule__c> listrs=loanRepaymentsMap.get(LoanId);
                    System.debug('list rs-->'+listrs);
                    if(listrs != null && listrs.size()>0)
                    {
                        for(Repayment_Schedule__c r: listrs)
                        {
                            fractional_repayment+=loanProportion*LWCUtilityFX.conversionfromLCtoAUD(r.Amount_Due__c,'VND',curr_map);
                              if(lenderAmt.get(LenderId)==null)
                                    lenderAmt.put(LenderId,fractional_repayment);
                             else
                                {
                                Decimal prev_calc=lenderAmt.get(LenderId);
                                lenderAmt.put(LenderId,prev_calc+fractional_repayment);
                                }
                        }   
                        System.debug('Lender fractional repayment now--->'+lenderAmt.get(LenderId));
                    }       
                   
                    
                }
    
            }
            
            if(lenderAmt != null && lenderAmt.size()>0)
            {
                    
                    for(String lender: contactsMap.keySet())
                    {
                            Decimal addAmount=0.0;
                            if((lenderAmt.get(lender)!=null)||(repaymentLoansMap.get(lender)!=null)||(contactsMap.get(lender)!=null))
                            {
                                if(lenderAmt.get(lender)!=null)
                                    addAmount+=lenderAmt.get(lender);
                                if(repaymentLoansMap.get(lender)!=null)
                                    addAmount+=repaymentLoansMap.get(lender);
                                if(contactsMap.get(lender)!=null)
                                    addAmount+=contactsMap.get(lender).Lender_Balance__c;
                                System.debug(lender+'~~~'+addAmount);
                                if((addAmount>=5000)&&(contactsMap.get(lender).KYC_Required__c!=true))
                                {
                                    contwithAML.put(lender,true);
                                   Case c=new Case(OwnerId = CaseGroup.Id,ContactId=lender,RecordTypeId=LWCUtility.getKYCRecordTypeId(),Description=' Credit Limit exceeded and AML is required',
                                                  Due_Date__c=Date.Today().addDays(10),Priority='High',Status='New');
                                    System.debug('case creating-->'+c);
                                    addCases.add(c);
                                    
                                }
                                else
                                    contwithAML.put(lender,false);
                                
                                
                            }
                    }          
            }
        
        
        if((addCases.size()>0)&&(addCases!=null))
        {
            System.debug('Creating the cases'+addCases);
            insert addCases;
        }
        return contwithAML;  
    }


    
    public static FeedItem createChatterFeed_LoanRepayment(String groupId, String fspId, String fspName){
        FeedItem post = new FeedItem(ParentId=groupId, Type = 'LinkPost');
        post.Body = 'All Loan Repayment has  been set for ' + fspName;
        post.Title = 'All Loan Repayment Set for ' + fspName;
        post.LinkUrl = '/lightning/r/Contact/' + fspId + '/view';
        return post;
    }
    
    public static FeedItem createChatterFeed_LoanRejection(String fspId, String loanId){
        FeedItem post = new FeedItem();
        post.ParentId = loanId;
        post.Status='Published';
        post.Visibility='AllUsers';
        post.Type = 'TextPost';
        post.Body = 'Loan has been rejected, please check and resubmit.';
        post.Title = 'Rejected';
        return post;
    }
    
    public static void sendEmailTemplate(List<String> userIds){
        
    }
    
    public static void sendEmailToUsers(set<String> userIds){
        list<String> emailIds = new list<String>();
        list<User> users = [Select Id, Name, Email From User Where Id IN: userIds];
        for(User usr: users){
            emailIds.add(usr.Email);
        } 
        String emailBody='Hello, <br /><br />This is to inform you that Finance team has not set the funded loans yet for the '+System.Today().addMonths(-1).Month()+' '+System.Today().addMonths(-1).Year()+'.<br /><br /> Please set the loans and process th Offset Calculation manually.';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Finance team has not set the funded loans yet');
        mail.setToAddresses(emailIds);
        mail.setHTMLBody(emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
    
    
    
    public static void sendMoneyIncomingMailToUsers(List<String> userIds){
        list<String> emailIds = new list<String>();
        list<User> users = [Select Id, Name, Email From User Where Id IN: userIds];
        for(User usr: users){
            emailIds.add(usr.Email);
        }
        
        String emailBody='Hello, <br /><br />This is to inform you that your money is incoming .<br />';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Money Incoming');
        mail.setToAddresses(emailIds);
        mail.setHTMLBody(emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
    
    
    
    public static void sendMoneyHeldEmailToUsers(List<String> userIds){
        list<String> emailIds = new list<String>();
        list<User> users = [Select Id, Name, Email From User Where Id IN: userIds];
        for(User usr: users){
            emailIds.add(usr.Email);
        }
        
        String emailBody='Hello, <br /><br />This is to inform you that your repayment is held .<br />';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Repayment Held');
        mail.setToAddresses(emailIds);
        mail.setHTMLBody(emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
    
    // to run the offset calculation manually, need to call this method on click of a button from the LWC Settings page
    public static void executeOffsetCalculationManually(){
        LWC_CalculateFSPBalance_8EMScheduler ctrl = new LWC_CalculateFSPBalance_8EMScheduler();
        ctrl.execute(null);
    }
    
    // to run the fx rate updates manually, need to call this method on click of a button from the LWC Settings page
    public static void updateFXRatesManually(){
        /* LWC_UpdateConversionRateScheduler ctrl = new LWC_UpdateConversionRateScheduler();
        ctrl.execute(null); */
        Set<string> c = new Set<string>();
        for( CurrencyType cType : [SELECT Id, IsoCode, IsCorporate FROM CurrencyType WHERE IsCorporate = false] ){
            c.add(cType.IsoCode);
        }
        if( !c.isEmpty() ){
            integer m = 5;
            for( String s : c ){
                LWC_UpdateConversionRateScheduler sch = new LWC_UpdateConversionRateScheduler(s);
                Datetime dt = Datetime.now().addMinutes(m);  
                String schCronExp = dt.format('s m H d M \'?\' yyyy');
                System.Schedule('Scheduling currency '+s+' '+dt,schCronExp,sch);
                m+=5;
            }
        }
    }

    // to run the fx rate updates automatically
    public static void updateFXRates(){
        Set<string> c = new Set<string>();
        for( CurrencyType cType : [SELECT Id, IsoCode, IsCorporate FROM CurrencyType WHERE IsCorporate = false] ){
            c.add(cType.IsoCode);
        }
        if( !c.isEmpty() ){
            integer m = 30;
            for( String s : c ){
                LWC_UpdateConversionRateScheduler sch = new LWC_UpdateConversionRateScheduler(s);
                String schCronExp = '0 '+m+' 5 * * ? *';
                System.Schedule('Scheduling currency '+s+' '+m,schCronExp,sch);
                m+=5;
            }
        }
    }
    // to run the LWC_LastLoginScheduler daily at 6 AM
    public static void runLWCLastLoginScheduler(){
        LWC_LastLoginScheduler sch = new LWC_LastLoginScheduler();
        String schCronExp = '0 0 6 1/1 * ? *';
        System.Schedule('Last Login',schCronExp,sch);
    }
    public static boolean checkIfLoanReviewerIsManager(String reviewerId){
        list<GroupMember> gmList = [Select UserOrGroupId From GroupMember where Group.Type='Queue' AND Group.Name = 'Care Loan Managers' AND UserOrGroupId=:reviewerId];
        if(gmList != null && gmList.size()>0){
            return true;
        }
        return false;
    }
    
    public static set<String> getLWCAdminUsers(){
        set<String> userIds = new set<String>();
        list<GroupMember> gmList = [Select UserOrGroupId From GroupMember where Group.Type='Queue' AND Group.Name = 'LWC Admin'];
        for (GroupMember gm : gmList) {
            if (String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                userIds.add(gm.UserOrGroupId);
            }
        }
        return userIds;
    }
    
    public static set<String> getFinanceTeamUsers(){
        set<String> userIds = new set<String>();
        list<GroupMember> gmList = [Select UserOrGroupId From GroupMember where Group.Type='Queue' AND Group.Name = 'Finance Team'];
        for (GroupMember gm : gmList) {
            if (String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                userIds.add(gm.UserOrGroupId);
            }
        }
        return userIds;
    }
    
    @AuraEnabled(cacheable=true)
    public static User getCommunityUser() {
        return [SELECT Id, Name, ContactId, Contact.Name, Contact.Email FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    public static String getMonth(Integer index){
        String month = '';
        if(index == 1 ){
            month = 'Jan';
        }
        else if(index == 2){
            month = 'Feb';
        }
        else if(index == 3){
            month = 'March';
        }
        else if(index == 4){
            month = 'April';
        }
        else if(index == 5){
            month = 'May';
        }
        else if(index == 6){
            month = 'June';
        }
        else if(index == 7){
            month = 'July';
        }
        else if(index == 8){
            month = 'Aug';
        }
        else if(index == 9){
            month = 'Sep';
        }
        else if(index == 10){
            month = 'Oct';
        }
        else if(index == 11){
            month = 'Nov';
        }
        else if(index == 12){
            month = 'Dec';
        }
        return month;
    }
    
    public static Integer getMonth(String index){
        Integer month = null;
        if(index == 'Jan' ){
            month = 1;
        }
        else if(index == 'Feb'){
            month = 2;
        }
        else if(index == 'March'){
            month = 3;
        }
        else if(index == 'April'){
            month = 4;
        }
        else if(index == 'May'){
            month = 5;
        }
        else if(index == 'June'){
            month = 6;
        }
        else if(index == 'July'){
            month = 7;
        }
        else if(index == 'Aug'){
            month = 8;
        }
        else if(index == 'Sep'){
            month = 9;
        }
        else if(index == 'Oct'){
            month = 10;
        }
        else if(index == 'Nov'){
            month = 11;
        }
        else if(index == 'Dec'){
            month = 12;
        }
        return month;
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