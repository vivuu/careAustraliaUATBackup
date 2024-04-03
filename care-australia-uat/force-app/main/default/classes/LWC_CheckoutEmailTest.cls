@isTest
public class LWC_CheckoutEmailTest {
    @TestSetup
    private static void testData(){
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        list<Campaign> parentCampaignList = new list<Campaign>();
        parentCampaignList.add(new Campaign(Name='Donation', IsActive=true, Campaign_Code__c=lwcGlobalSettings.Campaign_GeneralDonation__c));
        parentCampaignList.add(new Campaign(Name='LenderBalance', IsActive=true, Campaign_Code__c=lwcGlobalSettings.Campaign_BalanceDonation__c));
        parentCampaignList.add(new Campaign(Name='AutoRelend', IsActive=true, Campaign_Code__c=lwcGlobalSettings.Campaign_AutoRelendDonation__c));
        insert parentCampaignList;
        
        String customerRTId=LWCUtility.getCustomerRecordTypeId();
        Contact fxGain = new Contact(RecordTypeId=customerRTId, FirstName='LWC FX', LastName = 'Lender', IsLender__c=true);
        insert fxGain;
        list<CollaborationGroup> cgList = LWCTestUtility.createCollaborationGroups(true);
        list<User> fspStaffUsers = LWCTestUtility.getFSPStaffUsers();
        list<Contact> borrowers = LWCTestUtility.getBorrowerRecords(fspStaffUsers);
        Account fspAccount = LWCTestUtility.getFSPAccountRecord();
        Loan__c oldLoan = new Loan__c(Borrower__c=borrowers[0].Id, FSP__c=fspAccount.Id, FSP_Name__c=borrowers[0].FSP_Name__c, FSP_Loan_ID__c='L-'+borrowers[0].FSP_Client_ID__c+'X', 
                                      Loan_Term_Months__c=3, Loan_Disbursement_Date__c=System.Today().addDays(-89), 
                                      Loan_Principal_Disbursed__c=24000000, Loan_Schedule__c='Monthly', CurrencyISOCode='VND', 
                                      Consent_Provided__c=true, Number_of_Employees__c=1, Jobs_Created__c=1, Female_Employees_Count__c=1,
                                      Loan_Purpose__c='Farming', CA_Themes__c='Climate Mitigation', Loan_Type__c='Farming', 
                                      Loan_Title__c='Help Farmer to grow', Loan_Description__c='So and So farmer need help in farming',
                                      Loan_Proposal_Status__c='Published', Stage__c='Active', Funded_Date__C=System.Today().addMonths(-2));
        insert oldLoan;
        
        list<Repayment_Schedule__c> oldrsList = new list<Repayment_Schedule__c>();
        Decimal amount1 = oldLoan.Loan_Principal_Disbursed__c/oldLoan.Loan_Term_Months__c;
        for(Integer j=1; j<=oldLoan.Loan_Term_Months__c; j++){
            Date dt = System.Today();
            if(j==1){
                dt=dt.addDays(-58);
            }else if(j==2){
                dt=dt.addDays(-28);
            }else{
                dt=dt.addDays(2);
            }
            Repayment_Schedule__c rs = LWCTestUtility.getRepaymentRecord(oldLoan.Id, amount1, dt);
            system.debug('rs-> '+rs);
            rs.Loan_Repayment_Number__c=j;
            oldrsList.add(rs);
        }
        insert oldrsList;
        
        
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
        
        for(Loan__c l: loanList){
            l.Loan_Proposal_Status__c='Published';
            l.Stage__c='Fundraising';
            l.Funded_Date__C=System.Today().addMonths(-2);
        }
        update loanList;
        
    }
    
    public static testmethod void testsendCheckoutEmail(){
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        List<Loan__c> loanList = [select id from Loan__c Where Stage__c='Fundraising' limit 10];
        map<String, Contact> contactsMap = new  map<String, Contact>(LWCTestUtility.getLenderContacts());
        for(Contact con: contactsMap.values()){
            con.Email='test@test.com';
            contactsMap.put(con.Id, con);
        }
        update contactsMap.values();
        
        system.debug('lenderContacts '+contactsMap.size());
        map<String, Lender_Balance__c> lenderBalanceMap = LWCTestUtility.getLenderBalances(contactsMap.values());
        system.debug('lenderBalanceMap--> '+lenderBalanceMap);
        List<Transaction__c> tranList = new List<Transaction__c>();
        tranList.add(new Transaction__c(Amount__c = 25, Added_To_Cart__c=true, Lender_Email__c='test@test.com', Type__c = 'Loan', Loan__c = loanList[0].id, status__c = 'Held', Lender__c = contactsMap.values()[0].Id, Transaction_Date__c=System.Now()));
        tranList.add(new Transaction__c(Amount__c = 100, Added_To_Cart__c=true, Type__c = 'Topup', status__c = 'Held', Lender__c = contactsMap.values()[0].Id, Transaction_Date__c=System.Now()));
        insert tranList;
        
        String stdPriceBookId='';
        if(Test.isRunningTest()) {
            stdPriceBookId = Test.getStandardPricebookId();
        } else {
            stdPriceBookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        }
        
        map<String, Transaction__c> oppTransactionMap = new map<String, Transaction__c>();
        list<Opportunity> oppList = new list<Opportunity>();
        String oppDonationRTId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        Campaign donationCampaign = [SELECT Id FROM Campaign WHERE Campaign_Code__c =: lwcGlobalSettings.Campaign_GeneralDonation__c LIMIT 1];
        for(Transaction__c trans: tranList){
            Contact lenderContact = contactsMap.get(trans.Lender__c);
            String oppName=lenderContact.Name + ' $' + trans.Amount__c;
            oppList.add(new Opportunity(RecordTypeId=oppDonationRTId, Name=oppName, AccountId=lenderContact.AccountId, 
                                        ContactId=lenderContact.Id, CurrencyIsoCode='AUD', CloseDate=Date.today(), 
                                        StageName='Closed Won', Donation_Source__c='Auto Transfer', Type = 'LWC', Amount=trans.Amount__c,
                                        CampaignId=donationCampaign.Id, Pricebook2Id=stdPriceBookId));
            
        }
        system.debug('### oppList size: '+oppList.size());
        if(oppList != null && oppList.size()>0){
            insert oppList;
        }
        
        Test.startTest();
        Integer i=0;
        for(Transaction__c trans: tranList){
            trans.Opportunity__c=oppList[0].Id;
            trans.Status__c='Completed';
            trans.Completed_Date__c=System.Now();
            i++;
        }
        update tranList;
        Test.stopTest();
    }
    
}