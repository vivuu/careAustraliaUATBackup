public without sharing class CheckoutUtility {
    static Decimal oppAmount = 0;
    static Decimal topUpBalanceAmount = 0;
    public static String lenderName;
            
    public static void processTransactionsAndPayment(List<Id> transactionIds, Contact con, Decimal usedLenderBalanceAmount, Map<String, Object> paymentResponse, String email) {
        oppAmount = 0; 
        topUpBalanceAmount = 0;
        String transactionList='';   
        List<Transaction__c> processTransactionRecords = new List<Transaction__c>();
        System.debug('In processTransactionsAndPayment');
        Map<Id, Transaction__c> transactionMapId = CheckoutUtility.processTransactions(transactionIds, con.Id, email, lenderName);
        processTransactionRecords.addAll(transactionMapId.values());
        List<Transaction__c> transToGetTopupRecords = [Select Id, Type__c From Transaction__c Where Id IN :transactionIds AND Type__c = 'Loan'];
        Boolean isOnlyTopup = false;
        if(transToGetTopupRecords.isEmpty()){
            isOnlyTopup = true;
        }
        Transaction__c handlingTopupTransaction = new Transaction__c();
        handlingTopupTransaction.Added_To_Cart__c = true;
        //handlingTopupTransaction.Amount__c = oppAmount - usedLenderBalanceAmount;
        handlingTopupTransaction.Amount__c = oppAmount - topUpBalanceAmount - usedLenderBalanceAmount;
        handlingTopupTransaction.Status__c = 'Completed';
        handlingTopupTransaction.Transaction_Reason__c = 'To balance the remaining lender balance';
        handlingTopupTransaction.Lender__c = con.Id;
        handlingTopupTransaction.Type__c = 'Payment';
        handlingTopupTransaction.Transaction_Date__c = DateTime.now();
        handlingTopupTransaction.Lender_Email__c = email;
        handlingTopupTransaction.Lender_Name__c = lenderName;
        handlingTopupTransaction.Completed_Date__c = DateTime.now();

        //Following condition specifies that handling amount is not required
        if(handlingTopupTransaction.Amount__c > 0 && !isOnlyTopup) {
            processTransactionRecords.add(handlingTopupTransaction);   
        }
        upsert processTransactionRecords;
        List<Transaction__c> tranv=[SELECT Id,Completed_Date__c FROM transaction__c WHERE ID In :transactionIds];
        for(Transaction__c t: tranv)
        {
            System.debug('Date completed'+t.Completed_Date__c);
			transactionList+=t.Id+',';            
        }
        transactionList=transactionList.substring(0,transactionList.length()-1);
        System.debug('transactionList-->'+transactionList);
        String templateName='MAD221 Thank you after transaction';
        EmailTemplate template = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE Name =: templateName LIMIT 1];
        System.debug('Contact from guest-->'+con);
        
        String relatedOpp;
        Map<String, Opportunity> oppMapWithTransactionId = createOpportunities(oppAmount, con, transactionMapId.values(),lenderName);

        LWC_CheckoutEmail.getPdfFileAsBase64String(con.Id,transactionList,'LWC Transaction PDF',template.Id,email,oppMapWithTransactionId.values()[0].id);        
        createOpportunityLineItem(transactionMapId, oppMapWithTransactionId);
        
        processPayment(oppMapWithTransactionId, oppAmount, usedLenderBalanceAmount, transactionMapId, paymentResponse);
        
        List<Transaction__c> transactions = new List<Transaction__c>();
        Id LendWithCareRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                      .get('LendWithCare').getRecordTypeId();
        Id DonationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                      .get('Donation').getRecordTypeId();
        System.System.debug('oppMapWithTransactionId 62 : '+oppMapWithTransactionId);
        for(String transStringId: oppMapWithTransactionId.keySet()) {
            Opportunity opp = oppMapWithTransactionId.get(transStringId);
            System.debug('opp 65 : '+opp);
            if(opp.RecordTypeId == LendWithCareRecordTypeId || opp.RecordTypeId == DonationRecordTypeId) {
                Id transId = transStringId.split('-T')[0];
                Transaction__c trans = transactionMapId.get(transId);
                if(opp.RecordTypeId == DonationRecordTypeId){
                    trans.Opportunity2__c = oppMapWithTransactionId.get(transStringId).Id;
                }
                else{
                    trans.Opportunity__c = oppMapWithTransactionId.get(transStringId).Id;
                }
                transactions.add(trans);   
            }
        }
        System.debug('transactions 73 : '+transactions);
        update transactions;
    }
    
    public static void processRD(Contact con, Decimal amount, Map<String, Object> cardResponse) {
        Stripe_Payment_Configs__mdt metadataRecords = [SELECT RD_Campaign__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
        String rdCampaign = metadataRecords.RD_Campaign__c;
        
        Map<String, Object> cardWrapper = (Map<String, Object>)cardResponse.get('card');
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(
            npe03__Contact__c=con.Id, 
            npe03__Amount__c=amount, 
            npe03__Recurring_Donation_Campaign__c=[SELECT Id FROM Campaign WHERE Campaign_Code__c = :rdCampaign LIMIT 1].Id, 
            npsp__StartDate__c=System.Today(), 
            npe03__Date_Established__c=System.Today(),
            CurrencyISOCode='AUD',
            npsp__Status__c='Active',
            Payment_Gateway__c='Stripe', 
            npsp__PaymentMethod__c='Credit Card',
            npsp__RecurringType__c='Open',
            npe03__Installment_Period__c='Weekly',
            npsp__InstallmentFrequency__c=4,
            Stripe_Payment_Method_Id__c =String.valueOf(cardWrapper.get('id')),
            npsp__CardExpirationMonth__c=String.valueOf(cardWrapper.get('exp_month')),
            npsp__CardExpirationYear__c= String.valueOf(cardWrapper.get('exp_year')), 
            npsp__CardLast4__c=String.valueOf(cardWrapper.get('last4')), 
            Card_Number_Masked__c='************' + String.valueOf(cardWrapper.get('last4')),
            Card_Type__c=(String) cardWrapper.get('brand')
        );
        
        insert rd;
        
        con.Champion__c = true;
        update con;
        
        StripeSubscriptionQueueable queueable = new StripeSubscriptionQueueable(con.Stripe_Customer_Id__c, rd, true);
        if(!Test.isRunningTest()) {
         	System.enqueueJob(queueable);   
        }
    }
     
    private static Map<Id, Transaction__c> processTransactions(List<Id> transactionIds, Id conId, String email, String lenderName) {
        topUpBalanceAmount = 0;
        Map<Id, Transaction__c> transactionMapId = new Map<Id, Transaction__c>([SELECT Id, Amount__c, Type__c, Name,Completed_Date__c,Lender_Name__c,Transaction_Fee__c FROM Transaction__c WHERE ID IN :transactionIds]);
        for(Transaction__c trans : transactionMapId.values()) {
            trans.Status__c = 'Completed';
            trans.Lender__c = conId;
            trans.Transaction_Date__c = DateTime.now();
            trans.Lender_Email__c = email;
            trans.Lender_Name__c = lenderName;
            trans.Completed_Date__c = DateTime.now();
            oppAmount += trans.Amount__c;
            if(trans.Type__c == 'Topup') {
                topUpBalanceAmount += trans.Amount__c;
            }
        }
        return transactionMapId;
    }
    
    private static Map<String, Opportunity> createOpportunities(Decimal oppAmount, Contact con, List<Transaction__c> transactions, String name) {
        Stripe_Payment_Configs__mdt metadataRecords = [SELECT Donation_Campaign__c, Lend_With_Care_Campaign__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
        String lendWithCareCampaign = metadataRecords.Lend_With_Care_Campaign__c;
        String donationCampaign = metadataRecords.Donation_Campaign__c;
        
        Map<String, Opportunity> oppMapWithTransactionId = new Map<String, Opportunity>();
        
        List<Opportunity> opportunities = new List<Opportunity>();
        
    	Opportunity loanOpp = getOpportunity(oppAmount, con);
        loanOpp.Amount = oppAmount;
        loanOpp.CampaignId = [SELECT Id FROM Campaign WHERE Campaign_Code__c = :lendWithCareCampaign LIMIT 1].Id;
        loanOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                      .get('LendWithCare').getRecordTypeId();
        loanOpp.Payee_Name__c = name;
        opportunities.add(loanOpp);
        
        Integer i = 0;
        for(Transaction__c trans: transactions) {
            if(trans.Type__c == 'Donation') {
                System.debug('trans : '+trans);
                System.debug('trans Transaction_Fee__c : '+trans.Transaction_Fee__c);
                Opportunity donationOpp = getOpportunity(trans.Amount__c, con);
                donationOpp.Amount = trans.Amount__c;
                donationOpp.Covered_transaction_costs__c = trans.Transaction_Fee__c;
                // donationOpp.Covered_transaction_costs__c = trans.Transaction_Fee__c;
                System.debug('Covered_transaction_costs__c : '+donationOpp.Covered_transaction_costs__c);
                donationOpp.CampaignId = [SELECT Id FROM Campaign WHERE Campaign_Code__c = :donationCampaign LIMIT 1].Id;
                donationOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                      .get('Donation').getRecordTypeId();
                
                opportunities.add(donationOpp);
                
                oppMapWithTransactionId.put(trans.Id + '-T' + i, donationOpp);
                i += 1;
            }
            else{
                oppMapWithTransactionId.put(trans.Id + '-T' + i, loanOpp);
                i += 1;
            }
        }
        
        insert opportunities;
        
        return oppMapWithTransactionId;
    }
    
    private static void createOpportunityLineItem(Map<Id, Transaction__c> transactionMapId, Map<String, Opportunity> oppMapWithTransactionId) {
        Stripe_Payment_Configs__mdt metadataRecords = [SELECT Donation_Product_Name__c, Loan_Product_Name__c, Topup_Product_Name__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
        String loanProductName = metadataRecords.Loan_Product_Name__c;
        String topUpProductName = metadataRecords.Topup_Product_Name__c;
        String donationProductName = metadataRecords.Donation_Product_Name__c;
        
        Product2 loanProduct = [SELECT Id FROM Product2 WHERE Name = :loanProductName][0];
        Product2 topUpProduct = [SELECT Id FROM Product2 WHERE Name = :topUpProductName][0];
        Product2 donationProduct = [SELECT Id FROM Product2 WHERE Name = :donationProductName][0];
        
        List<OpportunityLineItem> opplineItems = new List<OpportunityLineItem>();
        for(String transStringId: oppMapWithTransactionId.keySet()) {
            OpportunityLineItem lineItem = new OpportunityLineItem();
            
            Id transId = transStringId.split('-T')[0];
            Transaction__c trans = transactionMapId.get(transId);
            
            lineItem.OpportunityId = oppMapWithTransactionId.get(transStringId).Id;
            Boolean isDonationRecordWithZeroAmount = false;
            if(trans.Type__c == 'Loan') {
                lineItem.Product2Id = loanProduct.Id;
                lineItem.HIC_ShopifySync__SKU__c=trans.Name;
            } else if(trans.Type__c == 'Topup') {
                lineItem.Product2Id = topUpProduct.Id;
                lineItem.HIC_ShopifySync__SKU__c=trans.Name;
            } else if(trans.Type__c == 'Donation') {
                lineItem.HIC_ShopifySync__SKU__c=trans.Name;
                lineItem.Product2Id = donationProduct.Id;
            }
            
            lineItem.Quantity = trans.Amount__c;
            lineItem.UnitPrice = 1;

            opplineItems.add(lineItem);
        }
        
        insert opplineItems;
    }
    
    private static void processPayment(Map<String, Opportunity> oppMapWithTransactionId, Decimal oppAmount, Decimal usedLenderBalanceAmount, Map<Id, Transaction__c> transactionMapId, Map<String, Object> paymentResponse) {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp: oppMapWithTransactionId.values()) {
            oppIds.add(opp.Id);
        }
        
        Id lendOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                      .get('LendWithCare').getRecordTypeId();
        Id donationOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                      .get('Donation').getRecordTypeId();
        
        List<npe01__OppPayment__c> oppPayments = new List<npe01__OppPayment__c>();
        
        List<npe01__OppPayment__c> deleteOppPayments = new List<npe01__OppPayment__c>();
        
        for(Opportunity opp: [SELECT Id, RecordTypeId, (SELECT Id FROM npe01__OppPayment__r) FROM Opportunity WHERE Id IN :oppIds]) {
            npe01__OppPayment__c oppPayment = opp.npe01__OppPayment__r;
            oppPayment.npe01__Paid__c = true;
            oppPayment.CurrencyIsoCode = 'AUD';
            oppPayment.npe01__Payment_Date__c = System.today();
            oppPayment.Payment_Result__c = 'Success';
            
            if(opp.RecordTypeId == lendOppRecordType) {
                Decimal paymentAmount = oppAmount - usedLenderBalanceAmount;
                //Following condition will specifies that if user has used full lender balance
                //Which is enough to pay for the loan and donation
                //Also it will consider the topup type, if there is any topup then it will be considered to update payment amount
                if(paymentAmount > 0) {
                    oppPayment.npe01__Payment_Amount__c = oppAmount - usedLenderBalanceAmount;
                    String objectType = (String)paymentResponse.get('object');
                    
                    if(objectType == 'payment_intent') {
                        Map<String, Object> chargeMap = (Map<String, Object>) paymentResponse.get('charges');
                        List<Object> charges = (List<Object>) chargeMap.get('data');
                        Map<String, Object> chargeObject = (Map<String, Object>) charges[0];
                        setPaymentDetails(oppPayment, chargeObject);
                    } else if(objectType == 'charge') {
                        setPaymentDetails(oppPayment, paymentResponse);
                    } else if(objectType == 'paypal') {
                        oppPayment.npe01__Check_Reference_Number__c = (String) paymentResponse.get('id');
                        oppPayment.Merchant_Category__c = 'PayPal';
                        oppPayment.npe01__Payment_Method__c = 'PayPal';
                    }
                    
                    oppPayments.add(oppPayment);
                } else {
                    deleteOppPayments.add(oppPayment);
                }
                
                if(usedLenderBalanceAmount > 0) {
                 	npe01__OppPayment__c lenderBalanceOppPayment = new npe01__OppPayment__c();
                    lenderBalanceOppPayment.npe01__Paid__c = true;
                    lenderBalanceOppPayment.CurrencyIsoCode = 'AUD';
                    lenderBalanceOppPayment.npe01__Payment_Amount__c = usedLenderBalanceAmount;
                    lenderBalanceOppPayment.npe01__Opportunity__c = opp.Id;
                    lenderBalanceOppPayment.npe01__Payment_Date__c = System.today();
                    lenderBalanceOppPayment.npe01__Payment_Method__c = 'Lender Balance';
                    lenderBalanceOppPayment.Merchant_Category__c = 'LWC Transaction';
                    lenderBalanceOppPayment.Payment_Result__c = 'Success';
                    //lenderBalanceOppPayment.npe01__Check_Reference_Number__c = getTransactionName(oppMapWithTransactionId, transactionMapId, opp.Id);
                    
                    oppPayments.add(lenderBalanceOppPayment);   
                }
            } else if(opp.RecordTypeId == donationOppRecordType) {
            	oppPayment.npe01__Payment_Method__c = 'Internal Transfer';
                oppPayment.Merchant_Category__c = 'LWC Transaction';
                oppPayment.npe01__Check_Reference_Number__c = getTransactionName(oppMapWithTransactionId, transactionMapId, opp.Id);
                oppPayments.add(oppPayment);
            }
        }
        
        if(deleteOppPayments.size() > 0) {
            delete deleteOppPayments;
        }
        
        upsert oppPayments;
    }
    
    private static String getTransactionName(Map<String, Opportunity> oppMapWithTransactionId, Map<Id, Transaction__c> transactionMapId, Id oppId) {
        for(String transStringId: oppMapWithTransactionId.keySet()) {
            Opportunity opp = oppMapWithTransactionId.get(transStringId);
            if(opp.Id == oppId) {
                Id transId = transStringId.split('-T')[0];
                Transaction__c trans = transactionMapId.get(transId);
                return trans.Name;   
            }
        }
        return null;
    }
    
    public static void setPaymentDetails(npe01__OppPayment__c payment, Map<String, Object> chargeObject) {
        payment.npe01__Payment_Method__c = 'Credit Card';
        payment.Stripe_Payment_Method_Id__c = (String) chargeObject.get('payment_method');
        payment.npe01__Check_Reference_Number__c = (String) chargeObject.get('id');
        
        Map<String, Object> paymentMethodWrapper = (Map<String, Object>)chargeObject.get('payment_method_details');
        Map<String, Object> cardWrapper = (Map<String, Object>)paymentMethodWrapper.get('card');
        
        payment.Card_Type__c = (String) cardWrapper.get('brand');
        payment.Card_Token__c = (String) cardWrapper.get('fingerprint');
        payment.npsp__Card_Expiration_Month__c = String.valueOf(cardWrapper.get('exp_month'));
        payment.npsp__Card_Expiration_Year__c = String.valueOf(cardWrapper.get('exp_year'));
        payment.npsp__Card_Last_4__c = String.valueOf(cardWrapper.get('last4'));
        payment.Card_Number_Masked__c = '************' + payment.npsp__Card_Last_4__c;
        payment.Merchant_Category__c = 'Stripe';
    }
    
    private static Opportunity getOpportunity(Decimal oppAmount, Contact con) {
        Opportunity opp = new Opportunity();
        opp.Name = con.Name + ' $' + oppAmount;
        opp.AccountId = con.AccountId;
        opp.ContactId = con.Id;
        opp.CurrencyIsoCode = 'AUD';
        opp.CloseDate = Date.today();
        opp.StageName = 'Closed Won';
        opp.Donation_Source__c = 'Web';
        opp.Type = 'LWC';
        if(Test.isRunningTest()) {
            opp.Pricebook2Id = Test.getStandardPricebookId();
        } else {
            opp.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        }
        return opp;
    }
}