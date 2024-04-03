/**
* Class Name: StripeBatchGiftEntryCtrl
* Auhtor: Gerent Team
* Description: Used by Batch Gift Entry LWC
* Modification Details:  - 10/10/2022 - Initial version created
* Test Class and Coverage:  - StripeBatchGiftEntryCtrlTest - 93%
* */
    public with sharing class StripeBatchGiftEntryCtrl {
    @AuraEnabled
    public static Contact addCustomer(String contactJsonString) {
        try {        
            Contact con=(Contact) JSON.deserialize(contactJsonString, Contact.class);
            //System.debug('con'+con+' ==='+contactJsonString);
            insert con;
            return con;
        }catch(Exception ex) {
            throw new AuraHandledException('There is some error'+ex.getMessage()); 
        }       
    }
    
    @AuraEnabled
    public static Map<String,object> createPaymentRecords(String jsonString){
        Map<String,object> paramMap=new Map<String,object>();
        try {
            //List<ResponseWrapper> cardInfoRwList = (List<ResponseWrapper>) System.JSON.deserialize (cardInfo, List<ResponseWrapper>.class);
            List<processCardWrapper> rowRwList=(List<processCardWrapper>) System.JSON.deserialize (jsonString, List<processCardWrapper>.class);
            //System.debug('processCardWrapper'+cardInfoRw);
            //System.debug('rw'+rowRw);
            
            //paramMap.put('ResponseWrapper',cardInfoRw);
            paramMap.put('processCardWrapper',rowRwList);
            set<String> contactIds = new set<String>();
            map<String, Contact> contactsMap = new map<String, Contact>();
            Map<Integer,Opportunity> rowOpportunityIdMap=new Map<Integer,Opportunity>();
            List<npe03__Recurring_Donation__c> rdList = new List<npe03__Recurring_Donation__c>();
            List<Opportunity> oppList=new List<Opportunity>();

            map<String, Campaign> campaignsMap = new map<String, Campaign>();
            
            Set<ID> campaignIds = new Set<Id>();
            if(rowRwList != null && rowRwList.size()>0){
                for(processCardWrapper cardInfoRw:rowRwList){
                    if(cardInfoRw.contactId != null){
                        contactIds.add(cardInfoRw.contactId);
                    }
                    if( cardInfoRw.campaignId != null ){
                        campaignIds.add( cardInfoRw.campaignId );
                    }
                }
                
                if(contactIds != null && contactIds.size()>0){
                    contactsMap = new map<String, Contact>([Select Id, Name, AccountId, Account.Name, Stripe_Payment_Method_Id__c From Contact Where Id IN: contactIds]);
                    for(processCardWrapper cardInfoRw:rowRwList){
                        if(cardInfoRw.recurringId != null && cardInfoRw.recurringId.trim().length()>0){
                            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(Id=cardInfoRw.recurringId);
                            rd.npsp__PaymentMethod__c = 'Credit Card';
                            rd.Payment_Gateway__c='Stripe';
                            //rd.Card_Number_Masked__c=('************' +cardInfoRw.last4);
                            //rd.Card_Type__c = cardInfoRw.brand;
                            //rd.Card_Token__c = cardInfoRw.fingerprint;
                            //rd.Payee_Name__c = cardInfoRw.contactName;
                            //rd.npsp__CardExpirationMonth__c = String.valueOf(cardInfoRw.expiryMonth);
                            //rd.npsp__CardExpirationYear__c = String.valueOf(cardInfoRw.expiryYear);
                            rdList.add(rd);
                        }else{
                            Id donationRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
                            Opportunity opp=new Opportunity(RecordTypeId=donationRTId, Type='One-Off Gift', Donation_Source__c='Phone');        
                            opp.Card_Number_Masked__c=('************' +cardInfoRw.last4);
                            opp.Payment_Method__c = 'Credit Card';
                            opp.Payment_Gateway__c='Stripe';
                            opp.Name='OPP - BatchGiftEntry';
                            opp.Donation_Source__c='Mail';
                            opp.Amount = cardInfoRw.amount;
                            opp.Stripe_Payment_Method_Id__c = cardInfoRw.payMethodId;
                            /* if(contactsMap.containsKey(cardInfoRw.contactId)){
                                if(contactsMap.get(cardInfoRw.contactId).Stripe_Payment_Method_Id__c != null){
                            		opp.Stripe_Payment_Method_Id__c=contactsMap.get(cardInfoRw.contactId).Stripe_Payment_Method_Id__c;
                                }
                            } */
                            //opp.Card_Type__c = cardInfoRw.brand;
                            //opp.Card_Token__c = cardInfoRw.fingerprint;
                            //opp.Payee_Name__c = cardInfoRw.contactName;
                            //opp.Card_Expiration_Month__c = String.valueOf(cardInfoRw.expiryMonth);
                            //opp.Card_Expiration_Year__c = String.valueOf(cardInfoRw.expiryYear);
                            if(contactsMap.containsKey(cardInfoRw.contactId)){
                                String donationDate = '';
                                if( cardInfoRw.donationDate != null ){
                                    donationDate = String.valueOf(cardInfoRw.donationDate);
                                    if( donationDate.indexOf(' ') >= 0 ){
                                        donationDate = donationDate.substring( 0, donationDate.indexOf(' ') );
                                    }
                                }
                                opp.Name = contactsMap.get(cardInfoRw.contactId).Account.Name + ' Donation ' + donationDate;
                                opp.AccountId=contactsMap.get(cardInfoRw.contactId).AccountId;
                            }
                            opp.npsp__Primary_Contact__c=cardInfoRw.contactId;
                            if(cardInfoRw.campaignId!=null && cardInfoRw.campaignId!=''){
                                opp.CampaignId=cardInfoRw.campaignId;
                            }
                            opp.StageName='Pledged';
                            opp.CloseDate=System.today();
                            System.debug('npe03__Recurring_Donation__c'+cardInfoRw.recurringId);
                            if(cardInfoRw.recurringId!=null  && cardInfoRw.recurringId!=''){
                                opp.npe03__Recurring_Donation__c=cardInfoRw.recurringId;
                            }
                            rowOpportunityIdMap.put(cardInfoRw.serialNo,opp);
                            oppList.add(opp);
                        }
                    }
                }
                
                if(rdList != null && rdList.size()>0){
                    update rdList;
                }
                
                Map<String,String> oppIdPaymentIdMap=new Map<String,String>();
                if(oppList != null && oppList.size()>0){
                    insert oppList;
                    for(npe01__OppPayment__c exPayment:[Select Id,npe01__Opportunity__c from npe01__OppPayment__c where npe01__Opportunity__c IN :oppList]){
                        oppIdPaymentIdMap.put(exPayment.npe01__Opportunity__c,exPayment.Id);
                    }
                    paramMap.put('oppList', oppList);
                }
                
                List<npe01__OppPayment__c> paymentRecList=new List<npe01__OppPayment__c>();
                for(processCardWrapper cardInfoRw:rowRwList){
                    if(cardInfoRw.recurringId==null || cardInfoRw.recurringId.trim().length()==0){
                        if( campaignIds.size() > 0 ){
                            campaignsMap = new map<String, Campaign>([Select Id, AUS_Code__c, GAU__c From Campaign Where Id IN: campaignIds]);
                        }
                        String oppId=rowOpportunityIdMap.get(cardInfoRw.serialNo).Id; 
                        npe01__OppPayment__c paymentRec = new npe01__OppPayment__c();
                        if(oppIdPaymentIdMap.containsKey(oppId)){
                            paymentRec.Id=oppIdPaymentIdMap.get(oppId);
                        }else{
                            paymentRec.npe01__Opportunity__c=oppId;
                        }  
                        paymentRec.npe01__Payment_Date__c=cardInfoRw.donationDate;      
                        paymentRec.Payee_Name__c = cardInfoRw.contactName;
                        paymentRec.npe01__Payment_Method__c = 'Credit Card';
                        paymentRec.npe01__Payment_Amount__c = cardInfoRw.amount;
                        paymentRec.isGiftEnty__c=true;
                        paymentRec.Stripe_Payment_Method_Id__c = cardInfoRw.payMethodId;
                        
                        paymentRec.Merchant_Category__c = 'Stripe';
                        if( campaignsMap != null && campaignsMap.containsKey(cardInfoRw.campaignId)){
                            paymentRec.GAU__c = campaignsMap.get(cardInfoRw.campaignId).GAU__C;
                            paymentRec.AUS_Code__c = campaignsMap.get(cardInfoRw.campaignId).AUS_Code__c;

                        }
                        /* if(contactsMap.containsKey(cardInfoRw.contactId)){
                            if(contactsMap.get(cardInfoRw.contactId).Stripe_Payment_Method_Id__c != null){
                                paymentRec.Stripe_Payment_Method_Id__c=contactsMap.get(cardInfoRw.contactId).Stripe_Payment_Method_Id__c;
                            }
                        } */
                        paymentRec.Card_Number_Masked__c = ('************' + cardInfoRw.last4);
                        paymentRec.Card_Type__c = cardInfoRw.brand;
                        //paymentRec.Card_Token__c = cardInfoRw.fingerprint;
                        String expMon = String.valueOf(cardInfoRw.expiryMonth);
                        if( expMon.length() ==1 )   expMon='0'+expMon;                        
                        paymentRec.npsp__Card_Expiration_Month__c = expMon;
                        paymentRec.npsp__Card_Expiration_Year__c = String.valueOf(cardInfoRw.expiryYear);
                        //paymentRec.npe01__Check_Reference_Number__c = cardInfoRw.payMethodId;
                        paymentRecList.add(paymentRec);
                    }
                }
                if(paymentRecList != null && paymentRecList.size()>0){
                    upsert paymentRecList;
                    paramMap.put('PaymentList', paymentRecList);
                    Set<Id> payIds = new Set<Id>();
                    for( npe01__OppPayment__c payment : paymentRecList ){
                        payIds.add( payment.Id );
                    }
                    //Make payment
                    // makePayment( payIds );
                } 
            }
        } catch (Exception ex) {
            System.debug('Message'+ex.getMessage()+' Line No'+ ex.getLineNumber());
            paramMap.put('Error',' '+ex.getMessage());     
        }
        return paramMap;
    }
    @future(callout=true)
    public static void makePayment( Set<Id> payIds ){
       //Making payment in Stripe
       System.debug('PayRecs:'+[SELECT id, npe01__Payment_Amount__c, 
       npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c, 
       npe01__Opportunity__c, npsp__Card_Expiration_Month__c, npsp__Card_Expiration_Year__c,
       npsp__Card_Last_4__c, Card_Number_Masked__c, Card_Token__c, Stripe_Payment_Method_Id__c
       FROM npe01__OppPayment__c WHERE ID IN :payIds AND Stripe_Charge_ID__c = null 
       AND npe01__Payment_Method__c= 'Credit Card' AND 
       npe01__Paid__c=false AND isGiftEnty__c=true ORDER BY CreatedDate DESC]);
       StripePaymentBatchHandler.createPayment( [SELECT id, npe01__Payment_Amount__c, 
                                                npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c, 
                                                npe01__Opportunity__c, npsp__Card_Expiration_Month__c, npsp__Card_Expiration_Year__c,
                                                npsp__Card_Last_4__c, Card_Number_Masked__c, Card_Token__c, Stripe_Payment_Method_Id__c
                                                FROM npe01__OppPayment__c WHERE ID IN :payIds AND Stripe_Charge_ID__c = null 
                                                AND npe01__Payment_Method__c= 'Credit Card' AND 
                                                npe01__Paid__c=false AND isGiftEnty__c=true ORDER BY CreatedDate DESC] ); 
    }

    @AuraEnabled(cacheable=true)
    public static String getPicklistValues(String objectApiName, String fieldApiName){
        Schema.SObjectType objDescribe = Schema.getGlobalDescribe().get(objectApiName) ;
        Schema.DescribeSObjectResult objDescribeResult = objDescribe.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeResult.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
        list<Schema.PicklistEntry> options =fieldResult.getPickListValues();        
        String jsonString=JSON.serialize(options);
        return jsonString;
        
    }   

    public class processCardWrapper{
        @AuraEnabled        
        public String contactId;
        @AuraEnabled        
        public String contactName;
        @AuraEnabled        
        public String campaignId;
        @AuraEnabled        
        public String campaignName;
        @AuraEnabled        
        public String recurringId;
        @AuraEnabled        
        public String recurringName;
        @AuraEnabled        
        public date donationDate;
        @AuraEnabled        
        public double amount;
        @AuraEnabled        
        public String paymentMehtod;
        @AuraEnabled        
        public String checkRef;
        @AuraEnabled
        public String cardNumber;
        @AuraEnabled
        public String expiryYear;
        @AuraEnabled
        public String expiryMonth;
        @AuraEnabled
        public String idx;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String brand;
        @AuraEnabled
        public String last4;
        @AuraEnabled
        public String fingerprint;
        @AuraEnabled
        public Integer serialNo;
        @AuraEnabled
        public String cardId;
        @AuraEnabled
        public String payMethodId;
    }
}