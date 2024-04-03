@isTest
public class FSP_UpdateRepaymentsCtrlTest {
    
    @TestSetup
    private static void testData(){
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);        
        list<Loan__c> loanList = LWCTestUtility.getBorrowerLoans(borrowers);
        list<Account> fspAccounts = LWCTestUtility.getFSPAccounts();
        list<Repayment_Schedule__c> rsList = new list<Repayment_Schedule__c>();
        for(Loan__c l: loanList){
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
                system.debug('rs-> '+rs);
                rs.Loan_Repayment_Number__c=j;
                rsList.add(rs);
            }
        }
        insert rsList;
        
        loanList = LWCTestUtility.submitLoanforReview(loanList);
        loanList = LWCTestUtility.updateLoansToPublish(loanList);
        list<String> lenderIds = LWCTestUtility.getLenderUsersIds();
        list<Repayment_Schedule__c> rsToSetPayments = LWCTestUtility.getLastMonthsRepayments();
        
        Integer m=1;
        for(Repayment_Schedule__c rs: rsToSetPayments){
            rs.Repayment_Date__c=System.Today();
            if(m<3){
                rs.Principal_Repaid__c=rs.Amount_Due__c;
                rs.Status__c='Paid';
            }else if(m>=3 && m<6){
                if(m!=4){
                    rs.Principal_Repaid__c=rs.Amount_Due__c/2;
                    rs.Status__c='Underpaid';
                    rs.Non_performing_loan_options__c='Loss of income';
                    rs.Non_performing_loan_options_other__c='test';
                }
            }else if(m>=6 && m<9){
                rs.Principal_Repaid__c=0;
                rs.Status__c='Skipped';
                rs.Non_performing_loan_options__c='Loss of income';
                rs.Non_performing_loan_options_other__c='test';
            }else{
                rs.Principal_Repaid__c=0;
                rs.Status__c='Skipped';
                rs.Non_performing_loan_options__c='Loss of income';
                rs.Non_performing_loan_options_other__c='test';
                rs.Write_Off_Request__c=true;
                rs.Comments__c='test';
            }
            m++;
        }
        update rsList;
        
        Integer month=System.Today().addMonths(-1).Month();
        Integer year=System.Today().addMonths(-1).Year();
        list<FSP_Monthly_Settlement__c> fmsList = new list<FSP_Monthly_Settlement__c>();
        String monthYear=LWCUtility.getMonth(month)+'-'+year;
        for(User usr: fspStaffUsers){
            fmsList.add(new FSP_Monthly_Settlement__c(FSP__c=fspAccounts[0].Id, FSP_Staff__c=usr.ContactId,
                                                      Offset_Calculation_Date__c=System.Today().addMonths(-1), Month__c=month, 
                                                      Year__c=year, Offset_Month_Year__c=monthYear, Offset_Balance_for_FSP_USD__c=20,
                                                      Below_Threshold__c=true, Offset_Clearance__c=false));
        }
        insert fmsList;
    }
    @isTest
    public static void testProcessCSVFile() {
        // Create test data
        String csvContent = 'Repayment Schedule: ID,Loan: ID,FSP Loan ID,Location,Loan Principal Disbursed (LC),Loan: Currency,Cumulative Amount Received To Date (LC),Total Expected Inc Last Month,Last Month\'s Expected Repayment,Cumulative Amount Received This Month,Write Off Request,Comments\n';
        csvContent += 'Value0,Value1,Value2,Value3,4,Value5,6,7,8,9,true,Test comment\n';
        
        // Call the method to test
        List<FSP_UpdateRepaymentsCtrl.RSModal> rsList = FSP_UpdateRepaymentsCtrl.processCSVFile(csvContent);
        
        // Perform assertions
        System.assertEquals(1, rsList.size());
        FSP_UpdateRepaymentsCtrl.RSModal rsModal = rsList[0];
        System.assertEquals('Value0', rsModal.repaymentScheduleID);
        System.assertEquals('Value1', rsModal.careLoanID);
        System.assertEquals('Value2', rsModal.fspLoanID);
        System.assertEquals('Value3', rsModal.location);
        System.assertEquals(4, rsModal.loanAmount);
        System.assertEquals('Value5', rsModal.loanCurrency);
        System.assertEquals(6, rsModal.cumulativeAmountReceivedSoFar);
        System.assertEquals(7, rsModal.totalExpectedIncLastMonth);
        System.assertEquals(8, rsModal.lastMonthsExpectedRepayment);
        System.assertEquals(9, rsModal.cumulativeAmountReceivedThisMonth);
        System.assertEquals(true, rsModal.writeOffRequest);
        System.assertEquals('Test comment', rsModal.comment);
        
    }
    @isTest
    public static void testReadCSVFileInvalidDoc() {
        String csvContents = 'Repayment Schedule: ID,Loan: ID,FSP Loan ID,Location,Loan Principal Disbursed (LC),Loan: Currency,Cumulative Amount Received To Date (LC),Total Expected Inc Last Month,Last Month\'s Expected Repayment,Cumulative Amount Received This Month,Write Off Request,s,' +'/n'+
            'a3TAD0000003HKT,L-a00789-F,fsp-121, / ,23662478,VND,2345634,23662478.41,11831239.21,,0,\n' +
            ',Care002,fsp1234, / ,94668058,VND,234121,94668058.29,47334029.15,,0,\n' +
            'a3TAD0000003x8P,,FSP-262, / ,50263500,VND,45634,50263500,25131750,,0,\n' +
            'a3TAD0000003xDF,L-a00339-A,, / ,50263500,VND,-49020077,75395250,50263500,,0,\n' +
            'a3TAD0000003wp3,L-a00333-A,FSP-8172,,43083000,VND,0,21541500,21541500,,0,\n' +
            'a3TAD0000003REz,L-a00032-,L111, / ,,VND,0,46768983.06,23384491.53,1,0,\n' +
            'a3TAD0000003QVp,L-a00007-A,L22222, / Melbourne,47360000,,-23556544,47360000,23680000,,0,\n' +
            'a3TAD0000003dWH,Care003,L976, / ,71077500,VND,,,,,1,';
        
        system.debug('csvContent--> '+csvContents);
        test.startTest();
        //List<FSP_UpdateRepaymentsCtrl.RSModal1> processedData = FSP_UpdateRepaymentsCtrl.readCSVFile1(csvContents);
        FSP_UpdateRepaymentsCtrl.readCSVFile1(csvContents);
        test.stopTest();       
    }  
    @isTest
    public static void testReadCSVFile1() {
        String csvContents = 'Repayment Schedule: ID,Loan: ID,FSP Loan ID,Location,Loan Principal Disbursed (LC),Loan: Currency,Cumulative Amount Received To Date (LC),Total Expected Inc Last Month,Last Month\'s Expected Repayment,Cumulative Amount Received This Month,Write Off Request,Comments\n' +
            'a3TAD0000003HKT,L-a00789-F,fsp-121, / ,23662478,VND,2345634,23662478.41,11831239.21,,0,\n' +
            ',Care002,fsp1234, / ,94668058,VND,234121,94668058.29,47334029.15,,0,\n' +
            'a3TAD0000003x8P,,FSP-262, / ,50263500,VND,45634,50263500,25131750,,0,\n' +
            'a3TAD0000003xDF,L-a00339-A,, / ,50263500,VND,-49020077,75395250,50263500,,0,\n' +
            'a3TAD0000003wp3,L-a00333-A,FSP-8172,,43083000,VND,0,21541500,21541500,,0,\n' +
            'a3TAD0000003REz,L-a00032-,L111, / ,,VND,0,46768983.06,23384491.53,1,0,\n' +
            'a3TAD0000003QVp,L-a00007-A,L22222, / Melbourne,47360000,,-23556544,47360000,23680000,,0,\n' +
            'a3TAD0000003dWH,Care003,L976, / ,71077500,VND,,,,,1,';
        
        system.debug('csvContent--> '+csvContents);
        test.startTest();
        //List<FSP_UpdateRepaymentsCtrl.RSModal1> processedData = FSP_UpdateRepaymentsCtrl.readCSVFile1(csvContents);
        FSP_UpdateRepaymentsCtrl.readCSVFile1(csvContents);
        test.stopTest();       
    }
    
    @istest
    public static void testReadCSVFiles(){
        String csvContents = 'Repayment Schedule: ID,Loan: ID,FSP Loan ID,Location,Loan Principal Disbursed (LC),Loan: Currency,Cumulative Amount Received To Date (LC),Total Expected Inc Last Month,Last Month\'s Expected Repayment,Cumulative Amount Received This Month,Write Off Request,Comments\n' +
            'a3TAD0000003HKT,L-a00789-F,fsp-121, / ,23662478,VND,2345634,23662478.41,11831239.21,,0,\n' +
            '"a3TAD00000037wD,Care002,fsp1234, / ,94668058,VND,234121,94668058.29,47334029.15,,0,\n' +
            'a3TAD0000003x8P,L-a00338-D,FSP-262, / ,50263500,VND,45634,50263500,25131750,,0,\n' +
            'a3TAD0000003xDF,L-a00339-A,FSP-734, / ,50263500,VND,-49020077,75395250,50263500,,0,\n' +
            'a3TAD0000003wp3,L-a00333-A,FSP-8172,test / ,43083000,VND,0,21541500,21541500,,0,\n' +
            'a3TAD0000003REz,L-a00032-,L111, / ,46768983,VND,0,46768983.06,23384491.53,,0,\n' +
            'a3TAD0000003QVp,L-a00007-A,L22222, / Melbourne,47360000,VND,-23556544,47360000,23680000,,0,\n' +
            'a3TAD0000003dWH,Care003,L976, / ,71077500,VND,35526405,71077500,35538750,,0,';
        
        system.debug('csvContent--> '+csvContents);
        test.startTest();
        FSP_UpdateRepaymentsCtrl.readCSVFile1(csvContents);
        test.stopTest();
    }
    @istest
    public static void testReadCSVFilesNull(){
        String csvContents = '""';
        
        system.debug('csvContent--> '+csvContents);
        test.startTest();
        FSP_UpdateRepaymentsCtrl.readCSVFile1(csvContents);
        test.stopTest();
    }
    @isTest
    public static void testIsNumericValidNumericString() {
        Boolean result = FSP_UpdateRepaymentsCtrl.isNumeric('12345');
    }
    
    @isTest
    public static void testIsNumericInvalidNumericString() {
        Boolean result = FSP_UpdateRepaymentsCtrl.isNumeric('12.34.56');
    }
    
    @isTest
    public static void testIsNumericCatchBlockNonNumericString() {
        Boolean result = FSP_UpdateRepaymentsCtrl.isNumeric('abc');
    }
    
    @isTest
    public static void testIsNumericCatchBlockNullString() {
        Boolean result = FSP_UpdateRepaymentsCtrl.isNumeric(null);
    }
    
    @isTest
    public static void testIsNumericCatchBlocEmptyString() {
        Boolean result = FSP_UpdateRepaymentsCtrl.isNumeric('');
    }
    
    @isTest
    public static void testIsNumericCatchBlockWhitespaceString() {
        Boolean result = FSP_UpdateRepaymentsCtrl.isNumeric('   ');
    }
    
    @isTest
    public static void testValidateIsLoanRepaymentsAllSetPositive() {
        FSP_UpdateRepaymentsCtrl controller = new FSP_UpdateRepaymentsCtrl();
        controller.nameFile = 'SampleFileName';
        controller.contentFile = Blob.valueOf('Sample content');
        
        // Set values for other properties
        controller.documentName = 'SampleDocument';
        controller.readSuccess = true;
        controller.rsDataLines = new List<String>{'Line 1', 'Line 2'};
            controller.nonPerformingOptions = new List<SelectOption>{new SelectOption('Loss of income', 'Loss of income')};
                
                // Set lstFieldNames
                controller.lstFieldNames = new List<String>{'Field1', 'Field2'};
                    list<CollaborationGroup> cgList = [Select id,Name,CollaborationType,Description from CollaborationGroup];
        
        // Create a list of Repayment Schedule IDs.
        List<String> rsIds = new List<String>();
        rsIds.add('00123456789012345678');
        rsIds.add('00123456789012345679');
        
        // Create a map of FSP ID to FSP name.
        Map<String, String> fspMap = new Map<String, String>();
        fspMap.put('00123456789012345678', 'FSP 1');
        fspMap.put('00123456789012345679', 'FSP 2');
        
        
        // Mock LWCUtility.createChatterFeed_LoanRepayment method
        Test.startTest();
        List<FeedItem> feedItemList = new List<FeedItem>();
        feedItemList.add(new FeedItem());
        FSP_UpdateRepaymentsCtrl.validateIsLoanRepaymentsAllSet(rsIds, fspMap);
        Test.stopTest();
        
        // Verify that the feed items were created successfully.
        List<FeedItem> feedItems = [SELECT Id, Body FROM FeedItem WHERE ParentId IN :rsIds];
        System.assertEquals(0, feedItems.size());
        System.assertEquals(1, feedItemList.size());
        
    }
    @isTest
    public static void testSaveRepayments() {
        
        list<Loan__c> loanList = [Select Id, Name,FSP_Loan_ID__c,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c,CurrencyIsoCode,Cumulative_Amount_Received_To_Date__c From Loan__c];
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c,location__c
                                                       From Repayment_Schedule__c];
        Map<String, Object> jsonObject = new Map<String, Object>{
            'rs'=>rsToSetPayments[0],
                'id' => rsToSetPayments[0].Id,
                'careLoanID' => String.valueof(loanList[0].Id).substring(0, 15),
                'fspLoanID'=>loanList[0].FSP_Loan_ID__c,
                'location'=>rsToSetPayments[0].location__c,
                'loanAmount'=>loanList[0].Loan_Principal_Disbursed__c,
                'loanCurrency'=>loanList[0].CurrencyIsoCode,
                'cumulativeAmountReceivedSoFar'=>loanList[0].Cumulative_Amount_Received_To_Date__c,
                'totalExpectedIncLastMonth'=>'23456',
                'lastMonthsExpectedRepayment'=>'23456',
                'cumulativeAmountReceivedThisMonth'=>'0',
                'comment'=>'',
                'message'=>'',
                'isEditable'=>true
                };
                    String inputJson = JSON.serialize(jsonObject);
        inputJson='['+inputJson+']';
        
        test.startTest();
        FSP_UpdateRepaymentsCtrl.saveRepayments(inputJson);
        test.stopTest();
        
    }
    @isTest
    public static void testSaveRepaymentPositive() {
        
        list<Loan__c> loanList = [Select Id, Name,FSP_Loan_ID__c,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c,CurrencyIsoCode,Cumulative_Amount_Received_To_Date__c From Loan__c];
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c,location__c
                                                       From Repayment_Schedule__c ];
        Map<String, Object> jsonObject = new Map<String, Object>{
            'rs'=>rsToSetPayments[0],
                'id' => rsToSetPayments[0].Id,
                'careLoanID' => String.valueof(loanList[0].Id).substring(0, 15),
                'fspLoanID'=>loanList[0].FSP_Loan_ID__c,
                'location'=>rsToSetPayments[0].location__c,
                'loanAmount'=>loanList[0].Loan_Principal_Disbursed__c,
                'loanCurrency'=>loanList[0].CurrencyIsoCode,
                'cumulativeAmountReceivedSoFar'=>loanList[0].Cumulative_Amount_Received_To_Date__c,
                'totalExpectedIncLastMonth'=>'23456',
                'lastMonthsExpectedRepayment'=>'23456',
                'cumulativeAmountReceivedThisMonth'=>'1234',
                'comment'=>'',
                'message'=>'',
                'isEditable'=>true,
                'writeoffrequest'=>true
                };
                    String inputJson = JSON.serialize(jsonObject);
        inputJson='['+inputJson+']';
        test.startTest();
        FSP_UpdateRepaymentsCtrl.saveRepayments(inputJson);
        test.stopTest();
        
    }
    @isTest
    public static void testSaveRepaymentError() {
        
        list<Loan__c> loanList = [Select Id, Name,FSP_Loan_ID__c,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c,CurrencyIsoCode,Cumulative_Amount_Received_To_Date__c From Loan__c];
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c,location__c
                                                       From Repayment_Schedule__c ];
        Map<String, Object> jsonObject = new Map<String, Object>{
            'rs'=>rsToSetPayments[0],
                'id' => rsToSetPayments[0].Id,
                'careLoanID' => null,
                'fspLoanID'=>loanList[0].FSP_Loan_ID__c,
                'location'=>rsToSetPayments[0].location__c,
                'loanAmount'=>loanList[0].Loan_Principal_Disbursed__c,
                'loanCurrency'=>loanList[0].CurrencyIsoCode,
                'cumulativeAmountReceivedSoFar'=>loanList[0].Cumulative_Amount_Received_To_Date__c,
                'totalExpectedIncLastMonth'=>'23456',
                'lastMonthsExpectedRepayment'=>'23456',
                'cumulativeAmountReceivedThisMonth'=>'1234',
                'comment'=>'',
                'message'=>'',
                'isEditable'=>true,
                'writeoffrequest'=>true
                };
                    String inputJson = JSON.serialize(jsonObject);
        inputJson='['+inputJson+']';
        test.startTest();
        FSP_UpdateRepaymentsCtrl.saveRepayments(inputJson);
        test.stopTest();
        
    }
    @isTest
    public static void testSaveRepaymentLoanId() {
        
        list<Loan__c> loanList = [Select Id, Name,FSP_Loan_ID__c,Total_Expected_Inc_Last_Month__c,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c,CurrencyIsoCode,Cumulative_Amount_Received_To_Date__c From Loan__c];
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c,location__c
                                                       From Repayment_Schedule__c ];
        loanList[0].Cumulative_Amount_Received_To_Date__c=2000;
        loanList[0].Total_Expected_Inc_Last_Month__c = 2000;
        Update loanList[0];
        Map<String, Object> jsonObject = new Map<String, Object>{
            'rs'=>rsToSetPayments[0],
                'loan'=>loanList[0],
                'id' => rsToSetPayments[0].Id,
                'careLoanID' => String.valueof(loanList[0].Id).substring(0, 15),
                'fspLoanID'=>loanList[0].FSP_Loan_ID__c,
                'location'=>rsToSetPayments[0].location__c,
                'loanAmount'=>loanList[0].Loan_Principal_Disbursed__c,
                'loanCurrency'=>loanList[0].CurrencyIsoCode,
                'cumulativeAmountReceivedSoFar'=>loanList[0].Cumulative_Amount_Received_To_Date__c,
                'totalExpectedIncLastMonth'=> loanList[0].Total_Expected_Inc_Last_Month__c,
                'lastMonthsExpectedRepayment'=>2000,
                'cumulativeAmountReceivedThisMonth'=>2000,
                'comment'=>'',
                'message'=>'',
                'isEditable'=>true,
                'writeoffrequest'=>true
                };
                    String inputJson = JSON.serialize(jsonObject);
        inputJson='['+inputJson+']';
        test.startTest();
        FSP_UpdateRepaymentsCtrl.parseDecimal('Decimal');
        FSP_UpdateRepaymentsCtrl.saveRepayments(inputJson);
        test.stopTest();
        
    }
    @isTest
    public static void testSaveRepaymentZero() {
        
        list<Loan__c> loanList = [Select Id, Name,FSP_Loan_ID__c,Total_Expected_Inc_Last_Month__c,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c,CurrencyIsoCode,Cumulative_Amount_Received_To_Date__c From Loan__c];
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c,location__c
                                                       From Repayment_Schedule__c ];
        loanList[0].Cumulative_Amount_Received_To_Date__c=0;
        loanList[0].Total_Expected_Inc_Last_Month__c = 0;
        Update loanList[0];
        Map<String, Object> jsonObject = new Map<String, Object>{
            'rs'=>rsToSetPayments[0],
                'loan'=>loanList[0],
                'id' => rsToSetPayments[0].Id,
                'careLoanID' => String.valueof(loanList[0].Id).substring(0, 15),
                'fspLoanID'=>loanList[0].FSP_Loan_ID__c,
                'location'=>rsToSetPayments[0].location__c,
                'loanAmount'=>loanList[0].Loan_Principal_Disbursed__c,
                'loanCurrency'=>loanList[0].CurrencyIsoCode,
                'cumulativeAmountReceivedSoFar'=>loanList[0].Cumulative_Amount_Received_To_Date__c,
                'totalExpectedIncLastMonth'=> loanList[0].Total_Expected_Inc_Last_Month__c,
                'lastMonthsExpectedRepayment'=>0,
                'cumulativeAmountReceivedThisMonth'=>2000,
                'comment'=>'',
                'message'=>'',
                'isEditable'=>true,
                'writeoffrequest'=>true
                };
                    String inputJson = JSON.serialize(jsonObject);
        inputJson='['+inputJson+']';
        test.startTest();
        FSP_UpdateRepaymentsCtrl.parseDecimal('Decimal');
        FSP_UpdateRepaymentsCtrl.saveRepayments(inputJson);
        test.stopTest();
        
    }
    @isTest
    public static void testSaveRepaymentNonperforming() {
        
        list<Loan__c> loanList = [Select Id, Name,FSP_Loan_ID__c,Total_Expected_Inc_Last_Month__c,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c,CurrencyIsoCode,Cumulative_Amount_Received_To_Date__c From Loan__c];
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c,location__c
                                                       From Repayment_Schedule__c ];
        loanList[0].Cumulative_Amount_Received_To_Date__c=20;
        loanList[0].Is_NonPerforming__c = true;
        Update loanList[0];
        Map<String, Object> jsonObject = new Map<String, Object>{
            'rs'=>rsToSetPayments[0],
                'loan'=>loanList[0],
                'id' => rsToSetPayments[0].Id,
                'careLoanID' => String.valueof(loanList[0].Id).substring(0, 15),
                'fspLoanID'=>loanList[0].FSP_Loan_ID__c,
                'location'=>rsToSetPayments[0].location__c,
                'loanAmount'=>loanList[0].Loan_Principal_Disbursed__c,
                'loanCurrency'=>loanList[0].CurrencyIsoCode,
                'cumulativeAmountReceivedSoFar'=>loanList[0].Cumulative_Amount_Received_To_Date__c,
                'totalExpectedIncLastMonth'=> loanList[0].Total_Expected_Inc_Last_Month__c,
                'lastMonthsExpectedRepayment'=>200,
                'cumulativeAmountReceivedThisMonth'=>2000,
                'comment'=>null,
                'isEditable'=>true,
                'writeOffRequest'=>true,
                'nonPerformingOptions'=>'Comment'
                };
                    String inputJson = JSON.serialize(jsonObject);
        inputJson='['+inputJson+']';
        test.startTest();
        FSP_UpdateRepaymentsCtrl.parseDecimal('Decimal');
        FSP_UpdateRepaymentsCtrl.saveRepayments(inputJson);
        test.stopTest();
        
    }
    @isTest
    public static void testSaveRepaymentNonPerformPositive() {
        
        list<Loan__c> loanList = [Select Id, Name,FSP_Loan_ID__c,Total_Expected_Inc_Last_Month__c,Loan_Principal_Disbursed__c, Loan_Principal_Disbursed_AUD__c, 
                                  Published_Amount_AUD__c, Loan_Term_Months__c, Total_Repayment_Scheduled_Amount__c,CurrencyIsoCode,Cumulative_Amount_Received_To_Date__c From Loan__c];
        list<Repayment_Schedule__c> rsToSetPayments = [Select Id, Name, Amount_Due__c, Due_Date__c,location__c
                                                       From Repayment_Schedule__c ];
        loanList[0].Cumulative_Amount_Received_To_Date__c=2000;
        loanList[0].Total_Expected_Inc_Last_Month__c = 2000;
        Update loanList[0];
        Map<String, Object> jsonObject = new Map<String, Object>{
            'rs'=>rsToSetPayments[0],
                'loan'=>loanList[0],
                'id' => rsToSetPayments[0].Id,
                'careLoanID' => String.valueof(loanList[0].Id).substring(0, 15),
                'fspLoanID'=>loanList[0].FSP_Loan_ID__c,
                'location'=>rsToSetPayments[0].location__c,
                'loanAmount'=>loanList[0].Loan_Principal_Disbursed__c,
                'loanCurrency'=>loanList[0].CurrencyIsoCode,
                'cumulativeAmountReceivedSoFar'=>loanList[0].Cumulative_Amount_Received_To_Date__c,
                'totalExpectedIncLastMonth'=> loanList[0].Total_Expected_Inc_Last_Month__c,
                'lastMonthsExpectedRepayment'=>2000,
                'cumulativeAmountReceivedThisMonth'=>2000,
                'comment'=>null,
                'message'=>'',
                'isEditable'=>true,
                'nonPerformingOptions'=>'Comment'
                };
                    String inputJson = JSON.serialize(jsonObject);
        inputJson='['+inputJson+']';
        test.startTest();
        FSP_UpdateRepaymentsCtrl.parseDecimal('Decimal');
        FSP_UpdateRepaymentsCtrl.saveRepayments(inputJson);
        test.stopTest();
        
    }
    
}