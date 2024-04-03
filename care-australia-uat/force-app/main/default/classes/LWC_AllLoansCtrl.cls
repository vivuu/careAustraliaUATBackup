/**
* Class Name	:	LWC_AllLoansCtrl 
* Author		:	Amit Goyal
* Date			:	29/06/2023
* Description	:	For AllLoan related stories for LWC Site
*/

public without sharing class LWC_AllLoansCtrl {
    list<String> publishedLoanStagesToSkip = new list<String>{'Cancelled', 'Repaid', 'Written off', 'Expired'};
        @AuraEnabled(Cacheable=true) 
        public static  Map<String, Object> getAllLoansAndDoc_HomePage(){
            list<String> publishedLoanStagesToSkip = new list<String>{'Cancelled', 'Repaid', 'Written off', 'Expired'};
                Map<String, Object> loanContentDisMap = new Map<String, Object>();
            String strLoanSoql = 'Select Id, Name,Amount_Left_Before_Fully_Funded__c, Published_Amount_AUD__c, Published_Date__c, Loan_Title__c, Borrower__r.City__c, Borrower__r.Country__c,Location_of_Business__c,';
            strLoanSoql += ' Loan_Description__c,Loan_Purpose__c, LWC_Loan_Description__c, Loan_Principal_Disbursed_AUD__c, Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c,Expected_Fund_From_Cart__c,';
            strLoanSoql += ' Number_of_Lenders__c, Amount_Funded__c, Funded__c, CMS_Key__c, (SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) From Loan__c';
            strLoanSoql += ' Where (Stage__c != \'Cancelled\' AND Stage__c != \'Repaid\' AND Stage__c != \'Written off\' AND Stage__c != \'Expired\')'; 
            strLoanSoql += ' AND Loan_Proposal_Status__c=\'Published\' AND Feature_on_LWC_HomePage__c=true';
            List<Loan__c> loans = Database.query(strLoanSoql);
            if( loans.size() < 4 ){
                Integer recLength = 4-loans.size(); 
                String strLoanSoql2 = 'Select Id, Name,Amount_Left_Before_Fully_Funded__c, Published_Amount_AUD__c, Published_Date__c, Loan_Title__c, Borrower__r.City__c, Borrower__r.Country__c,Location_of_Business__c,';
                strLoanSoql2 += ' Loan_Description__c, Loan_Purpose__c, LWC_Loan_Description__c, Loan_Principal_Disbursed_AUD__c, Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c,Expected_Fund_From_Cart__c,';
                strLoanSoql2 += ' Number_of_Lenders__c, Amount_Funded__c, Funded__c, CMS_Key__c, (SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) From Loan__c';
                strLoanSoql2 += ' Where (Stage__c != \'Cancelled\' AND Stage__c != \'Repaid\' AND Stage__c != \'Written off\' AND Stage__c != \'Expired\')'; 
                strLoanSoql2 += ' AND Loan_Proposal_Status__c=\'Published\' AND Feature_on_LWC_HomePage__c=false LIMIT '+recLength;
                loans.addAll( (List<Loan__c>)Database.query(strLoanSoql2) );
            }
            loanContentDisMap.put('Loan', (Object)loans);
            Set<Id> contentDocumentIds = new Set<Id>();
            List<LWC_Config_Setting__mdt> LWCConfigSettings = [SELECT Minimum_Lending_Amount_AUD__c,Loan_Amounts__c FROM LWC_Config_Setting__mdt WHERE DeveloperName = 'LWC_Global'];
            if( !LWCConfigSettings.isEmpty() ){
                loanContentDisMap.put('loanAmts', (Object)LWCConfigSettings[0].Loan_Amounts__c);
            }
            if( !loans.isEmpty() && loans.size()>0 ){
                Map<Id, Id> loanIdContentDocIdsMap = new Map<Id, Id>();
                Map<Id, String> contentDocumentIdTitleMap = new Map<Id, String>();
                for( Loan__c loan : loans ){
                    for( ContentDocumentLink cdl : loan.ContentDocumentLinks ){
                        if( cdl.ContentDocument.Title.contains('_cover') && !cdl.ContentDocument.Title.contains('_round') ){
                            contentDocumentIdTitleMap.put( cdl.ContentDocumentId, cdl.ContentDocument.Title );
                            loanIdContentDocIdsMap.put( cdl.ContentDocumentId, loan.Id );
                            contentDocumentIds.add( cdl.ContentDocumentId );
                        }
                    }
                }
                if( !contentDocumentIds.isEmpty() ){
                    List<ContentDistribution> cds = [SELECT ContentDownloadUrl, ContentDocumentId FROM ContentDistribution 
                                                     WHERE ContentDocumentId IN :contentDocumentIds
                                                    ];
                    Map<Id, List<ContentDistribution>> loanIdContentDisMap = new Map<Id, List<ContentDistribution>>();
                    for( ContentDistribution cd : cds ){
                        if( loanIdContentDocIdsMap.containsKey(cd.ContentDocumentId) ){
                            //If loan Id is not there then add it
                            if( !loanIdContentDisMap.containsKey( loanIdContentDocIdsMap.get(cd.ContentDocumentId)) ){
                                loanIdContentDisMap.put( loanIdContentDocIdsMap.get(cd.ContentDocumentId), new List<ContentDistribution>());
                            }
                            if( contentDocumentIdTitleMap.containsKey(cd.ContentDocumentId) ){
                                cd.Name = contentDocumentIdTitleMap.get(cd.ContentDocumentId);
                            }
                            loanIdContentDisMap.get(loanIdContentDocIdsMap.get(cd.ContentDocumentId)).add( cd );
                        }
                    }
                    loanContentDisMap.put( 'ContentDistribution', (Object)loanIdContentDisMap );
                    return loanContentDisMap;
                }
            }
            return loanContentDisMap;
        }
    // All Loan which are featured for homepage
    @AuraEnabled(Cacheable=true)
    public static list<Loan__c> getAllLoans_HomePage(){
        list<String> publishedLoanStagesToSkip = new list<String>{'Cancelled', 'Repaid', 'Written off', 'Expired'};
            String strLoanSoql = 'Select Id, Name, Published_Amount_AUD__c, Published_Date__c, Loan_Title__c, Borrower__r.Country__c,Expected_Fund_From_Cart__c,';
        strLoanSoql += ' Loan_Description__c, Loan_Purpose__c, Loan_Principal_Disbursed_AUD__c, Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c,';
        strLoanSoql += ' Number_of_Lenders__c, Amount_Funded__c, Funded__c, CMS_Key__c From Loan__c';
        strLoanSoql += ' Where (Stage__c != \'Cancelled\' AND Stage__c != \'Repaid\' AND Stage__c != \'Written off\' AND Stage__c != \'Expired\')'; 
        strLoanSoql += ' AND Loan_Proposal_Status__c=\'Published\' AND Feature_on_LWC_HomePage__c=true';
        return Database.query(strLoanSoql);
    }
    @AuraEnabled
    public static Map<Id, List<ContentDistribution>> getContentDistribution(List<id> loanIds){
        try {
            Map<String, Object> loanContentDisMap = new Map<String, Object>();
            List<Loan__c> loans = [SELECT Id, (SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) 
                                   FROM Loan__c WHERE Id IN :loanIds
                                  ];
            Set<Id> contentDocumentIds = new Set<Id>();
            if( !loans.isEmpty() && loans.size()>0 ){
                Map<Id, Id> loanIdContentDocIdsMap = new Map<Id, Id>();
                Map<Id, String> contentDocumentIdTitleMap = new Map<Id, String>();
                for( Loan__c loan : loans ){
                    for( ContentDocumentLink cdl : loan.ContentDocumentLinks ){
                        if( cdl.ContentDocument.Title.contains('_cover') && !cdl.ContentDocument.Title.contains('_round') ){
                            contentDocumentIdTitleMap.put( cdl.ContentDocumentId, cdl.ContentDocument.Title );
                            loanIdContentDocIdsMap.put( cdl.ContentDocumentId, loan.Id );
                            contentDocumentIds.add( cdl.ContentDocumentId );
                        }
                    }
                }
                if( !contentDocumentIds.isEmpty() ){
                    List<ContentDistribution> cds = [SELECT ContentDownloadUrl, ContentDocumentId FROM ContentDistribution 
                                                     WHERE ContentDocumentId IN :contentDocumentIds
                                                    ];
                    Map<Id, List<ContentDistribution>> loanIdContentDisMap = new Map<Id, List<ContentDistribution>>();
                    for( ContentDistribution cd : cds ){
                        if( loanIdContentDocIdsMap.containsKey(cd.ContentDocumentId) ){
                            //If loan Id is not there then add it
                            if( !loanIdContentDisMap.containsKey( loanIdContentDocIdsMap.get(cd.ContentDocumentId)) ){
                                loanIdContentDisMap.put( loanIdContentDocIdsMap.get(cd.ContentDocumentId), new List<ContentDistribution>());
                            }
                            if( contentDocumentIdTitleMap.containsKey(cd.ContentDocumentId) ){
                                cd.Name = contentDocumentIdTitleMap.get(cd.ContentDocumentId);
                            }
                            loanIdContentDisMap.get(loanIdContentDocIdsMap.get(cd.ContentDocumentId)).add( cd );
                        }
                    }
                    return loanIdContentDisMap;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(Cacheable=true)
    public static list<Loan__c> getAllLoans(String loanType, String businessLocation, String sortBy,List<String> pageNumber, Integer pageSize){
        // This function will cover the allLoans, allLoans Filter, allLoans sort related story
        
        // MAD-74
        // GIVEN any user is on the “All Loans” page
        // WHEN the sytem loads the page
        // THEN the system should only load a small amount of loans (~20) AND should load more as the user keeps scrolling to see more loans
        
        // GIVEN a Lender is at the “All loans” page
        // WHEN A loan becomes fully funded
        // THEN the system should display the loans that are fully funded on the loans page (refer to the definition of active loans) 
        // until loans are Repaid, Written off or Cancelled ( Loan.Loan status)
        // 
        
        //Integer offset = (pageNumber - 1) * pageSize;
        list<String> publishedLoanStagesToSkip = new list<String>{'Cancelled', 'Repaid', 'Written off', 'Expired'};
            String strLoanSoql = 'Select Id, Name, Published_Date__c, Loan_Title__c,Borrower__r.Postcode__c, Borrower__r.Country__c,';
        strLoanSoql += ' Loan_Description__c, Loan_Purpose__c, Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c,Expected_Fund_From_Cart__c,';
        strLoanSoql += ' Number_of_Lenders__c, Amount_Funded__c, Funded__c, CMS_Key__c, Published_Amount_AUD__c,CreatedDate,Location_of_Business__c From Loan__c ';
        strLoanSoql += ' Where (Stage__c = \'Fundraising\' )'; 
        strLoanSoql += ' AND Loan_Proposal_Status__c=\'Published\' ';
        if(loanType != null && loanType.trim().length()>0){
            strLoanSoql += ' AND Loan_Type__c =: loanType';
        }
        
        if(businessLocation != null && businessLocation.trim().length()>0){
            strLoanSoql += ' AND Location_of_Business__c =: businessLocation';
        }
        
        if(sortBy != null && sortBy.trim().length()>0){
            if(sortBy=='Least To Complete'){
                strLoanSoql += ' Order By Published_Amount_AUD__c ASC';
            } else if(sortBy=='Most To Complete'){
                strLoanSoql += ' Order By Published_Amount_AUD__c DESC';
            }else if(sortBy=='Oldest Loan'){
                strLoanSoql += ' Order By Published_Date__c ASC';
            }else if(sortBy=='Most Recent Loan'){
                strLoanSoql += ' Order By Published_Date__c DESC';
            }else{
                strLoanSoql += ' Order By Published_Amount_AUD__c ASC';
            }
        }
        if(sortBy == null){
            strLoanSoql += ' Order By Published_Date__c DESC, Name DESC';
        }
        if(pageNumber != null && pageNumber.size()>0){
            strLoanSoql += ' AND Id NOT IN :pageNumber'; 
        }
        if(pageSize != null && pageSize>0){
            strLoanSoql += ' Limit :pageSize';
        }
        
        
        
        
        //strLoanSoql += ' Limit 10';
        return Database.query(strLoanSoql);
    }
    public static void updateLoanFundings(String loanId){
        // Bulkify the same logic in case you are calling this from trigger
        // To update the fields on loan after each transaction happens for loan funding.
        // also we have to take measure about updating the transaction whenever the amount needs to be returned in case the loan gets expired.
        list<Transaction__c> transactions = [Select Id, Name, Status__c, Lender__c, Amount__c From Transaction__c 
                                             Where Loan__c=:loanId 
                                             AND Type__c='Loan' 
                                             AND Status__c='Completed'];
        if(transactions != null && transactions.size()>0){
            set<String> noOfLenders = new set<String>();
            Decimal amountFunded = 0.0;
            for(Transaction__c trans: transactions){
                noOfLenders.add(trans.Lender__c);
                amountFunded+=trans.Amount__c;
            }
            Loan__c loan = new Loan__c(Id=loanId, Number_of_Lenders__c=noOfLenders.size(), Amount_Funded__c=amountFunded);
            update loan;
        }
    }
    
    public static list<Contact> getLoanLendersInformation(String loanId){
        // to return all the lenders for a specific loan for borrower's page or other places
        list<Transaction__c> transactions = [Select Id, Name, Status__c, Lender__c, Amount__c From Transaction__c 
                                             Where Loan__c=:loanId 
                                             AND Type__c='Loan' 
                                             AND Status__c='Completed'];
        if(transactions != null && transactions.size()>0){
            set<String> noOfLenders = new set<String>();
            for(Transaction__c trans: transactions){
                noOfLenders.add(trans.Lender__c);
            }
            
            return [Select Id, Name, Profile_Picture__c, Remain_Anonymous__c, Use_an_Alias__c From Contact Where Id IN: noOfLenders];
        }
        return null;
    }
    
    public static list<Loan__c> getRelatedLoans(String loanId, String loanType){
        // to return related loans for the borrower's page
        return [Select Id, Name, Published_Amount_AUD__c, Published_Date__c, Loan_Title__c, Borrower__r.Country__c, Loan_Description__c, Funded__c,Expected_Fund_From_Cart__c,
                Loan_Principal_Disbursed_AUD__c,  Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c, Number_of_Lenders__c, Amount_Funded__c,  
                (Select Id, Name, Repayment_Date__c, Amount_Due__c, Due_Date__c 
                 From Repayment_Schedules__r)
                From Loan__c Where Loan_Type__c =: loanType AND Id !=: loanId limit 4];
    }
    
    @AuraEnabled(Cacheable=true)
    public static Loan__c getLoan(String loanId){
        // to return loan information for the borrower's page
        return [Select Id,Name,CMS_Key__c,Published_Amount_AUD__c,Published_Date__c,Loan_Title__c,Loan_Description__c,Funded__c,Loan_Principal_Disbursed_AUD__c,Expected_Fund_From_Cart__c,
                Loan_Term_Months__c,Loan_Schedule__c,Loan_Type__c,Number_of_Lenders__c,Amount_Funded__c,Borrower__r.Name,Borrower__r.Country__c,
                Borrower__r.Description,(SELECT Id,ContentDocumentId FROM ContentDocumentLinks) 
                From Loan__c Where  Id =: loanId];
    }
    
    
    public class SearchResultWrapper {
        @AuraEnabled
        public List<SObject> searchResults { get; set; }
        
        @AuraEnabled
        public ConnectApi.ManagedContentVersionCollection contentCollection { get; set; }
    }
    
    @AuraEnabled(Cacheable=true)
    public static SearchResultWrapper searchLoan(string searchKey){
        String searchQuery = '*' + searchKey + '*'; // Note the asterisks for SOSL wildcards
        
        List<List<SObject>> searchResults = [
            FIND :searchQuery
            IN ALL FIELDS RETURNING
            Loan__c(Id, Name, Published_Date__c, Loan_Title__c, Borrower__r.Country__c,Borrower_Country__c,
                    Loan_Description__c, Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c,
                    Number_of_Lenders__c, Amount_Funded__c, Funded__c, CMS_Key__c, Published_Amount_AUD__c)
            //Loan_Other_Object__c(Id, Name, Custom_Field_1__c, Custom_Field_2__c)
            // Add more objects and fields as needed
        ];
        
        List<SObject> loans = new List<SObject>();
        
        // Extract and process the search results for Loan__c object
        for (List<SObject> resultList : searchResults) {
            loans.addAll(resultList);
        }
        
        String channelName = 'Lendwithcare';
        String channelId = getChannelId(channelName);
        SearchResultWrapper wrapper = new SearchResultWrapper();
        if(channelId != null){
            ConnectApi.ManagedContentVersionCollection obj = 
                ConnectApi.ManagedContent.getAllContent(channelId, 0, 100, 'en_US', 
                                                        'CareAustraliaSite',false,
                                                        '2023-06-25T18:24:31.000Z','2024-06-25T18:24:31.000Z');
            
            
            wrapper.searchResults = loans;
            wrapper.contentCollection = obj;
            
        }
        else{
            wrapper.searchResults = loans; 
        }
        
        
        return wrapper;
    }
    @AuraEnabled (cacheable=true)
    public static String getChannelId(String channelName){
        ConnectApi.ManagedContentChannelCollection channelRepObj = 
            ConnectApi.ManagedContent.getAllDeliveryChannels(0,6);        
        
        //loop through the channels and return the channel Id
        for(ConnectApi.ManagedContentChannel channelObj: channelRepObj.channels){
            if(channelObj.channelName == channelName){
                return channelObj.channelId;
            }
        }
        return null;
    }
    
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getAllLoansDev( Id contactId, String filter ){
        // This function will cover the allLoans, allLoans Filter, allLoans sort related story
        Map<String, Object> loanContentDisMap = new Map<String, Object>();
        String transactionQuery = 'SELECT Loan__c FROM Transaction__c WHERE Lender__c = \''+contactid+'\' AND Type__c = \'Loan\' AND Status__c = \'Completed\'';
        if( filter != 'All' ){
            transactionQuery+=' AND Loan__r.Stage__c = \''+filter+'\'';
        } else{
            transactionQuery+=' AND ( Loan__r.Stage__c = \'Fundraising\' OR Loan__r.Stage__c = \'Active\' OR Loan__r.Stage__c = \'Repaid\' )';
        }
        List<Transaction__c> transactions = Database.query(transactionQuery);
        if( transactions.size() > 0 ){
            Set<Id> loanIds = new Set<Id>();
            for( Transaction__c t : transactions ){
                loanIds.add( t.Loan__c );
            }
            List<Loan__c> loans = [   Select Id, Name,Amount_Left_Before_Fully_Funded__c, Expected_Fund_From_Cart__c,
                                   Published_Amount_AUD__c, Published_Date__c, Loan_Title__c, Borrower__r.City__c, Borrower__r.Country__c,
                                   Location_of_Business__c,Loan_Description__c, Loan_Purpose__c, LWC_Loan_Description__c, 
                                   Loan_Principal_Disbursed_AUD__c, Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c,
                                   Number_of_Lenders__c, Amount_Funded__c, Funded__c, CMS_Key__c, 
                                   (SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) From Loan__c 
                                   WHERE Id IN :loanIds              
                                  ];
            loanContentDisMap.put('Loan', (Object)loans);
            Set<Id> contentDocumentIds = new Set<Id>();
            if( !loans.isEmpty() && loans.size()>0 ){
                Map<Id, Id> loanIdContentDocIdsMap = new Map<Id, Id>();
                Map<Id, String> contentDocumentIdTitleMap = new Map<Id, String>();
                for( Loan__c loan : loans ){
                    for( ContentDocumentLink cdl : loan.ContentDocumentLinks ){
                        if( cdl.ContentDocument.Title.contains('_cover') && !cdl.ContentDocument.Title.contains('_round') ){
                            contentDocumentIdTitleMap.put( cdl.ContentDocumentId, cdl.ContentDocument.Title );
                            loanIdContentDocIdsMap.put( cdl.ContentDocumentId, loan.Id );
                            contentDocumentIds.add( cdl.ContentDocumentId );
                        }
                    }
                }
                if( !contentDocumentIds.isEmpty() ){
                    List<ContentDistribution> cds = [SELECT ContentDownloadUrl, ContentDocumentId FROM ContentDistribution 
                                                     WHERE ContentDocumentId IN :contentDocumentIds
                                                    ];
                    Map<Id, List<ContentDistribution>> loanIdContentDisMap = new Map<Id, List<ContentDistribution>>();
                    for( ContentDistribution cd : cds ){
                        if( loanIdContentDocIdsMap.containsKey(cd.ContentDocumentId) ){
                            //If loan Id is not there then add it
                            if( !loanIdContentDisMap.containsKey( loanIdContentDocIdsMap.get(cd.ContentDocumentId)) ){
                                loanIdContentDisMap.put( loanIdContentDocIdsMap.get(cd.ContentDocumentId), new List<ContentDistribution>());
                            }
                            if( contentDocumentIdTitleMap.containsKey(cd.ContentDocumentId) ){
                                cd.Name = contentDocumentIdTitleMap.get(cd.ContentDocumentId);
                            }
                            loanIdContentDisMap.get(loanIdContentDocIdsMap.get(cd.ContentDocumentId)).add( cd );
                        }
                    }
                    loanContentDisMap.put( 'ContentDistribution', (Object)loanIdContentDisMap );
                    return loanContentDisMap;
                }
            }
            return loanContentDisMap;
        }
        return null;
        /* String strLoanSoql = 'Select Id, Loan_Purpose__c, Name, Published_Date__c, Loan_Title__c,Borrower__r.Postcode__c, Borrower__r.Country__c,';
strLoanSoql += ' Loan_Description__c, Loan_Term_Months__c, Loan_Schedule__c, Loan_Type__c,';
strLoanSoql += ' Number_of_Lenders__c, Amount_Funded__c, Funded__c, Published_Amount_AUD__c From Loan__c ';
strLoanSoql += ' Where (Stage__c != \'Cancelled\' AND Stage__c != \'Repaid\' AND Stage__c != \'Written off\' AND Stage__c != \'Expired\')'; 
strLoanSoql += ' AND Loan_Proposal_Status__c=\'Published\' AND Lender__c = \''+contactId+'\'';

//strLoanSoql += ' Limit 10';
return Database.query(strLoanSoql); */
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<DataSet> getLoanTypeCount(Id contactid) {
        System.debug( 'CCID:'+contactid );
        List<DataSet> dataSet = new List<DataSet>();
        Set<Id> loanIds = new Set<Id>();
        //System.debug( 'Cont:'+ contactid);
        // List<Transaction__c> transactions = new List<Transaction__c>();
        if( contactid == null ){
            for( Loan__c l : [ SELECT Id FROM Loan__c WHERE Stage__c!= 'New' ] ){
                loanIds.add(l.Id);
            }
        }  
        else{
            for (Transaction__c trans : [ SELECT Loan__c FROM Transaction__c WHERE Lender__c = :contactid AND Status__c = 'Completed' AND Type__c='Loan' ]) {
                loanIds.add(trans.Loan__c);
            }
        }
        //System.debug( 'Size:'+transactions.size() );
        //System.debug('loanIds'+loanIds);
        List<AggregateResult> ls = [SELECT COUNT(Id) cnt, Loan_Type__c FROM Loan__c WHERE Id IN :loanIds GROUP BY Loan_Type__c ORDER BY Count(Id) DESC];
        //System.debug( '-->'+ls.size() );
        //List<AggregateResult> result = Database.query(ls);
        
        for (AggregateResult ar : ls) {
            String loanType = (String)ar.get('Loan_Type__c');
            Integer counts = (Integer)ar.get('cnt');
            dataSet.add(new DataSet(loanType, counts));
        }
        
        return dataSet;
    }
    
    public class DataSet {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Integer count { get; set; }
        
        public DataSet(String label, Integer count) {
            this.label = label;
            this.count = count;
        }
    }
    
    
    
    /*@AuraEnabled(cacheable=true)
public static User getCommunityUser() {
User communityUser = [SELECT Id, Name, ContactId, Contact.Name, Contact.Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

if (communityUser == null) {
throw new AuraHandledException('Community user not found.');
}

// Check if the queried user record has a contact associated
if (communityUser.ContactId != null) {
return communityUser;
} else {
throw new AuraHandledException('Associated contact missing for the community user.');
}
}*/
    
    
    //    @AuraEnabled(cacheable=true)
    // public static List<Transaction__c> getLoansByStage(String stage, Id contactId) {
    //     if (String.isNotBlank(stage) && contactId != null) {
    //         String strLoanSoql = 'SELECT Loan__r.Id, Loan__r.LWC_Loan_Description__c, Loan__r.Location_of_Business__c, Loan__r.Loan_Title__c, Loan__r.Loan_Type__c, Loan__r.Stage__c, Loan__r.Funded__c FROM Transaction__c WHERE Lender__c = \'' + contactId + '\'';
    
    //         if (!stage.equals('All')) {
    //             strLoanSoql += ' AND Loan__r.Stage__c = \'' + stage + '\'';
    //         }
    
    //         return Database.query(strLoanSoql);
    //     } else {
    //         return new List<Transaction__c>(); // Return an empty list
    //     }
    // }
    
    @AuraEnabled(cacheable=true)
    public static List<Loan__c> getLoansByStage(String stage, Id contactId) {
        Set<Id> loanIds = new Set<Id>();
        List<Loan__c> queryLoans = new List<Loan__c>();
        
        List<Transaction__c> transactions = [SELECT Loan__c FROM Transaction__c WHERE Lender__c = :contactId AND Status__c='Completed'];
        
        for (Transaction__c trans : transactions) {
            loanIds.add(trans.Loan__c);
        }
        
        if (String.isNotBlank(stage) && contactId != null) {
            
            queryLoans = [SELECT Id, Loan_Description__c, Location_of_Business__c, Loan_Title__c, Loan_Type__c, Stage__c, Funded__c,Expected_Fund_From_Cart__c FROM Loan__c WHERE Id IN :loanIds];
            
            if (!stage.equals('All')) {
                queryLoans = [SELECT Id, Loan_Description__c, Location_of_Business__c, Loan_Title__c, Loan_Type__c, Stage__c, Funded__c, Expected_Fund_From_Cart__c FROM Loan__c WHERE Id IN :loanIds AND Stage__c = :stage];            }
            
            return queryLoans;
        } else {
            return new List<Loan__c>(); // Return an empty list
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Transaction__c> getYourTransactionDetails(String type, Id contactId, Boolean showAll, String sortValue, Map<String, String> filterValues) {
        System.debug('@@@@: ');
        //System.debug('@@@@ Parsed:: ' + Date.parse(filterValues.get('fromDate')));
        
        if (String.isBlank(type) || contactId == null) {
            return new List<Transaction__c>();
        }
        
        String query = 'SELECT Id, Type__c, Amount__c, Completed_Date__c FROM Transaction__c WHERE Status__c=\'Completed\' AND Lender__c = \'' + contactId + '\'';
        
        if (!'All'.equals(type)) {
            query += ' AND Type__c = \'' + type + '\'';
        }
        
        if (filterValues != null) {
            if (filterValues.containsKey('fromAmount') && filterValues.containsKey('toAmount') &&
                filterValues.get('fromAmount')!='' && filterValues.get('toAmount')!=''
               ) {
                   Decimal fromAmount = Decimal.valueOf(filterValues.get('fromAmount'));
                   Decimal toAmount = Decimal.valueOf(filterValues.get('toAmount'));
                   query += ' AND Amount__c >= ' + fromAmount + ' AND Amount__c <= ' + toAmount;
               }
            
            if (filterValues.containsKey('fromDate') && filterValues.containsKey('toDate') && 
                filterValues.get('fromDate')!='' && filterValues.get('toDate')!=''
               ) {
                   Date fromDate = Date.valueOf(filterValues.get('fromDate'));
                   Date toDate = Date.valueOf(filterValues.get('toDate'));
                   DateTime fromDateTime = DateTime.newInstance(fromDate.year(), fromDate.month(), fromDate.day());
                   DateTime toDateTime = DateTime.newInstance(toDate.year(), toDate.month(), toDate.day(), 23, 59, 59);
                   query += ' AND Completed_Date__c >= ' + fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND Completed_Date__c <= ' + toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
               }
        }
        
        if ('MostRecent'.equals(sortValue)) {
            query += ' ORDER BY Completed_Date__c DESC';
        } else if ('Oldest'.equals(sortValue)) {
            query += ' ORDER BY Completed_Date__c ASC';
        } else if ('HighestLowest'.equals(sortValue)) {
            query += ' ORDER BY Amount__c DESC';
        } else if ('LowestHighest'.equals(sortValue)) {
            query += ' ORDER BY Amount__c ASC';
        } else {
            query += ' ORDER BY Completed_Date__c DESC';
        }
        
        /*  if (!showAll) {
query += ' LIMIT 8';
} */
        
        return Database.query(query);
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLoanSchedules( Id loanId ){
        Map<String, Object> schMap=new Map<String, Object>();
        schMap.put( 'RSch', (Object)[SELECT CurrencyIsoCode, Id, Due_Date__c, Repayment_Date__c, Amount_Due__c FROM Repayment_Schedule__c WHERE Loan__c = :loanId] );
        Map<string,decimal> cTypeMap = new Map<string,Decimal>();
        for( CurrencyType cType : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE] ){
            cTypeMap.put( cType.ISOCode, cType.ConversionRate );
        }
        schMap.put('CurrencyType', (Object)cTypeMap);
        return schMap; 
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLoanDetails(String loanId) {
        if (String.isNotBlank(loanId)) {
            String strLoanSoql = 'SELECT Id,(SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks ), Borrower__r.FirstName, Borrower__r.Published_Name__c,Borrower__r.City__c, Amount_Left_Before_Fully_Funded__c, Stage__c, Loan_Title__c, Borrower__r.Name, Amount_Funded__c, Borrower__r.Description, ';
            strLoanSoql+='(SELECT Id, Due_Date__c, Repayment_Date__c, Amount_Due__c, CurrencyIsoCode FROM Repayment_Schedules__r), ';
            strLoanSoql+='(SELECT Id, Lender__r.Id, Lender__r.Published_Name__c, Lender__r.Name,Lender__r.FirstName,Lender__r.Remain_Anonymous__c, Lender__r.Profile_Picture__c FROM Transactions__r WHERE Type__c=\'Loan\' AND Status__c = \'Completed\' LIMIT 14), ';
            strLoanSoql+='Borrower__r.Postcode__c, Borrower__r.Country__c, Loan_Description__c,LWC_Loan_Description__c, Funded__c, Published_Amount_AUD__c, Loan_Type__c, Loan_Term_Months__c, Loan_Schedule__c,Expected_Fund_From_Cart__c FROM Loan__c WHERE Id = \'' + String.escapeSingleQuotes(loanId) + '\' LIMIT 1';
            List<Loan__c> loans = Database.query(strLoanSoql);
            List<Loan__c> relatedLoans = new List<Loan__c>();
            List<ContentDistribution> cds = new List<ContentDistribution>();
            Map<Id, String> contentDocumentIdTitleMap = new Map<Id, String>();
            List<LWC_Config_Setting__mdt> LWCConfigSettings = [SELECT Loan_Amounts__c FROM LWC_Config_Setting__mdt WHERE DeveloperName = 'LWC_Global'];
            String loanAmts = LWCConfigSettings[0].Loan_Amounts__c;
            Map<Id, List<ContentDistribution>> loanIdContentDisMap = new Map<Id, List<ContentDistribution>>();
            if( loans!=null && !loans.isEmpty() ){
                //Fetching images
                Set<Id> contentDocumentIds = new Set<Id>();
                
                for( ContentDocumentLink cdl : loans[0].ContentDocumentLinks ){
                    contentDocumentIds.add( cdl.ContentDocumentId );
                    contentDocumentIdTitleMap.put( cdl.ContentDocumentId, cdl.ContentDocument.Title );
                }
                if( !contentDocumentIds.isEmpty() ){
                    cds = [SELECT ContentDownloadUrl, Name, ContentDocumentId FROM ContentDistribution 
                           WHERE ContentDocumentId IN :contentDocumentIds
                          ];
                    for( ContentDistribution cd : cds ){
                        if( contentDocumentIdTitleMap.containsKey( cd.ContentDocumentId ) ){
                            cd.Name = contentDocumentIdTitleMap.get(cd.ContentDocumentId);
                        }
                    }
                }
                
                // String strLoanTypeSoql = 'SELECT Id,Loan_Purpose__c,Amount_Left_Before_Fully_Funded__c,Expected_Fund_From_Cart__c, (SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks ), Loan_Title__c, Borrower__r.Name, Amount_Funded__c, Borrower__r.Description, Borrower__r.Postcode__c, Borrower__r.Country__c, Loan_Description__c, LWC_Loan_Description__c, Funded__c, Published_Amount_AUD__c, Loan_Type__c, Loan_Term_Months__c, Loan_Schedule__c FROM Loan__c WHERE Loan_Type__c = \'' + String.escapeSingleQuotes(loans[0].Loan_Type__c) + '\' AND Id !=\''+loanId+'\' AND Loan_Proposal_Status__c = \'Published\' ORDER BY CreatedDate DESC LIMIT 4';
                
                // Updated query to fetch only Fundraising Loans - Ashok Utala (23/01/2024)
                
                String strLoanTypeSoql = 'SELECT Id,Loan_Purpose__c,Amount_Left_Before_Fully_Funded__c,Expected_Fund_From_Cart__c, (SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks ), Loan_Title__c, Borrower__r.Name, Amount_Funded__c, Borrower__r.Description, Borrower__r.Postcode__c, Borrower__r.Country__c, Loan_Description__c, LWC_Loan_Description__c, Funded__c, Published_Amount_AUD__c, Loan_Type__c, Loan_Term_Months__c, Loan_Schedule__c FROM Loan__c WHERE Loan_Type__c = \'' + String.escapeSingleQuotes(loans[0].Loan_Type__c) + '\' AND Id !=\''+loanId+'\' AND Loan_Proposal_Status__c = \'Published\' AND Stage__c  = \'Fundraising\' ORDER BY CreatedDate DESC LIMIT 4';
                
                relatedLoans =  Database.query(strLoanTypeSoql);
                
                Set<Id> contentDocumentIdsRelLoans = new Set<Id>();
                /* List<LWC_Config_Setting__mdt> LWCConfigSettings = [SELECT Minimum_Lending_Amount_AUD__c FROM LWC_Config_Setting__mdt WHERE DeveloperName = 'LWC_Global'];
if( !LWCConfigSettings.isEmpty() ){
loanContentDisMap.put('MinimumLendingAmount', (Object)LWCConfigSettings[0].Minimum_Lending_Amount_AUD__c);
} */
                if( !relatedLoans.isEmpty() && relatedLoans.size()>0 ){
                    Map<Id, Id> loanIdContentDocIdsMap = new Map<Id, Id>();
                    Map<Id, String> relContentDocumentIdTitleMap = new Map<Id, String>();
                    for( Loan__c relLoan : relatedLoans ){
                        for( ContentDocumentLink cdl : relLoan.ContentDocumentLinks ){
                            if( cdl.ContentDocument.Title.contains('_cover') && !cdl.ContentDocument.Title.contains('_round') ){
                                loanIdContentDocIdsMap.put( cdl.ContentDocumentId, relLoan.Id );
                                contentDocumentIdsRelLoans.add( cdl.ContentDocumentId );
                                relContentDocumentIdTitleMap.put( cdl.ContentDocumentId, cdl.ContentDocument.Title );
                            }
                        }
                    }
                    if( !contentDocumentIdsRelLoans.isEmpty() ){
                        List<ContentDistribution> cdsRel = [SELECT ContentDownloadUrl, ContentDocumentId FROM ContentDistribution 
                                                            WHERE ContentDocumentId IN :contentDocumentIdsRelLoans
                                                           ];
                        for( ContentDistribution cd : cdsRel ){
                            if( loanIdContentDocIdsMap.containsKey(cd.ContentDocumentId) ){
                                //If loan Id is not there then add it
                                if( !loanIdContentDisMap.containsKey( loanIdContentDocIdsMap.get(cd.ContentDocumentId)) ){
                                    loanIdContentDisMap.put( loanIdContentDocIdsMap.get(cd.ContentDocumentId), new List<ContentDistribution>());
                                }
                                if( relContentDocumentIdTitleMap.containsKey(cd.ContentDocumentId) ){
                                    cd.Name = relContentDocumentIdTitleMap.get(cd.ContentDocumentId);
                                }
                                loanIdContentDisMap.get(loanIdContentDocIdsMap.get(cd.ContentDocumentId)).add( cd );
                            }
                        }
                    }
                }
                
            }
            Map<string,decimal> cTypeMap = new Map<string,Decimal>();
            for( CurrencyType cType : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE] ){
                cTypeMap.put( cType.ISOCode, cType.ConversionRate );
            }
            Object cmsContents;
            if(!test.isRunningTest()){
                cmsContents = (Object)CareHomePageCtrl.getContent('Why LWC');    
            } else if( Test.isRunningTest() ){
                cmsContents = (Object)'Test';
            }
            
            return new Map<String, Object>{'Loan'=>(object)loans,'CurrencyType'=>(Object)cTypeMap, 'RelatedLoan'=>(Object)relatedLoans, 'LoanContentDis'=>(Object)cds, 'RelatedLoanContentDis'=>(Object)loanIdContentDisMap, 'loanAmts'=>(Object)loanAmts, 'CMSContent'=>cmsContents};
                } 
        return new Map<String, Object>();
    }
    
    public class ContactData {
        @AuraEnabled
        public Contact contactRecord { get; set; }
        
        @AuraEnabled
        public Integer totalTransactionsAmount { get; set; }
        
        @AuraEnabled
        public Integer sumOfJobsCreated { get; set; }
        
        @AuraEnabled
        public Map<String, Decimal> mapOfTypeAndAmount { get; set; }
        
        public ContactData(Contact contactRecord, Integer totalTransactionsAmount, Integer sumOfJobsCreated, Map<String, Decimal> mapOfTypeAndAmount) {
            this.contactRecord = contactRecord;
            this.totalTransactionsAmount = totalTransactionsAmount;
            this.sumOfJobsCreated = sumOfJobsCreated;
            this.mapOfTypeAndAmount = mapOfTypeAndAmount;
        }
    }
    @AuraEnabled
    public static void putContactInfo(Id contactId, String FirstName, String LastName,String Title, Date dob, Boolean RemAnony) {
        try {
            Contact contact = [SELECT Id, FirstName, LastName, Title, BirthDate,Remain_Anonymous__c FROM Contact WHERE Id = :contactId];
            
            if (contact != null) {

                contact.Remain_Anonymous__c= RemAnony;
                if (String.isNotBlank(FirstName)) contact.FirstName = FirstName;
                if (String.isNotBlank(LastName)) contact.LastName = LastName;
                if (String.isNotBlank(Title)) contact.Title = Title;
                if(dob!=null)
                    contact.BirthDate = dob;
                update contact; // Make sure this line is executed without errors
            } else {
                throw new AuraHandledException('Contact not found with the provided ID.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static String getLogOutURL()
    {
        String retUrl=System.Label.Logout_URL_of_Lender;
        retUrl=retUrl.replace('login','homepage');
        return retUrl;
    }
    
    @AuraEnabled(Cacheable=true)
    public static ContactData getContactInfo(Id contactId) {
        Set<Id> loanIds = new Set<Id>();
        Map<String, Decimal> mapOfTypeAndAmount = new Map<String, Decimal>();
        
        List<Transaction__c> transactions = [SELECT Loan__c, Amount__c, Type__c, Status__c FROM Transaction__c WHERE Lender__c =: contactId and Status__c ='Completed'];
        
        for (Transaction__c trans : transactions) {
            
            loanIds.add(trans.Loan__c); //Load Ids
            
            Decimal amount = trans.Amount__c;
            
            if (trans.Type__c == 'Topup') {
                if (mapOfTypeAndAmount.containsKey('Topup')) {
                    amount += mapOfTypeAndAmount.get('Topup');
                }
                mapOfTypeAndAmount.put('Topup', amount);
                
            } else if (trans.Type__c == 'Repayment') {
                if (mapOfTypeAndAmount.containsKey('Repayment')) {
                    amount += mapOfTypeAndAmount.get('Repayment');
                }
                mapOfTypeAndAmount.put('Repayment', amount);
                
            } else if (trans.Type__c == 'Loan') {
                if (mapOfTypeAndAmount.containsKey('Loan')) {
                    amount += mapOfTypeAndAmount.get('Loan');
                }
                mapOfTypeAndAmount.put('Loan', amount);
                
            } else if (trans.Type__c == 'Withdrawal') {
                if (mapOfTypeAndAmount.containsKey('Withdrawal')) {
                    amount += mapOfTypeAndAmount.get('Withdrawal');
                }
                mapOfTypeAndAmount.put('Withdrawal', amount);
                
            } else if (trans.Type__c == 'Donation') {
                if (mapOfTypeAndAmount.containsKey('Donation')) {
                    amount += mapOfTypeAndAmount.get('Donation');
                }
                mapOfTypeAndAmount.put('Donation', amount);
            }
        }
        
        // Querying the Breakdown data.
        Contact contactRecord = [SELECT Id, FirstName, LastName, Birthdate	,Remain_Anonymous__c,Title,Name, Total_Loans__c, Total_Amount_Lent__c, Total_Donation__c, 
                                 Champion__c,Auto_Relend__c, Lender_Balance__c, Total_People_Helped__c, Profile_Picture__c FROM Contact WHERE Id = :contactId LIMIT 1];
        
        AggregateResult sumOfTransactionsAmount = [SELECT SUM(Amount__c) FROM Transaction__c WHERE Lender__c = :contactId and Status__c ='Completed'];
        AggregateResult sumOfLoansJobsCreated = [SELECT SUM(Jobs_Created__c) FROM Loan__c WHERE Id IN :loanIds];
        
        AggregateResult sumOfTotalPeoplehelp = [SELECT SUM(Loan__r.Jobs_Created__c),SUM(Loan__r.Number_of_Employees__c),
                                                SUM(Loan__r.Borrower__r.dependants__c) FROM Transaction__c WHERE Lender__c =: contactId and Type__c = 'Loan' and Status__c ='Completed'];
        // Extracting values from AggregateResult
        Integer totalTransactionsAmount = sumOfTransactionsAmount != null && sumOfTransactionsAmount.get('expr0')!=null ? ((Decimal)sumOfTransactionsAmount.get('expr0')).intValue() : 0;
        
        Decimal peopleHelped = 0;
        if( sumOfTotalPeoplehelp!= null ){
            peopleHelped+= sumOfTotalPeoplehelp.get('expr0')!=null? ((Decimal)sumOfTotalPeoplehelp.get('expr0')) : 0;
            peopleHelped+= sumOfTotalPeoplehelp.get('expr1')!=null? ((Decimal)sumOfTotalPeoplehelp.get('expr1')) : 0;
            peopleHelped+= sumOfTotalPeoplehelp.get('expr2')!=null? ((Decimal)sumOfTotalPeoplehelp.get('expr2')) : 0;
        }
        mapOfTypeAndAmount.put('Peoplehelped', peopleHelped);
        //Integer sumOfJobsCreated = sumOfLoansJobsCreated != null ? ((Decimal)sumOfLoansJobsCreated.get('expr0')).intValue() : 0;
        Integer sumOfJobsCreated = 0; // Default value
        if (sumOfLoansJobsCreated != null) {
            Decimal expr0Value = (Decimal)sumOfLoansJobsCreated.get('expr0');
            
            if (expr0Value != null) {
                sumOfJobsCreated = expr0Value.intValue();
            }
        }
        ContactData contactData = new ContactData(contactRecord, totalTransactionsAmount, sumOfJobsCreated,mapOfTypeAndAmount);
        return contactData;
    }
    /* @AuraEnabled(cacheable=true)
public static String getProfileImage(String contId) {
if( contId!=null ){
List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM 
ContentDocumentLink WHERE ContentDocument.Title Like '%Profile%'
AND LinkedEntityId = :contId
];
if( !contDocLinks.isEmpty() ){
List<ContentDistribution> cds = [SELECT ContentDownloadUrl, ContentDocumentId FROM ContentDistribution 
WHERE ContentDocumentId = :contDocLinks[0].ContentDocumentId
];
if( !cds.isEmpty() ){
return cds[0].ContentDownloadUrl;
}
}
}
return null;
} */
    @AuraEnabled(Cacheable=true)
    public static Map<String, Decimal> getImpactInfo() {
        Set<Id> loanIds = new Set<Id>();
        Map<String, Decimal> mapOfTypeAndAmount = new Map<String, Decimal>();
        
        List<Transaction__c> transactions = [SELECT Loan__c, Amount__c, Type__c, Status__c FROM Transaction__c Where Status__c ='Completed'];
        
        for (Transaction__c trans : transactions) {
            
            loanIds.add(trans.Loan__c); //Load Ids
            
            Decimal amount = trans.Amount__c;
            
            if (trans.Type__c == 'Topup') {
                if (mapOfTypeAndAmount.containsKey('Topup')) {
                    amount += mapOfTypeAndAmount.get('Topup');
                }
                mapOfTypeAndAmount.put('Topup', amount);
                
            } else if (trans.Type__c == 'Repayment') {
                if (mapOfTypeAndAmount.containsKey('Repayment')) {
                    amount += mapOfTypeAndAmount.get('Repayment');
                }
                mapOfTypeAndAmount.put('Repayment', amount);
                
            } else if (trans.Type__c == 'Loan') {
                if (mapOfTypeAndAmount.containsKey('Loan')) {
                    amount += mapOfTypeAndAmount.get('Loan');
                }
                mapOfTypeAndAmount.put('Loan', amount);
                
            } else if (trans.Type__c == 'Withdrawal') {
                if (mapOfTypeAndAmount.containsKey('Withdrawal')) {
                    amount += mapOfTypeAndAmount.get('Withdrawal');
                }
                mapOfTypeAndAmount.put('Withdrawal', amount);
                
            } else if (trans.Type__c == 'Donation') {
                if (mapOfTypeAndAmount.containsKey('Donation')) {
                    amount += mapOfTypeAndAmount.get('Donation');
                }
                mapOfTypeAndAmount.put('Donation', amount);
            }
        }
        
        // Querying the Breakdown data.
        // Contact contactRecord = [SELECT Id, Name, Total_Loans__c, Champion__c,Auto_Relend__c, Lender_Balance__c, Total_People_Helped__c, Profile_Picture__c FROM Contact WHERE Id = :contactId LIMIT 1];
        AggregateResult sumOfTransactionsAmount = [SELECT SUM(Loan__r.Published_Amount_AUD__c) FROM Transaction__c WHERE Type__c = 'Loan' AND Status__c ='Completed' ];
        AggregateResult sumOfLoansJobsCreated = [SELECT SUM(Jobs_Created__c) FROM Loan__c WHERE Loan_Proposal_Status__c  = 'Published'  ];
        AggregateResult sumOfTotalLoans = [SELECT count(Id) FROM Loan__c WHERE Loan_Proposal_Status__c  = 'Published'  ];
        
        AggregateResult sumOfPeopleHelped = [SELECT sum(Borrower__r.Dependants__c), sum(Jobs_Created__c), sum(Number_of_Employees__c) FROM Loan__c WHERE Loan_Proposal_Status__c  = 'Published' ];
        // Extracting values from AggregateResult
        Decimal totalTransactionsAmount = sumOfTransactionsAmount != null && sumOfTransactionsAmount.get('expr0')!=null ? ((Decimal)sumOfTransactionsAmount.get('expr0')) : 0;
        Decimal sumOfJobsCreated = sumOfLoansJobsCreated != null && sumOfLoansJobsCreated.get('expr0')!=null ? ((Decimal)sumOfLoansJobsCreated.get('expr0')) : 0;
        Decimal totalLoans = sumOfTotalLoans != null  && sumOfTotalLoans.get('expr0')!=null? ((Decimal)sumOfTotalLoans.get('expr0')) : 0;
        Decimal peopleHelped = 0;
        if( sumOfPeopleHelped!= null ){
            peopleHelped+= sumOfPeopleHelped.get('expr0')!=null? ((Decimal)sumOfPeopleHelped.get('expr0')) : 0;
            peopleHelped+= sumOfPeopleHelped.get('expr1')!=null? ((Decimal)sumOfPeopleHelped.get('expr1')) : 0;
            peopleHelped+= sumOfPeopleHelped.get('expr2')!=null? ((Decimal)sumOfPeopleHelped.get('expr2')) : 0;
        }
        // ContactData contactData = new ContactData(contactRecord, totalTransactionsAmount, sumOfJobsCreated,mapOfTypeAndAmount);
        return new Map<String, Decimal>{'NumberOfLoans'=>totalLoans, 'totalAmountLent'=>totalTransactionsAmount, 'JobsCreated'=>sumOfJobsCreated, 'PeopleHelped'=>peopleHelped};
            }
    
    @AuraEnabled(cacheable=true)
    public static List<Loan__c> getLoanDetailsForCart(List<Id> loanIds){
        return [SELECT Id, Loan_Title__c, Borrower__r.Postcode__c, Borrower__r.Country__c, Loan_Description__c, Expected_Fund_From_Cart__c,
                Funded__c, Published_Amount_AUD__c, Loan_Type__c, Loan_Term_Months__c, Loan_Schedule__c FROM Loan__c 
                WHERE Id IN:loanIds];
    }
    
    @AuraEnabled(cacheable=true)
    public static LWC_Config_Setting__mdt LWCConfigSettingMetadata(){
        
        return [SELECT Default_Donation_at_Checkout__c, FSP_Payment_Threshold_USD__c, Group_Borrower_Limit_AUD__c, 
                Id, Inactive_Lender_Limit_Days__c, Individual_Borrower_Limit_AUD__c, Lending_Buffer__c, 
                Loan_Acceptance_Days__c, Loan_Publish_Limit_Days__c, Minimum_Lending_Amount_AUD__c, 
                Missed_Repayments_Nonperforming__c, Number_of_Days_Manual_Refund__c, 
                Number_of_Refunds_Manual_Refund__c,Change_Champion_Currencies__c,Loan_Amounts__c
                FROM LWC_Config_Setting__mdt];
        
    }
    @AuraEnabled(cacheable=true)
    public static Loan__c getLeastToCompleteLoanRecord(){
        List<Loan__c> loanList = [SELECT Id, Loan_Title__c, Borrower__r.Postcode__c, Borrower__r.Country__c, Borrower__r.FirstName, 
                                  Loan_Description__c, Funded__c, Amount_Funded__c, Published_Amount_AUD__c, Loan_Type__c, Loan_Term_Months__c,
                                  Amount_Left_Before_Fully_Funded__c, Loan_Schedule__c FROM Loan__c WHERE Amount_Left_Before_Fully_Funded__c <= 50 and 
                                  Amount_Left_Before_Fully_Funded__c >= 25 and Stage__c != 'Cancelled' AND Stage__c != 'Repaid' AND 
                                  Stage__c != 'Written off' AND Stage__c != 'Expired' ORDER BY CreatedDate ASC LIMIT 1];
        if (!loanList.isEmpty()) {
            Loan__c loanRecord = loanList[0];
            return loanRecord;
            // Use the loanRecord or perform actions with it
        }
        return null;
    }
    public class TransactionData {
        @AuraEnabled public String Borrower { get; set; }
        @AuraEnabled public Decimal selectedAmount { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Type { get; set; }
    }
    
    
    @AuraEnabled
    public static List<Transaction__c> createTransactionRecord(List<Transaction__c> recordsToInsert){
        //,String sessionId
        List<Transaction__c> transactionListToInsert = new List<Transaction__c>();
        List<Loan__c> loanToUpdate = new List<Loan__c>();
        system.debug('data from lwc is '+ recordsToInsert);
        
        Cart__c cartRecord = new Cart__c();
        if(recordsToInsert[0].Lender__c != null){
            cartRecord = [select id,Last_Transaction_DateTime__c from Cart__c where Contact__c=:recordsToInsert[0].Lender__c limit 1];                
        }
        else{
            cartRecord = [select id,Last_Transaction_DateTime__c from Cart__c where Contact__c=null limit 1];
        }
        //cartRecord.Session_ID__c=UserInfo.getSessionID();
        
        Cart_Items__c cartItemsRecord = new Cart_Items__c();
        cartItemsRecord.Cart__c = cartRecord.id;
        if(recordsToInsert[0].Lender__c != null){
            cartItemsRecord.Lender__c = recordsToInsert[0].Lender__c;
        }
        if(recordsToInsert[0].Loan__c != null){
            cartItemsRecord.Loan__c = recordsToInsert[0].Loan__c;
        }
        cartItemsRecord.Type__c = recordsToInsert[0].Type__c;
        cartItemsRecord.Amount__c = recordsToInsert[0].Amount__c;
        //cartItemsRecord.Session_ID__c=sessionId;
        try{
            insert cartItemsRecord;   
            //Cart_Items__c cartItem = [select id, CreatedDate from Cart_Items__c where id=:cartItemsRecord.Id];
            //Datetime createdDateTime =System.now();
            //system.debug('createdDateTime '+createdDateTime);
            //Cart__c cart = [select id,Last_Transaction_DateTime__c from Cart__c where Id=:cartItemsRecord.Cart__c];
            cartRecord.Last_Transaction_DateTime__c = System.now();
            update cartRecord;
        }
        catch(Exception error){
            System.debug('error creating cart items '+ error);
        }
        Loan__c loanRecord = [select id, Expected_Fund_From_Cart__c,Amount_Funded__c from Loan__c where id=:recordsToInsert[0].Loan__c limit 1];
        
        for (Transaction__c rec : recordsToInsert) {
            rec.Status__c = 'Held';
            //rec.Completed_Date__c = System.today();
            rec.Added_To_Cart__c = true;
            if(cartItemsRecord.id != null){
                rec.Cart_Items__c = cartItemsRecord.id;
            }
            //rec.Session_ID__c=sessionId;
            /*loanRecord.Expected_Fund_From_Cart__c = rec.Amount__c;
            loanRecord.Amount_Funded__c = loanRecord.Amount_Funded__c + rec.Amount__c;
            loanRecord.Added_to_cart__c = true;
            loanToUpdate.add(loanRecord);*/
            
            transactionListToInsert.add(rec);
            
        }
        
        if (!transactionListToInsert.isEmpty()) {
            system.debug('inside if condition');
            //update loanToUpdate;
            insert transactionListToInsert;
        }
        system.debug('outside if condition');
        return transactionListToInsert;
    }
    @AuraEnabled
    public static Transaction__c updateTransactionRecord(Transaction__c rec){
        
        Transaction__c trData =[select id from Transaction__c where id=:rec.Id limit 1];
        trData.Amount__c = rec.Amount__c;
        if(trData != null ){
            update trData;
        }
        
        return trData;
        
        
    }
    @AuraEnabled
    public static Transaction__c updateDonationRecord( decimal coverTransactionCost, decimal voluntaryDonation, string contactId, Boolean showTransactionCoverCost, string transactionRec, Boolean isTopupOnly){
        Cart__c cartRecord = new Cart__c();
        if(contactId != null){
            cartRecord = [select id from Cart__c where Contact__c=:contactId limit 1];
            if(cartRecord!=null){
                List<Transaction__c> trData =[select id , Amount__c,Transaction_Fee__c, cart_items__c from Transaction__c  where id=: transactionRec];//id=:recId 
                Transaction__c tr = new Transaction__c();
                if(trData!=null && trData.size()>0){
                    tr = trData[0];
                    tr.isTopupOnly__c = isTopupOnly;
                    if(showTransactionCoverCost){
                        tr.Amount__c = coverTransactionCost + voluntaryDonation;
                        tr.Transaction_Fee__c = coverTransactionCost;
                        update tr;
                    }else{
                        Cart_Items__c cr = new Cart_Items__c();
                        cr.id = tr.cart_items__c;
                        tr.Amount__c = voluntaryDonation;
                        tr.Transaction_Fee__c = 0;
                        if(tr.Amount__c == 0){
                            //delete[select id from Cart_Items__c where id=:tr.cart_items__c];
                            //delete tr;
                            update tr;
                        }else{
                            update tr;
                            cr.Amount__c = tr.Amount__c;
                            update cr;
                        }
                    }
                }else{
                    Cart_Items__c cr = new Cart_Items__c();
                    cr.cart__c = cartRecord.id;
                    cr.lender__c = contactId;
                    cr.type__c = 'Donation';
                    cr.Amount__c = showTransactionCoverCost ? coverTransactionCost + voluntaryDonation : voluntaryDonation;
                    insert cr;
                    tr.lender__c = contactId;
                    tr.Amount__c = showTransactionCoverCost ? coverTransactionCost + voluntaryDonation : voluntaryDonation;
                    tr.type__c = 'Donation';
                    tr.cart_items__c = cr.id;
                    tr.status__c = 'Held';
                    tr.Transaction_Fee__c = 0;
                    insert tr;
                }
                
                
                return tr;
            }
            return null;                
        }
        
        return null;
        
    }
    
    @AuraEnabled
    public static List<Transaction__c> updateTransactionRecords(List<Id> rec, string conId){
        string contactId = conId;
        List<Transaction__c> trData =[select id,Lender__c,Cart_Items__c from Transaction__c where id in :rec];
        List<Transaction__c> toUpdate = new List<Transaction__c>();
        List<Cart_Items__c> tpUpdatecartItems = new List<Cart_Items__c>();
        set<Id> cartItemsId = new Set<Id>();
        List<Cart__c> cart=new List<cart__c>([SELECT Id,Last_Transaction_DateTime__c FROM Cart__c WHERE Contact__c = :conId]);
        if(cart.size()>0)
        {
            cart[0].Last_Transaction_DateTime__c=DateTime.now();
            update cart;
            
        }
        
        //Cart__c cart=[select Id from Cart__c where Contact__c =:conId];
        for(Transaction__c tr:trData){
            if(contactId != null){
                tr.Lender__c = contactId;
            }
            
            toUpdate.add(tr);
            cartItemsId.add(tr.Cart_Items__c);
        }
        
        if(trData.size()>0 ){
            update toUpdate;
        }
        List<Cart_Items__c> cartItems = [select id,Cart__c from Cart_Items__c where id in :cartItemsId];
        for(Cart_Items__c cartItem: cartItems){
            //cartItem.Cart__c = cart.Id;
            cartItem.Lender__c = contactId;
            cartItem.Cart__c = cart[0].Id;
            tpUpdatecartItems.add(cartItem);
        }
        if(tpUpdatecartItems.size()>0 ){
            update tpUpdatecartItems;
        }
        return toUpdate;
    }
    @AuraEnabled
    public static List<Transaction__c> updateTransactionRecordsAfterPayment(List<Id> rec, string conId){
        
        List<Transaction__c> trData =[select id,Lender__c from Transaction__c where id in :rec];
        List<Transaction__c> toUpdate = new List<Transaction__c>();
        
        for(Transaction__c tr:trData){
            tr.Lender__c = conId;
            tr.Transaction_Date__c = system.now();
            tr.Status__c = 'Completed';
            tr.Completed_Date__c=system.now();
        }
        
        if(trData.size()>0 ){
            update trData;
        }
        
        return trData;
        
        
    }
    
    @AuraEnabled
    public static Transaction__c removeTransactionRecord(string idToRemove){
        List<Transaction__c> transactionToDelete = new List<Transaction__c>();
        //List<Transaction__c> transactionToUpdate = new List<Transaction__c>();
        transactionToDelete = [select id,Cart_Items__c,type__c,amount__c from Transaction__c where id=:idToRemove and Status__c ='Held'];
        set<id> itemDelete = new set<id>();
        for(Transaction__c trans :transactionToDelete){
            /* if(trans.type__c=='Donation' && coverTransactionCost){
trans.Amount__c = donationAmt;
transactionToUpdate.add(trans);
}else{*/
            itemDelete.add(trans.Cart_Items__c);
            //}
        }
        List<Cart_Items__c>   itemToDelete = [select id from Cart_Items__c where id IN :itemDelete];
        //if(transactionToUpdate!=null && transactionToUpdate.size()>0){
        // update transactionToUpdate;
        //return transactionToUpdate[0];
        //}
        delete itemToDelete; 
        delete transactionToDelete;
        
        return null;
        
    }
    
    @AuraEnabled
    public static List<Transaction__c> removeZeroAmountTransactionRecord(String transId){
        // Step 1: Query Transaction__c records  
        List<Transaction__c> transactions = [SELECT Id, Opportunity__c, Opportunity2__c FROM Transaction__c WHERE Id =: transId];

        // Step 2: Query Opportunity__c records related to transactions
        Set<Id> opportunityIds = new Set<Id>();
        for (Transaction__c trans : transactions) {
            if (trans.Opportunity2__c != null) {
                opportunityIds.add(trans.Opportunity2__c);
            }
        }
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Id IN :opportunityIds];

        // Step 3: Query payment records (assuming Payment__c is a child object of Opportunity)
        List<npe01__OppPayment__c> payments = [SELECT Id FROM npe01__OppPayment__c WHERE npe01__Opportunity__c IN :opportunityIds];

        // Step 4: Delete related records in proper order
        if(!payments.isEmpty()){
            delete payments;
        }
        if(!opportunities.isEmpty()){
            delete opportunities;
        }
        if(!transactions.isEmpty()){
            delete transactions;
        }

        return transactions;
    }

    @AuraEnabled
    public static List<Transaction__c> removeTransactionRecords(List<Id> recordsToDelete){
        
        List<Transaction__c> transactionToDelete = new List<Transaction__c>();
        transactionToDelete = [select id from Transaction__c where id in :recordsToDelete And Status__c ='Held'];
        delete transactionToDelete;
        return transactionToDelete;
    }
    
    @AuraEnabled
    public static String TopupTransactionRecords(Transaction__c TopupRecord){
        system.debug('topup record from lwc '+TopupRecord);
        List<Transaction__c> transactionListToInsert = new List<Transaction__c>();
        Contact conRec = new Contact();  
        if(TopupRecord.Lender__c != null){
            conRec = [select id,KYC_Completed__c, KYC_failed__c,Lender_Balance__c from Contact where id=:TopupRecord.Lender__c];
        }
        system.debug('conRec '+conRec);
        Cart__c cartRecord = new Cart__c();
        if(conRec.Id != null){
            cartRecord = [select id from Cart__c where Contact__c=:conRec.Id limit 1];                
        }
        else{
            cartRecord = [select id from Cart__c where Contact__c=null limit 1];
        }
        
        Cart_Items__c cartItemsRecord = new Cart_Items__c();
        cartItemsRecord.Cart__c = cartRecord.id;
        if(conRec.Id != null){
            cartItemsRecord.Lender__c = conRec.Id;
        }
        
        cartItemsRecord.Type__c = TopupRecord.Type__c;
        cartItemsRecord.Amount__c = TopupRecord.Amount__c;
        try{
            insert cartItemsRecord; 
            Cart_Items__c cartItem = [select id, CreatedDate from Cart_Items__c where id=:cartItemsRecord.Id];
            Datetime createdDateTime = cartItem.CreatedDate;
            system.debug('createdDateTime '+createdDateTime);
            Cart__c cart = [select id,Last_Transaction_DateTime__c from Cart__c where Id=:cartItemsRecord.Cart__c];
            cart.Last_Transaction_DateTime__c = createdDateTime;
            update cart;
        }
        catch(Exception error){
            System.debug('error creating cart items '+ error);
        }
        TopupRecord.Status__c = 'Held';
        //TopupRecord.Completed_Date__c = System.today();
        TopupRecord.Added_To_Cart__c = true;
        if(cartItemsRecord.id != null){
            TopupRecord.Cart_Items__c = cartItemsRecord.id;
        }
        transactionListToInsert.add(TopupRecord);
        if(conRec != null && conRec.KYC_Completed__c
           && conRec.KYC_failed__c == false ){
               
               if (!transactionListToInsert.isEmpty()) {
                   UPSERT transactionListToInsert;
               }
               system.debug('outside if condition');
               
               return transactionListToInsert[0].Id;
           }
        else if(conRec != null && conRec.KYC_Completed__c == false
                && conRec.KYC_failed__c == false
                && (conRec.Lender_Balance__c + TopupRecord.Amount__c) >4999){
                    return 'KYC Pending';
                }
        else if(conRec != null && conRec.KYC_Completed__c == false
                && conRec.KYC_failed__c == false ){
                    
                    if (!transactionListToInsert.isEmpty()) {
                        UPSERT transactionListToInsert;
                    }
                    system.debug('outside if condition');
                    
                    return transactionListToInsert[0].Id;
                }
        
        return null;
    }
    
    
    
    @AuraEnabled
    public static npe03__Recurring_Donation__c recurringRecordCreation(npe03__Recurring_Donation__c rec)
    {
        
        Stripe_Setting__c stripeData = [select id, name,Default_Campaign__c from Stripe_Setting__c where name = 'default' LIMIT 1];
        system.debug('stripeData '+ stripeData);
        system.debug('campaign record '+ [select id, isActive, Name from Campaign where id=:stripeData.Default_Campaign__c limit 1]); 
        rec.npe03__Recurring_Donation_Campaign__c = stripeData.Default_Campaign__c;
        rec.npe03__Installments__c =12;
        system.debug('rec before try '+rec);
        
        Cart__c cartRecord = [select id,Is_Having_RD__c from Cart__c where Contact__c =:rec.npe03__Contact__c];
        try {
            
            system.debug('bfore insert '+rec);
            upsert rec;
            cartRecord.Is_Having_RD__c = true;
            update cartRecord;
            return rec;
            
        } catch (DmlException e) {
            System.debug('An error occurred while inserting the records: ' + e.getMessage());
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static Contact getLenderBalance(string conId){
        return [select Id, Name,Lender_Balance__c,MobilePhone,MailingPostalCode,Email,Champion__c,Terms_and_conditions__c   from Contact where id=:conId];
    }
    
    @AuraEnabled
    public static Transaction__c donateFromDashboard(Transaction__c rec){
        
        Contact lenderDetails = [select Lender_Balance__c, Id, FirstName, LastName, Name, Email, Phone, Stripe_Customer_Id__c, CurrencyIsoCode, AccountId from contact where id=:rec.Lender__c limit 1];
        if(lenderDetails.Lender_Balance__c >= rec.Amount__c){
            try{
                rec.Completed_Date__c = System.now();
                rec.Status__c = 'Completed';
                rec.Transaction_Date__c = System.now();
                rec.Added_To_Cart__c = true;
                insert rec;
                
                CheckoutUtility.processTransactionsAndPayment(new List<Id>{rec.Id}, lenderDetails, rec.Amount__c, new Map<String, Object>(), '');
                
                rec.Added_To_Cart__c = false;
                update rec;                
            }
            catch(exception e){
                system.debug('can not create donation records ' + e);
            }
        }
        return rec;
        
    }
    
    //Method to get picklist values of loan type filed from loan object
    @AuraEnabled(cacheable=true)
    public static List<LoanTypeOption> getLoanTypes() {
        List<LoanTypeOption> options = new List<LoanTypeOption>();
        
        Schema.DescribeFieldResult fieldResult = Loan__c.Loan_Type__c.getDescribe();
        
        for (Schema.PicklistEntry pick : fieldResult.getPicklistValues()) {
            LoanTypeOption option = new LoanTypeOption();
            option.value = pick.getValue();
            option.label = pick.getLabel();
            options.add(option);
        }
        
        return options;
    }
    
    public class LoanTypeOption {
        @AuraEnabled
        public String value { get; set; }
        
        @AuraEnabled
        public String label { get; set; }
    }
    @AuraEnabled
    public static string createLead( String fName, String lName, String email ){
        try {
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Newsletter').getRecordTypeId();
            INSERT new Lead(firstName=fName,LastName=lName, Email=email, Company=lName+' Household',npe01__Preferred_Email__c='Personal',LeadSource='LendWithCare',Status='Open - Not Contacted');
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean isGuestUser() {
        if( UserInfo.getSessionId()==null || UserInfo.getName().contains('Guest') ){
            return true;
        }
        return false;
    }
    /* @AuraEnabled
public static void updateCheckoutValue() {
List<CheckoutSetting__c> chkSettings = [SELECT Id, SetupOwnerId, value__c FROM CheckoutSetting__c];
if( chkSettings!=null && !chkSettings.isEmpty() && chkSettings.size() > 0 ){
if( chkSettings[0].SetupOwnerId != null ){   
chkSettings[0].value__c = '1234';
UPDATE chkSettings[0];
}
}else{
CheckoutSetting__c checkoutSetting = new CheckoutSetting__c( value__c = '1234' );
INSERT checkoutSetting;
}
}
@AuraEnabled
public static String checkSessionValue(String sessionId) {
List<CheckoutSetting__c> chkSettings = [SELECT Id, SetupOwnerId, value__c FROM CheckoutSetting__c];
if( chkSettings!=null && !chkSettings.isEmpty() && chkSettings.size() > 0 ){
if( chkSettings[0].value__c == sessionId ){   
chkSettings[0].value__c = null;
Update chkSettings[0];
return 'Success';
}
}
return 'Error';
} */
    
    @AuraEnabled
    public static void updateCommunicationPreference(Contact rec){
        Contact contactRecord = [select id, Email_Lendwithcare_Opt_Out__c from Contact where id=:rec.Id];
        
        try{
            contactRecord.Email_Lendwithcare_Opt_Out__c = rec.Email_Lendwithcare_Opt_Out__c;
            update contactRecord;
        }     
        catch(Exception e){
            system.debug('error updating contact '+ e);
        }
    }
    @AuraEnabled(cacheable=true)
    public static Contact getCommunicationPreferences(string conId){
        return [select id,Email_Lendwithcare_Opt_Out__c from Contact where id=:conId ];
    }
    
    @AuraEnabled
    public static void updateCommunicationPreferences(Contact rec){
        Contact contactRecord = [select id, Email_Lendwithcare_Opt_Out__c,Email_Donor_Updates_Opt_Out__c,
                                 Email_Feb_Appeal_Opt_Out__c, Email_Sept_Appeal_Opt_Out__c, 
                                 Email_Tax_Appeal_Opt_Out__c, Email_Xmas_Appeal_Opt_Out__c,
                                 Email_Follow_up_appeals_Opt_Out__c, Email_CAREgifts_Opt_Out__c,
                                 Email_Emergencies_Opt_Out__c, Bequest_Opt_Out__c,
                                 Email_All_Solicitations_Opt_Out__c, DM_Donor_Updates_Opt_Out__c,
                                 DM_Feb_Appeal_Opt_Out__c, DM_Sept_Appeal_Opt_Out__c,
                                 DM_Tax_Appeal_Opt_Out__c, DM_Xmas_Appeal_Opt_Out__c,
                                 DM_Follow_up_Appeals_Opt_Out__c, DM_CAREgifts_Opt_Out__c,
                                 DM_Emergencies_Opt_Out__c, DM_All_Solicitations_Opt_Out__c,
                                 Survey_Opt_Out__c from Contact where id=:rec.Id];
        
        if(rec.Email_Lendwithcare_Opt_Out__c == false){
            contactRecord.Email_Lendwithcare_Opt_Out__c = false;
            contactRecord.Email_Donor_Updates_Opt_Out__c = false;
            contactRecord.Email_Feb_Appeal_Opt_Out__c = false;
            contactRecord.Email_Sept_Appeal_Opt_Out__c = false;
            contactRecord.Email_Tax_Appeal_Opt_Out__c = false;
            contactRecord.Email_Xmas_Appeal_Opt_Out__c = false;
            contactRecord.Email_Follow_up_appeals_Opt_Out__c = false;
            contactRecord.Email_CAREgifts_Opt_Out__c = false;
            contactRecord.Email_Emergencies_Opt_Out__c = false;
            contactRecord.Bequest_Opt_Out__c = false;
            contactRecord.Email_All_Solicitations_Opt_Out__c = false; 
            contactRecord.DM_Donor_Updates_Opt_Out__c = false;
            contactRecord.DM_Feb_Appeal_Opt_Out__c = false;
            contactRecord.DM_Sept_Appeal_Opt_Out__c = false;
            contactRecord.DM_Tax_Appeal_Opt_Out__c = false;
            contactRecord.DM_Xmas_Appeal_Opt_Out__c = false;
            contactRecord.DM_Follow_up_Appeals_Opt_Out__c = false;
            contactRecord.DM_CAREgifts_Opt_Out__c = false;
            contactRecord.DM_Emergencies_Opt_Out__c = false;
            contactRecord.DM_All_Solicitations_Opt_Out__c = false;
            contactRecord.Survey_Opt_Out__c = false;
        }
        else if(rec.Email_Lendwithcare_Opt_Out__c == true){
            contactRecord.Email_Lendwithcare_Opt_Out__c = true;
            contactRecord.Email_Donor_Updates_Opt_Out__c = true;
            contactRecord.Email_Feb_Appeal_Opt_Out__c = true;
            contactRecord.Email_Sept_Appeal_Opt_Out__c = true;
            contactRecord.Email_Tax_Appeal_Opt_Out__c = true;
            contactRecord.Email_Xmas_Appeal_Opt_Out__c = true;
            contactRecord.Email_Follow_up_appeals_Opt_Out__c = true;
            contactRecord.Email_CAREgifts_Opt_Out__c = true;
            contactRecord.Email_Emergencies_Opt_Out__c = true;
            contactRecord.Bequest_Opt_Out__c = true;
            contactRecord.Email_All_Solicitations_Opt_Out__c = true; 
            contactRecord.DM_Donor_Updates_Opt_Out__c = true;
            contactRecord.DM_Feb_Appeal_Opt_Out__c = true;
            contactRecord.DM_Sept_Appeal_Opt_Out__c = true;
            contactRecord.DM_Tax_Appeal_Opt_Out__c = true;
            contactRecord.DM_Xmas_Appeal_Opt_Out__c = true;
            contactRecord.DM_Follow_up_Appeals_Opt_Out__c = true;
            contactRecord.DM_CAREgifts_Opt_Out__c = true;
            contactRecord.DM_Emergencies_Opt_Out__c = true;
            contactRecord.DM_All_Solicitations_Opt_Out__c = true;
            contactRecord.Survey_Opt_Out__c = true;
        }
        
        update contactRecord;
        
    }
    @AuraEnabled(cacheable=true)
    public static Decimal getMinOtherCurrency(){
        try {
            List<LWC_Config_Setting__mdt> LWCConfigSettings = [SELECT Change_Champion_Minimum_Other_Currency__c FROM LWC_Config_Setting__mdt WHERE DeveloperName = 'LWC_Global'];
            if( LWCConfigSettings.size() > 0 ){
                return LWCConfigSettings[0].Change_Champion_Minimum_Other_Currency__c;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static void updateAutoRelend( Id contactId, Boolean enable ) {
        List<Contact> conts = [SELECT Id,Auto_Relend__c FROM Contact WHERE Id = :contactId LIMIT 1];
        if( conts.size()>0 ){
            conts[0].Auto_Relend__c = enable;
            Database.UPDATE( conts[0]);
            //return 'Success';
        }
        // return 'Error';
        
    }
    @AuraEnabled(cacheable=true)
    public static User getCurrentUser() {
        try{
            //return null;
            return [SELECT Id, Name, Contact.Id, Contact.Name, Contact.Champion__c, Contact.Email FROM User WHERE Id = :UserInfo.getUserId()];
        } catch (Exception e) { 
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Cart__c getRDCurrentUser(string conId) {
        try{
            return [SELECT Id, Is_Having_RD__c FROM Cart__c WHERE Contact__c = :conId];
        } catch (Exception e) {
            return null;
        }
    }
    @AuraEnabled
    public static Transaction__c createVDTransaction(Transaction__c rec) {
        
        Cart__c cartRecord = new Cart__c();
        if(rec.Lender__c != null){
            cartRecord = [select id from Cart__c where Contact__c=:rec.Lender__c limit 1];                
        }
        else{
            cartRecord = [select id from Cart__c where Contact__c=null limit 1];
        }
        
        Cart_Items__c cartItemsRecord = new Cart_Items__c();
        cartItemsRecord.Cart__c = cartRecord.id;
        if(rec.Lender__c != null){
            cartItemsRecord.Lender__c = rec.Lender__c;
        }
        if(rec.Loan__c != null){
            cartItemsRecord.Loan__c = rec.Loan__c;
        }
        cartItemsRecord.Type__c = rec.Type__c;
        cartItemsRecord.Amount__c = rec.Amount__c;
        try{
            insert cartItemsRecord;   
            Cart_Items__c cartItem = [select id, CreatedDate from Cart_Items__c where id=:cartItemsRecord.Id];
            Datetime createdDateTime = cartItem.CreatedDate;
            system.debug('createdDateTime '+createdDateTime);
            Cart__c cart = [select id,Last_Transaction_DateTime__c from Cart__c where Id=:cartItemsRecord.Cart__c];
            cart.Last_Transaction_DateTime__c = createdDateTime;
            update cart;
        }
        catch(Exception error){
            System.debug('error creating cart items '+ error);
        }
        
        
        
        rec.Status__c = 'Held';
        //rec.Completed_Date__c = System.today();
        rec.Added_To_Cart__c = true;
        if(cartItemsRecord.id != null){
            rec.Cart_Items__c = cartItemsRecord.id;
        }
        
        upsert rec; 
        return rec;
    }
    
    @AuraEnabled
    public static String getAlert() {
        List<LWC_Alert__c> eAlerts = [Select Id, Message__c, StartDateTime__c, EndDateTime__c, Status__c From LWC_Alert__c Where Status__c='Active' AND StartDateTime__c <=: System.Now() AND EndDateTime__c >=: System.Now()];
        if( !eAlerts.isEmpty() && eAlerts.size() > 0 ){
            return eAlerts[0].Message__c;
        }
        return null;
    }
    
    @AuraEnabled
    public static String getCreditCardDetail(Id contactId, Decimal amount) {
        DateTime todayDate = DateTime.now();
        DateTime oneYearEgo = todayDate.addYears(-1);
        Id lendOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get('LendWithCare').getRecordTypeId();
        List<Opportunity> opps = [SELECT Id, RecordTypeId, (SELECT Id, Refund_Reference_Number__c, Card_Number_Masked__c, npe01__Payment_Amount__c FROM npe01__OppPayment__r WHERE Refund_Reference_Number__c = '' AND npe01__Payment_Method__c = 'Credit Card' AND npe01__Paid__c = true AND CreatedDate >= :oneYearEgo ORDER By CreatedDate DESC) FROM Opportunity WHERE ContactId = :contactId AND RecordTypeId = :lendOppRecordType ORDER By CreatedDate DESC];
        String cardNumber;
        Decimal refundAmountCharge = 0;
        for(Opportunity opp: opps) {
            for(npe01__OppPayment__c payment: opp.npe01__OppPayment__r) {
                if(refundAmountCharge >= amount) {
                    break;
                }
                cardNumber = payment.Card_Number_Masked__c;
                refundAmountCharge += payment.npe01__Payment_Amount__c;
            }
        }
        
        return cardNumber;
    }
    
    @AuraEnabled
    public static void refundAndDonate(Id contactId, Decimal refundAmount, Decimal donateAmount, String cardNumber) {
        Decimal totalRefundAmount = refundAmount;
        boolean caseCreation=false;
        DateTime todayDate = DateTime.now();
        DateTime oneMonthEgo = todayDate.addDays(-30);
        
        List<Contact> contacts = [SELECT Id, Number_of_Refunds__c, Last_Refund_Date__c FROM Contact WHERE Id = :contactId];
        
        if (contacts[0].Number_of_Refunds__c >= 2 && refundAmount > 0) {
            createRefundCase(contactId,refundAmount);
            caseCreation=true;
            /* Integer dayDifference = System.today().daysBetween(Date.newInstance(contacts[0].Last_Refund_Date__c.year(), contacts[0].Last_Refund_Date__c.month(), contacts[0].Last_Refund_Date__c.day()));
if(dayDifference > 30) {
contacts[0].Number_of_Refunds__c = 0;
} else {
contacts[0].Number_of_Refunds__c = contacts[0].Number_of_Refunds__c + 1;
}
update contacts[0];*/
        } else {
            if(totalRefundAmount > 100) {
                createRefundCase(contactId,refundAmount);
                caseCreation=true;
            } else if(totalRefundAmount > 0 && totalRefundAmount <= 100) {
                DateTime oneYearEgo = todayDate.addYears(-1);
                Id lendOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get('LendWithCare').getRecordTypeId();
                List<Opportunity> opps = [SELECT Id, RecordTypeId, (SELECT Id, Refund_Reference_Number__c, Card_Number_Masked__c, npe01__Payment_Amount__c, npe01__Check_Reference_Number__c FROM npe01__OppPayment__r WHERE Refund_Reference_Number__c = '' AND npe01__Payment_Method__c = 'Credit Card' AND npe01__Paid__c = true AND CreatedDate >= :oneYearEgo AND Card_Number_Masked__c = :cardNumber ORDER By CreatedDate DESC) FROM Opportunity WHERE ContactId = :contactId AND RecordTypeId = :lendOppRecordType ORDER By CreatedDate DESC];
                
                Map<String, Decimal> refundCharges = new Map<String, Decimal>();
                Decimal refundAmountCharge = 0;
                
                for(Opportunity opp: opps) {
                    for(npe01__OppPayment__c payment: opp.npe01__OppPayment__r) {
                        if(refundAmountCharge >= refundAmount) {
                            break;
                        }
                        refundCharges.put(payment.npe01__Check_Reference_Number__c, payment.npe01__Payment_Amount__c);
                        refundAmountCharge += payment.npe01__Payment_Amount__c;
                    }
                }
                
                if(refundCharges.size() == 0) {
                    createRefundCase(contactId,refundAmount);
                    caseCreation=true;
                } else {
                    Map<String, Map<String, Object>> chargePaymentsToUpdate = new Map<String, Map<String, Object>>();
                    
                    for(String chargeId: refundCharges.keySet()) {
                        Decimal amountToRefund = 0;
                        
                        if(refundAmount >= 0) {
                            if(refundAmount > refundCharges.get(chargeId)) {
                                amountToRefund = refundCharges.get(chargeId);
                            } else {
                                amountToRefund = refundAmount;
                            }
                            refundAmount = refundAmount - amountToRefund;
                            
                            System.debug('chargeId -> ' + chargeId);
                            System.debug('charge amount -> ' + refundCharges.get(chargeId));
                            System.debug('amountToRefund -> ' + amountToRefund);
                            System.debug('refundAmount remaining -> ' + refundAmount);
                            
                            Map<String, String> requestParameters = new Map<String, String>();
                            requestParameters.put('amount', String.valueOf(Integer.valueOf(amountToRefund*100)));
                            requestParameters.put('charge', chargeId);
                            
                            HttpResponse refundResponse = StripeConnection.postRefund(createRequestBody(requestParameters));
                            
                            if(refundResponse.getStatusCode() == 200) {
                                Map<String, Object> refundWrapper = (Map<String, Object>) JSON.deserializeUntyped(refundResponse.getBody());
                                chargePaymentsToUpdate.put(chargeId, refundWrapper);
                            }
                        }
                    }
                    
                    for(String chargeId: chargePaymentsToUpdate.keySet()) {
                        Map<String, Object> refundWrapper= chargePaymentsToUpdate.get(chargeId);
                        npe01__OppPayment__c payment = [SELECT Id FROM npe01__OppPayment__c WHERE npe01__Check_Reference_Number__c = :chargeId];
                        payment.Refund_Reference_Number__c = String.valueOf(refundWrapper.get('id'));
                        if(String.valueOf(refundWrapper.get('status')) == 'succeeded') {
                            payment.Refund_Status__c = 'Processed';  
                        } 
                        update payment;
                    }
                    
                    Transaction__c refundtrans = new Transaction__c(
                        Lender__c = contactId,
                        Amount__c = totalRefundAmount,
                        Type__c = 'Withdrawal',
                        Completed_Date__c = system.today(),
                        Status__c = 'Completed',
                        Transaction_Date__c = System.now(),
                        Transaction_Reason__c = 'Refunded stripe charge ids ' + String.join(chargePaymentsToUpdate.keySet(), ',')
                    );
                    insert refundtrans;
                    
                    if(contacts[0].Number_of_Refunds__c != null) {
                        contacts[0].Number_of_Refunds__c = contacts[0].Number_of_Refunds__c + 1;
                    } else {
                        contacts[0].Number_of_Refunds__c = 1;
                    }
                    contacts[0].Last_Refund_Date__c = todayDate;
                    Database.DMLOptions dml = new Database.DMLOptions(); 
                    dml.DuplicateRuleHeader.AllowSave = true;
                    Database.SaveResult sr=Database.update(contacts[0], dml);
                }
            } 
        }
        
        if(donateAmount > 0) {
            Transaction__c trans = new Transaction__c(
                Lender__c = contactId,
                Amount__c = donateAmount,
                Type__c = 'Donation'
            );
            
            donateFromDashboard(trans);
        }
    }
    
    
    @AuraEnabled
    public static void createRefundCase(Id contactId, Decimal refundAmount) {
        Id RefundRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Withdrawal').getRecordTypeId();  
        
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
        
        Case newCase = new Case(
            ContactId = contactId,
            Status = 'Open',
            Type = 'Withdrawal',
            Withdrawal_Amount__c=refundAmount,
            RecordTypeId = RefundRecordTypeId,
            CurrencyIsoCode = 'AUD',
            Priority = 'High',
            AccountId = con.AccountId,
            Subject = 'Lender has requested withdrawal.',
            Origin = 'Web'
        );
        insert newCase;
    }
    
    private static String createRequestBody(Map<String, String> requestParameters) {
        String requestBody = '';
        for(String key: requestParameters.keySet()) {
            String value = requestParameters.get(key);
            if(String.isEmpty(requestBody) && value.trim().length() > 0 && value != null){
                requestBody += key + '=' + value;
            }else{
                requestBody += '&' + key + '=' + value;
            }
        }
        return requestBody;
    }
    //Profile
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        System.debug('File Data : '+base64+'File Name : '+filename+'Record Id : '+recordId);
        List<ContentDocumentLink> oldContentDocumentLink=[SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId];
        set<Id> oldContentDocumentsIds=new set<Id>();
        for(ContentDocumentLink contentDocumentLink:oldContentDocumentLink){
            oldContentDocumentsIds.add(contentDocumentLink.ContentDocumentId);
        }
        List<ContentDocument> oldContentDocuments=[SELECT Id, Title FROM ContentDocument WHERE Id=:oldContentDocumentsIds AND Title LIKE '%Profile%'];
        if(oldContentDocuments.size() > 0){
            System.debug('Old ContentDocument IDs : '+oldContentDocuments);
            delete oldContentDocuments;
        }
        
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        if( cdl!=null ){
            List<ContentDistribution> cds = [SELECT ContentDownloadUrl, ContentDocumentId FROM ContentDistribution 
                                             WHERE ContentDocumentId =:cdl.ContentDocumentId
                                            ];
            if( !cds.isEmpty() && cds.size() > 0 ){
                Contact c = new Contact( Id = recordId, Profile_Picture__c = cds[0].ContentDownloadUrl );
                UPDATE c;
            }
            return cds[0].ContentDownloadUrl;
        }
        return cv.Title;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static void updateContactPostalAndMobile(String contactId, String mobilePhone, String mailingPostalCode,Boolean termsAndConditions) {
        try {
            
            if (String.isNotBlank(contactId)) {
                Contact contactToUpdate = [SELECT Id, MobilePhone, MailingPostalCode,Terms_and_conditions__c FROM Contact WHERE Id = :contactId LIMIT 1];
                
                if (contactToUpdate != null) {
                    if (String.isNotBlank(mobilePhone)) {
                        contactToUpdate.MobilePhone = mobilePhone;
                    }
                    
                    if (String.isNotBlank(mailingPostalCode)) {
                        contactToUpdate.MailingPostalCode = mailingPostalCode;
                    }

                    if(termsAndConditions==true){
                        contactToUpdate.Terms_and_conditions__c=termsAndConditions;
                    }
                    
                    update contactToUpdate;
                } else {
                    System.debug('Contact not found with Id: ' + contactId);
                }
            } else {
                System.debug('Invalid contactId');
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getUserEmail() {
        return UserInfo.getUserEmail();
    }
}