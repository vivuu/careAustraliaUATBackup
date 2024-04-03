/**
 * Class Name: StripeWebhookPaymentIntent
 * Auhtor: Gerent Team
 * Description: update PaymentIntent from stripe to salesforce
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */
@RestResource(urlMapping='/api/webhooks/PaymentIntent')
global without sharing class StripeWebhookPaymentIntent {
    @HttpPost
    global static void handlePayment(){
        // Get's the data from stripe to salesforce (contact object)
        try{
            if(Stripe_Setting__c.getValues('Default').Activation__c){
                map<String, String> declineCodeMap = new map<String, String>();
                list<Stripe_Decline_Code__mdt> declineCodes = [Select Id, DeveloperName, PAYMENT_RESULT__c From Stripe_Decline_Code__mdt];
                if(declineCodeMap != null && declineCodeMap.size()>0){
                    for(Stripe_Decline_Code__mdt dc: declineCodes){
                        declineCodeMap.put(dc.DeveloperName, dc.PAYMENT_RESULT__c);
                    }
                }
                
                Id donationRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
            	RestRequest request = RestContext.request;
                RestResponse response = RestContext.response;
                //Deserializing the request from Stripe
                StripePaymentIntentWrapper wrapperResponse = StripePaymentIntentWrapper.parse(request.requestBody.toString());
                //check if contact is present in salesforce
                if(String.isNotEmpty(wrapperResponse.data.object_z.customer)){
                    system.debug('###### + ' + wrapperResponse.data.object_z.customer);
                    String accountId=null;
                    Contact resultContact = new Contact();
                    List<Contact> contactRec = [SELECT Id, Name, AccountId, (SELECT Id, Amount, Last_Payment_Date__c, CloseDate FROM Opportunities Where StageName='Pledged' ORDER BY LastModifiedDate DESC) FROM Contact WHERE stripe_customer_id__c =: wrapperResponse.data.object_z.customer LIMIT 1];
                    List<Campaign> campaignRec = [SELECT Id FROM Campaign WHERE Campaign_Code__c =: wrapperResponse.data.object_z.metadata.campaign_code LIMIT 1];
                    if(contactRec.isEmpty()){
                        HttpResponse customerResponse = StripeConnection.getCustomer(wrapperResponse.data.object_z.customer, null);
                        if(customerResponse.getStatusCode() == 200 || customerResponse.getStatusCode() == 200){
                            StripeGetCustomerWrapper customerWrapper = StripeGetCustomerWrapper.parse(customerResponse.getBody());
                            if(String.isNotEmpty(customerWrapper.email) || String.isNotEmpty(customerWrapper.phone)){
                                contactRec = [Select id, Name, AccountId, Stripe_Customer_Id__c, Stripe_Customer_Ids__c, LastModifiedDate  FROM Contact WHERE (Name =: customerWrapper.name AND Phone =: customerWrapper.phone) OR (Name =: customerWrapper.name AND Email =: customerWrapper.email)];    
                            }   
                        }
                    }
                    
                    if(!contactRec.isEmpty()){
                        resultContact=contactRec[0];
                        accountId=contactRec[0].AccountId;
                    }else{
                        String defaultConId=Stripe_Setting__c.getValues('Default').Default_Contact__c;
                        if(defaultConId != null && defaultConId.trim().length()>0){
                            resultContact=[Select Id, Name, AccountId From Contact Where Id=:defaultConId limit 1];
                            accountId=resultContact.AccountId;
                        }
                    }
                    
                    String contactId = resultContact.Id;
                    String campaignId = !campaignRec.isEmpty() ? campaignRec[0].id : Stripe_Setting__c.getValues('Default').Default_Campaign__c;
                    List<npe01__OppPayment__c> paymentList;
                    // create a opportunity
                    List<Opportunity> oppList = [SELECT Id, Amount, StageName, CloseDate, (SELECT Id FROM npe01__OppPayment__r LIMIT 1), npe03__Recurring_Donation__c FROM Opportunity WHERE stripe_pi_id__c =: wrapperResponse.data.object_z.payment_intent AND stripe_pi_id__c != null LIMIT 1];
                    If(oppList.isEmpty()){
              			paymentList = [SELECT Id, npe01__Opportunity__c, npe01__Opportunity__r.Amount, npe01__Opportunity__r.StageName, npe01__Opportunity__r.CloseDate, npe01__Opportunity__r.npe03__Recurring_Donation__c FROM npe01__OppPayment__c WHERE Stripe_Charge_ID__c =: wrapperResponse.data.object_z.id AND Stripe_Charge_ID__c != null LIMIT 1];                    
                    }
                    if(oppList != null && oppList.size()>0){
                        //String.isNotEmpty(wrapperResponse.data.object_z.payment_intent)
                        if(!oppList.isEmpty()){
                            oppList[0].Amount = (Decimal)wrapperResponse.data.object_z.amount/100;
                            
                            if(wrapperResponse.data.object_z.status == 'succeeded'){
                                oppList[0].StageName = 'Closed Won';
                                oppList[0].CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                            }
                            else if(wrapperResponse.data.object_z.status == 'failed'){
                                oppList[0].StageName = 'Closed Lost';
                                oppList[0].CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                            }
                            if(!oppList[0].npe01__OppPayment__r.isEmpty() && String.isNotEmpty(oppList[0].npe01__OppPayment__r[0].Id) && wrapperResponse.data.object_z.source != null && wrapperResponse.data.object_z.source.object_Z == 'card'){
                                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                                payment.id = oppList[0].npe01__OppPayment__r[0].Id;
                                payment.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                payment.npe01__Payment_Method__c = 'Credit Card';
                                payment.npe01__Check_Reference_Number__c = wrapperResponse.data.object_z.id;
                                payment.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                payment.npe01__Payment_Amount__c = (Decimal)wrapperResponse.data.object_z.amount/100;
                                payment.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                payment.npsp__Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                payment.npsp__Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                payment.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id; 
                                if(wrapperResponse.data.object_z.failure_code != null && wrapperResponse.data.object_z.failure_code.trim().length()>0){
                                    String declineCode=wrapperResponse.data.object_z.failure_code;
                                    payment.Response_Code__c=declineCode;
                                    if(declineCodeMap.containsKey(declineCode)){
                                        payment.Payment_Result__c=declineCodeMap.get(declineCode);
                                    }
                                }
                                payment.Merchant_Category__c = 'Stripe';
                                payment.stripe_charge_id__c = wrapperResponse.data.object_z.id;
                                update payment;
                            } 
                            else if(!oppList[0].npe01__OppPayment__r.isEmpty() && String.isNotEmpty(oppList[0].npe01__OppPayment__r[0].Id) && wrapperResponse.data.object_z.payment_method_details != null &&  wrapperResponse.data.object_z.payment_method_details.card != null && wrapperResponse.data.object_z.payment_method_details.type == 'card'){
                                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                                payment.id = oppList[0].npe01__OppPayment__r[0].Id;
                                payment.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.payment_method_details.card.last4);
                                payment.npe01__Payment_Method__c = 'Credit Card';
                                payment.npe01__Check_Reference_Number__c = wrapperResponse.data.object_z.id;
                                payment.Card_Type__c = wrapperResponse.data.object_z.payment_method_details.card.brand;
                                payment.npe01__Payment_Amount__c = (Decimal)wrapperResponse.data.object_z.amount/100;
                                payment.Card_Token__c = wrapperResponse.data.object_z.payment_method_details.card.fingerprint;
                                payment.npsp__Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.payment_method_details.card.exp_month);
                                payment.npsp__Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.payment_method_details.card.exp_year);
                                payment.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.payment_method;
                                if(wrapperResponse.data.object_z.failure_code != null && wrapperResponse.data.object_z.failure_code.trim().length()>0){
                                    String declineCode=wrapperResponse.data.object_z.failure_code;
                                    payment.Response_Code__c=declineCode;
                                    if(declineCodeMap.containsKey(declineCode)){
                                        payment.Payment_Result__c=declineCodeMap.get(declineCode);
                                    }
                                }
                                payment.Merchant_Category__c = 'Stripe';
                                payment.stripe_charge_id__c = wrapperResponse.data.object_z.id;
                                update payment;
                            }
                            
                            if(String.isNotEmpty(oppList[0].npe03__Recurring_Donation__c) && wrapperResponse.data.object_z.source.object_Z == 'card'){
                                npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
                                rd.id = oppList[0].npe03__Recurring_Donation__c;
                                rd.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                rd.npsp__PaymentMethod__c = 'Credit Card';
                                rd.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                rd.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                rd.npsp__CardExpirationMonth__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                rd.npsp__CardExpirationYear__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                rd.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.id;
                                update rd;
                            }
                            if(!oppList.isEmpty()){
                                update oppList;
                            }
                        }
                    }
                    else if(!paymentList.isEmpty()){
                        Opportunity opp = new Opportunity();
                        if(String.isNotEmpty(paymentList[0].npe01__Opportunity__c)){
                            opp.id = paymentList[0].npe01__Opportunity__c;
                        }
                        opp.Amount = (Decimal)wrapperResponse.data.object_z.amount/100;
                        if(wrapperResponse.data.object_z.status == 'succeeded'){
                            opp.StageName = 'Closed Won';
                            opp.CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                        }
                        else if(wrapperResponse.data.object_z.status == 'failed'){
                            opp.StageName = 'Closed Lost';
                            opp.CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                        }
                        if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                            npe01__OppPayment__c payment = new npe01__OppPayment__c();
                            payment.id = oppList[0].npe01__OppPayment__r[0].Id;
                            payment.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                            payment.npe01__Payment_Method__c = 'Credit Card';
                            payment.npe01__Check_Reference_Number__c = wrapperResponse.data.object_z.id;
                            payment.Response_Code__c = '200';
                            payment.npe01__Payment_Amount__c = (Decimal)wrapperResponse.data.object_z.amount/100;
                            payment.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                            payment.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                            payment.npsp__Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                            payment.npsp__Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                            payment.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                            payment.Merchant_Category__c = 'Stripe';
                            if(wrapperResponse.data.object_z.failure_code != null && wrapperResponse.data.object_z.failure_code.trim().length()>0){
                                String declineCode=wrapperResponse.data.object_z.failure_code;
                                payment.Response_Code__c=declineCode;
                                if(declineCodeMap.containsKey(declineCode)){
                                    payment.Payment_Result__c=declineCodeMap.get(declineCode);
                                }
                            }
                            payment.stripe_charge_id__c = wrapperResponse.data.object_z.id;
                            update payment;
                        }
                        if(String.isNotEmpty(opp.npe03__Recurring_Donation__c) && wrapperResponse.data.object_z.source.object_Z == 'card'){
                            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
                            rd.id = oppList[0].npe03__Recurring_Donation__c;
                            rd.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                            rd.npsp__PaymentMethod__c = 'Credit Card';
                            rd.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                            rd.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                            rd.npsp__CardExpirationMonth__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                            rd.npsp__CardExpirationYear__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                            rd.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.id;
                            update rd;
                        }
                        update opp;
                    }
                    else if(!contactRec.isEmpty() && !contactRec[0].Opportunities.isEmpty() && ((contactRec[0].Opportunities[0].Amount != (Decimal)wrapperResponse.data.object_z.amount/100) || (contactRec[0].Opportunities[0].CloseDate !=  DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date()))){
                        if( wrapperResponse.data.object_z.status == 'succeeded' && wrapperResponse.data.object_z.captured == true){
                            Opportunity opp = new Opportunity();
                            if(wrapperResponse.data.object_z.metadata != null && String.isNotEmpty(wrapperResponse.data.object_z.metadata.isRecurring) && wrapperResponse.data.object_z.metadata.isRecurring.toLowerCase() == 'true'){
                                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
                            }
                            else{
                                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
                            }
                            opp.CampaignId = campaignId;
                            opp.ContactId = contactId;
                            opp.AccountId=accountId;
                            opp.Type='One-Off Gift';
                            opp.Name = contactRec[0].Name + ' ' + String.valueOf(date.today());
                            opp.Amount = (Decimal)wrapperResponse.data.object_z.amount/100;
                            opp.StageName = 'Closed Won';
                            opp.CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                            opp.stripe_pi_id__c = wrapperResponse.data.object_z.payment_intent;
                            if(wrapperResponse.data.object_z.metadata != null && wrapperResponse.data.object_z.metadata.donation_source != null){
                                opp.Donation_Source__c = wrapperResponse.data.object_z.metadata.donation_source;
                            }else{
                                opp.Donation_Source__c = 'Phone';
                            }
                            if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                opp.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                opp.Payment_Method__c = 'Credit Card';
                                opp.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                opp.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                opp.Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                opp.Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                opp.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                            }
                            insert opp;
                            system.debug(opp.id);
                            if(String.isNotEmpty(opp.id)){
                                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                                payment.npe01__Opportunity__c = opp.id;
                                payment.Merchant_Category__c = 'Stripe';
                                payment.npe01__Payment_Date__c = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                                payment.npe01__Payment_Amount__c = (Decimal)wrapperResponse.data.object_z.amount/100;
                                payment.stripe_charge_id__c = wrapperResponse.data.object_z.id;
                                payment.Response_Code__c = '200';
                                payment.npe01__Check_Reference_Number__c = wrapperResponse.data.object_z.id;
                                if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                    payment.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                    payment.npe01__Payment_Method__c = 'Credit Card';
                                    payment.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                    payment.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                    payment.npsp__Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                    payment.npsp__Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                    payment.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                                }
                                payment.npe01__Paid__c = true;
                                payment.Payment_Result__c = 'Success';
                                insert payment;
                            } 
                        }
                    } 
                    else if(!contactRec.isEmpty() && contactRec[0].Opportunities.isEmpty()){
                        if( wrapperResponse.data.object_z.status == 'succeeded' && wrapperResponse.data.object_z.captured == true){
                            Opportunity opp = new Opportunity();
                            if(wrapperResponse.data.object_z.metadata != null && String.isNotEmpty(wrapperResponse.data.object_z.metadata.isRecurring) && wrapperResponse.data.object_z.metadata.isRecurring.toLowerCase() == 'true'){
                                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
                                opp.type = 'Regular Giving';
                            }
                            else{
                                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
                            }
                            opp.CampaignId = campaignId;
                            opp.ContactId = contactId;
                            opp.AccountId=accountId;
                            opp.Type='One-Off Gift';
                            opp.Name = contactRec[0].Name + ' ' + String.valueOf(date.today());
                            opp.Amount = (Decimal)wrapperResponse.data.object_z.amount/100;
                            opp.StageName = 'Closed Won';
                            opp.CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                            opp.stripe_pi_id__c = wrapperResponse.data.object_z.payment_intent;
                            if(wrapperResponse.data.object_z.metadata != null && wrapperResponse.data.object_z.metadata.donation_source != null){
                                opp.Donation_Source__c = wrapperResponse.data.object_z.metadata.donation_source;
                            }else{
                                opp.Donation_Source__c = 'Phone';
                            }
                            if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                opp.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                opp.Payment_Method__c = 'Credit Card';
                                opp.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                opp.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                opp.Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                opp.Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                opp.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                            }
                            insert opp;
                            system.debug(opp.id);
                            if(String.isNotEmpty(opp.id)){
                                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                                payment.npe01__Opportunity__c = opp.id;
                                payment.npe01__Payment_Date__c = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                                payment.stripe_charge_id__c = wrapperResponse.data.object_z.id;
                                payment.npe01__Payment_Amount__c = (Decimal)wrapperResponse.data.object_z.amount/100;
                                payment.npe01__Check_Reference_Number__c = wrapperResponse.data.object_z.id;
                                payment.Response_Code__c = '200';
                                payment.Merchant_Category__c = 'Stripe';
                                if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                    payment.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                    payment.npe01__Payment_Method__c = 'Credit Card';
                                    payment.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                    payment.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                    payment.npsp__Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                    payment.npsp__Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                    payment.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                                }
                                payment.npe01__Paid__c = true;
                                payment.Payment_Result__c = 'Success';
                                insert payment;
                            } 
                        }
                    }
                    else if(contactRec.isEmpty()){
                        if( wrapperResponse.data.object_z.status == 'succeeded' && wrapperResponse.data.object_z.captured == true){
                            Opportunity opp = new Opportunity();
                            if(wrapperResponse.data.object_z.metadata != null && String.isNotEmpty(wrapperResponse.data.object_z.metadata.isRecurring) && wrapperResponse.data.object_z.metadata.isRecurring.toLowerCase() == 'true'){
                                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
                                opp.type = 'Regular Giving';
                            }
                            else{
                                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
                            }
                            opp.CampaignId = campaignId;
                            opp.ContactId = contactId;
                            opp.AccountId=accountId;
                            opp.Name = 'Default Contact';
                            opp.Type='One-Off Gift';
                            opp.Amount = (Decimal)wrapperResponse.data.object_z.amount/100;
                            opp.StageName = 'Closed Won';
                            opp.CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                            opp.stripe_pi_id__c = wrapperResponse.data.object_z.payment_intent;
                            if(wrapperResponse.data.object_z.metadata != null && wrapperResponse.data.object_z.metadata.donation_source != null){
                                opp.Donation_Source__c = wrapperResponse.data.object_z.metadata.donation_source;
                            }else{
                                opp.Donation_Source__c = 'Phone';
                            }
                            if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                opp.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                opp.Payment_Method__c = 'Credit Card';
                                opp.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                opp.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                opp.Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                opp.Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                opp.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                            }
                            insert opp;
                            system.debug(opp.id);
                            if(String.isNotEmpty(opp.id)){
                                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                                payment.npe01__Opportunity__c = opp.id;
                                payment.npe01__Payment_Date__c = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                                payment.npe01__Payment_Amount__c = (Decimal)wrapperResponse.data.object_z.amount/100;
                                payment.stripe_charge_id__c = wrapperResponse.data.object_z.id;
                                payment.Response_Code__c = '200';
                                payment.npe01__Check_Reference_Number__c = wrapperResponse.data.object_z.id;
                                if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                    payment.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                    payment.npe01__Payment_Method__c = 'Credit Card';
                                    payment.Merchant_Category__c = 'Stripe';
                                    payment.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                    payment.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                    payment.npsp__Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                    payment.npsp__Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                    payment.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                                }
                                payment.npe01__Paid__c = true;
                                payment.Payment_Result__c = 'Success';
                                insert payment;
                            } 
                        }
                    }
                }else{
                    String contactId = Stripe_Setting__c.getValues('Default').Default_Contact__c;
                    String accountId=null;
                    if(contactId != null && contactId.trim().length()>0){
                        list<Contact> resultContact=[Select Id, Name, AccountId From Contact Where Id=:contactId limit 1];
                        accountId=resultContact[0].AccountId;
                    }
                    String campaignId = Stripe_Setting__c.getValues('Default').Default_Campaign__c;
                    if( wrapperResponse.data.object_z.status == 'succeeded' && wrapperResponse.data.object_z.captured == true){
                        Opportunity opp = new Opportunity();
                        if(wrapperResponse.data.object_z.metadata != null && String.isNotEmpty(wrapperResponse.data.object_z.metadata.isRecurring) && wrapperResponse.data.object_z.metadata.isRecurring.toLowerCase() == 'true'){
                        	opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recurring Donation').getRecordTypeId();
                            opp.type = 'Regular Giving';
                        }
                        else{
                            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
                        }
                        opp.CampaignId = campaignId;
                        opp.ContactId = contactId;
                        opp.AccountId=accountId;
                        opp.Name = 'Default Contact';
                        opp.Type='One-Off Gift';
                        opp.Amount = (Decimal)wrapperResponse.data.object_z.amount/100;
                        opp.StageName = 'Closed Won';
                        opp.CloseDate = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                        opp.stripe_pi_id__c = wrapperResponse.data.object_z.payment_intent;
                        if(wrapperResponse.data.object_z.metadata != null && wrapperResponse.data.object_z.metadata.donation_source != null){
                            opp.Donation_Source__c = wrapperResponse.data.object_z.metadata.donation_source;
                            opp.type = 'Regular Giving';
                        }else{
                            opp.Donation_Source__c = 'Phone';
                        }
                        if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                opp.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                opp.Payment_Method__c = 'Credit Card';
                                opp.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                opp.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                opp.Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                opp.Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                opp.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                            }
                        insert opp;
                        system.debug(opp.id);
                        if(String.isNotEmpty(opp.id)){
                            npe01__OppPayment__c payment = new npe01__OppPayment__c();
                            payment.npe01__Opportunity__c = opp.id;
                            payment.Merchant_Category__c = 'Stripe';
                            payment.npe01__Payment_Date__c = DateTime.newInstance(Long.valueOf(wrapperResponse.data.object_z.created)*1000).date();
                            payment.stripe_charge_id__c = wrapperResponse.data.object_z.id;
                            payment.npe01__Payment_Amount__c = (Decimal)wrapperResponse.data.object_z.amount/100;
                            payment.Response_Code__c = '200';
                            payment.npe01__Check_Reference_Number__c = wrapperResponse.data.object_z.id;
                            if(wrapperResponse.data.object_z.source.object_Z == 'card'){
                                payment.Card_Number_Masked__c = ('************' + wrapperResponse.data.object_z.source.last4);
                                payment.npe01__Payment_Method__c = 'Credit Card';
                                payment.Card_Type__c = wrapperResponse.data.object_z.source.brand;
                                payment.Card_Token__c = wrapperResponse.data.object_z.source.fingerprint;
                                payment.npsp__Card_Expiration_Month__c = String.valueOf(wrapperResponse.data.object_z.source.exp_month);
                                payment.npsp__Card_Expiration_Year__c = String.valueOf(wrapperResponse.data.object_z.source.exp_year);
                                payment.Stripe_Payment_Method_Id__c = wrapperResponse.data.object_z.source.Id;    
                            }
                            payment.npe01__Paid__c = true;
                            payment.Payment_Result__c = 'Success';
                            insert payment;
                        } 
                    }
                }   
            }
        }
        catch(Exception e){
            system.debug(e);
            ApexLogCreator.createApexLog('StripeWebhookPaymentIntent', e.getMessage(), 'handlePayment', e.getStackTraceString());
        }   
    }
}