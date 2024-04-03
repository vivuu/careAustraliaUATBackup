/**
* Class Name: StripeAddUpdateDDonRD
* Auhtor: Gerent Team
* Description: update payment method and Direct Debit information on RD/Opp/Payment and Sync the Subscripion in Stripe, 
*              Add Card in Stripe
* Modification Details: Devansh Jain - 07/10/2022 - Initial version created
* */
public class StripeAddUpdateDDonRD { 
    Private static String body = '';
    public static boolean started = false;
    @AuraEnabled
    public static String updatePaymentMethod(String bsb_number, String account_number, String name, String email, String rdId, String financialIns){
        try{
            //StripeDirectDebitPayMethodBatch.started = true;
            started = true;
            if( bsb_number.contains( '-' ) ){
                bsb_number=bsb_number.remove('-');
            }
            String finalRes = '';   //used to see if any error occur
            if(Stripe_Setting__c.getInstance('Default').Activation__c){
                list<String> paymentMethods = new list<String>();
                if(Label.Stripe_Payment_Methods != null && Label.Stripe_Payment_Methods.trim().length()>0){
                    if(Label.Stripe_Payment_Methods.contains(';')){
                        paymentMethods=Label.Stripe_Payment_Methods.split(';');
                    }else{
                        paymentMethods.add(Label.Stripe_Payment_Methods);
                    }
                }else{
                    paymentMethods.add('Credit Card');
                }
                if(paymentMethods.contains('Direct Debit')){
                    Contact resultContact;
                    if(!String.isEmpty(bsb_number) && !String.isEmpty(account_number) && !String.isEmpty(name) && !String.isEmpty(email) && !String.isEmpty(rdId)){
                        Boolean isPGSwitched=false;
                        list<npe03__Recurring_Donation__c> rdList = [Select Id, Name, Payment_Gateway__c, npsp__PaymentMethod__c,
                                                                     npsp__InstallmentFrequency__c, Financial_Institution__c,
                                                                     npe03__Contact__c, npe03__Contact__r.Stripe_Customer_Id__c,
                                                                     npe03__Amount__c, npsp__RecurringType__c, npsp__StartDate__c,
                                                                     npe03__Installments__c, npe03__Installment_Period__c, 
                                                                     npsp__Day_of_Month__c, npe03__Recurring_Donation_Campaign__c,
                                                                     npe03__Recurring_Donation_Campaign__r.Name,
                                                                     npe03__Recurring_Donation_Campaign__r.stripe_product_id__c,
                                                                     npe03__Recurring_Donation__c.Stripe_Subscription_Id__c,
                                                                     npe03__Recurring_Donation__c.npsp__Status__c,Account_BSB__c,
                                                                     Card_Token__c,Payee_Name__c, Account_Number__c
                                                                     From npe03__Recurring_Donation__c 
                                                                     Where Id=: rdId limit 1];
                        
                        
                        
                        if(rdList != null && rdList.size()>0){
                            npe03__Recurring_Donation__c rd = rdList[0];
                            if(rd.Payment_Gateway__c=='Bambora'){
                                isPGSwitched=true;
                            }
                            
                            list <Opportunity> oppList = new list<Opportunity>();
                            Opportunity opp = new Opportunity();
                            
                            list <npe01__OppPayment__c> payList = new list<npe01__OppPayment__c>();
                            npe01__OppPayment__c pay = new npe01__OppPayment__c();
                            
                            //Fetch Opportunity and payment records to update card details
                            if(rd != null && rd.Id != null){
                                oppList = [SELECT Id, StageName FROM Opportunity WHERE npe03__Recurring_Donation__c =: rd.Id ];
                                if(oppList != Null){
                                    for(Opportunity varOpp : oppList){
                                        if(varOpp.StageName == 'Pledged'){
                                            opp.Id = varOpp.Id;
                                        }
                                    }
                                }
                                
                                if(opp.Id != null){
                                    payList = [SELECT Id FROM npe01__OppPayment__c WHERE npe01__Opportunity__c =: opp.Id LIMIT 1];
                                    if(payList != Null){
                                        for(npe01__OppPayment__c varPay : payList){
                                            pay.Id = varPay.Id;
                                        }
                                    }
                                }
                            }
                            
                            System.debug('isPGSwitched'+isPGSwitched);
                            if(isPGSwitched || String.isEmpty(rd.npe03__Contact__r.Stripe_Customer_Id__c)){
                                rd.Payment_Gateway__c='Stripe';
                                
                                
                                Boolean stripeCustomerFlag=false;
                                Boolean stripeCampaignFlag=false;
                                String stripeCustomerId;
                                String stripeProductId;
                                if(rd.npe03__Contact__c != null && rd.npe03__Contact__r.Stripe_Customer_Id__c != null){
                                    stripeCustomerFlag = true;
                                    stripeCustomerId=rd.npe03__Contact__r.Stripe_Customer_Id__c;
                                }else{
                                    // Create Customer first
                                    list<Contact> conList = [Select id, Stripe_Customer_Id__c, FirstName, MiddleName, LastName, Email, Phone, npe01__HomeEmail__c, npe01__WorkEmail__c, npe01__AlternateEmail__c, (select id, stripe_subscription_id__c from R00N80000002bOmREAU) rg from contact Where Id=:rd.npe03__Contact__c limit 1];
                                    resultContact = StripePaymentBatchHandler.createCustomer(conList[0]);
                                    if(resultContact != null && resultContact.Stripe_Customer_Id__c != null && resultContact.Stripe_Customer_Id__c.trim().length()>0){
                                        stripeCustomerId=resultContact.Stripe_Customer_Id__c;
                                    }
                                    
                                    if(!String.isEmpty(stripeCustomerId)){
                                        stripeCustomerFlag=true;
                                    }else{
                                        //If customer is not created then returning error
                                        return 'Error: Customer Id is null';
                                    }
                                }
                                
                                //Create Payment method
                                StripeAddUpdateDDonRD.ResponseWrapper pm = createPaymentMethod(bsb_number, account_number, name, email);
                                body = '';
                                //Used to create setupIntent for Direct Debit
                                System.debug('Stripe_Customer_Id__c:'+stripeCustomerId);
                                
                                //Attach Payment method
                                requestBody('customer', stripeCustomerId);
                                String API = pm.id+'/attach';
                                HttpResponse responseJson1 =  StripeConnection.postPaymentMethod(API, body);
                                System.debug(responseJson1.getBody());
                                System.debug('responseJson1::');
                                if( responseJson1.getBody() != null && responseJson1.getBody().contains('error') ){
                                    //If any error occured then returning error
                                    return responseJson1.getBody();
                                }
                                StripeAddUpdateDDonRD.ResponseWrapper pmwithContact = (StripeAddUpdateDDonRD.ResponseWrapper) System.JSON.deserialize (responseJson1.getBody(), StripeAddUpdateDDonRD.ResponseWrapper.class);    
                                
                                //Make payment method default
                                body='';
                                requestBody('invoice_settings[default_payment_method]',pmwithContact.id);
                                System.debug('BODY:'+body);
                                HttpResponse responseJson2 = StripeConnection.postCustomer(stripeCustomerId, body);
                                System.debug(responseJson2.getBody());
                                System.debug('responseJson2::');
                                if( responseJson2.getBody() != null && responseJson2.getBody().contains('error') ){
                                    //If any error occured then returning error
                                    return responseJson2.getBody();
                                }
								createSetupIntent( pm.Id, stripeCustomerId );
                                System.debug('RD:'+ rd.stripe_subscription_id__c);
                                if(rd != null && rd.Id != null){
                                    if(pmwithContact != null){
                                        String BSB = pmwithContact.au_becs_debit.bsb_number;
                                        rd.Account_BSB__c = BSB.left(3)+'-'+BSB.right(3);
                                        rd.npsp__PaymentMethod__c = 'Direct Debit';
                                        rd.Card_Token__c = pmwithContact.au_becs_debit.fingerprint;
                                        rd.Payee_Name__c = pmwithContact.billing_details.name;
                                        // rd.Account_Number__c = pmwithContact.au_becs_debit.last4;
                                        rd.Account_Number__c = account_number;
                                        rd.Direct_Debit_Changed__c = false;
                                        rd.Stripe_Payment_Method_Id__c = pmwithContact.Id;
                                        rd.Financial_Institution__c = financialIns;
                                        update rd;
                                    }
                                }
                                if(opp!= null && opp.Id!= null){
                                    if(pmwithContact != null){
                                        String BSB = pmwithContact.au_becs_debit.bsb_number;
                                        opp.Account_BSB__c = BSB.left(3)+'-'+BSB.right(3);
                                        opp.Payment_Method__c = 'Direct Debit';
                                        opp.Card_Token__c = pmwithContact.au_becs_debit.fingerprint;
                                        opp.Payee_Name__c = pmwithContact.billing_details.name;
                                        // opp.Account_Number__c = pmwithContact.au_becs_debit.last4;
                                        opp.Account_Number__c = account_number;
                                        opp.Stripe_Payment_Method_Id__c = pmwithContact.Id;
                                        update opp;
                                    }
                                }
                                if(pay != null && pay.Id != null){
                                    if(pmwithContact != null){
                                        String BSB = pmwithContact.au_becs_debit.bsb_number;
                                        pay.Account_BSB__c = BSB.left(3)+'-'+BSB.right(3);
                                        pay.npe01__Payment_Method__c = 'Direct Debit';
                                        pay.Card_Token__c = pmwithContact.au_becs_debit.fingerprint;
                                        pay.Payee_Name__c = pmwithContact.billing_details.name;
                                        // pay.Account_Number__c = pmwithContact.au_becs_debit.last4;
                                        pay.Account_Number__c = account_number;
                                        pay.Stripe_Payment_Method_Id__c = pmwithContact.Id;
                                        update pay;
                                    }
                                }
                                update resultContact;
                            }else{
                                // Update Recurring Donation for Payment Gateway, Payment Method, Card information and Stripe Subscription Id
                                rd.Payment_Gateway__c='Stripe';
                                
                                //Add payment method
                                StripeAddUpdateDDonRD.ResponseWrapper pm = createPaymentMethod(bsb_number, account_number, name, email);
                                System.debug(pm);
                                System.debug('pm::');
                                body = '';
                                
                                System.debug('Stripe_Customer_Id__c:'+rd.npe03__Contact__r.Stripe_Customer_Id__c);
                                requestBody('customer', rd.npe03__Contact__r.Stripe_Customer_Id__c);
                                String API = pm.id+'/attach';
                                HttpResponse responseJson1 =  StripeConnection.postPaymentMethod(API, body);
                                System.debug(responseJson1.getBody());
                                System.debug('responseJson1');
                                if( responseJson1.getBody() != null && responseJson1.getBody().contains('error') ){
                                    //If any error occured then returning error
                                    return responseJson1.getBody();
                                }
                                StripeAddUpdateDDonRD.ResponseWrapper pmwithContact = (StripeAddUpdateDDonRD.ResponseWrapper) System.JSON.deserialize (responseJson1.getBody(), StripeAddUpdateDDonRD.ResponseWrapper.class);
                                
                                
                                //Update default payment method on Subscription
                                body = '';
                                requestBody('default_payment_method',pmwithContact.id);
                                if( rd.Stripe_Subscription_Id__c != null ){
                                    HttpResponse UpdatePMSubscription = StripeConnection.postSubscription(rd.Stripe_Subscription_Id__c, body);  
                                    System.debug(UpdatePMSubscription.getBody());
                                    System.debug('UpdatePMSubscription::');
                                    if( UpdatePMSubscription.getBody() != null && UpdatePMSubscription.getBody().contains('error') ){
                                        //If any error occured then returning error
                                        return UpdatePMSubscription.getBody();
                                    }
                                }
                                createSetupIntent(pm.Id, rd.npe03__Contact__r.Stripe_Customer_Id__c);
                                System.debug('RD:'+ rd.stripe_subscription_id__c);
                                if(rd != null && rd.Id != null){
                                    String BSB = pmwithContact.au_becs_debit.bsb_number;
                                    rd.Account_BSB__c = BSB.left(3)+'-'+BSB.right(3);
                                    rd.npsp__PaymentMethod__c = 'Direct Debit';
                                    rd.Card_Token__c = pmwithContact.au_becs_debit.fingerprint;
                                    rd.Payee_Name__c = pmwithContact.billing_details.name;
                                    // rd.Account_Number__c = pmwithContact.au_becs_debit.last4;
                                    rd.Direct_Debit_Changed__c = false;
                                    rd.Account_Number__c = account_number;
                                    rd.Stripe_Payment_Method_Id__c = pmwithContact.Id;
                                    rd.Financial_Institution__c = financialIns;
                                    update rd;
                                }  
                            }
                            
                        }else{
                            // Error on the screen about wrong RDId
                            system.debug('### Error: Wrong Recurring Donation Id.');
                        }
                    }else{
                        // Error on the screen about data error
                        system.debug('### Error: one or more attribute are not specified.');
                    }
                }else{
                    npe03__Recurring_Donation__c VarRD = [SELECT id from npe03__Recurring_Donation__c where id =: rdId ];
                    if(VarRD!= Null){
                        VarRD.Account_BSB__c = bsb_number;
                        VarRD.Account_Number__c = account_number;
                        VarRD.Payee_Name__c = name;
                        VarRD.npsp__PaymentMethod__c = 'Direct Debit';
                    }
                }
            }
            return null;
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripeAddUpdateDDonRD', e.getMessage(), 'StripeAddUpdateDDonRD', e.getStackTraceString());
            return e.getMessage();
        }
    }
    
    public static void requestBody(String key, String value){
        if(String.isEmpty(body) && value.trim().length() > 0 && value != null){
            body += key + '=' + value;
        }else{
            body += '&' + key + '=' + value;
        }
    }
    public static void createSetupIntent( String pmId, String cusId ){
        body='';
        requestBody('payment_method_types[]','au_becs_debit');
        requestBody('payment_method',pmId);
        requestBody('customer',cusId);
        requestBody('mandate_data[customer_acceptance][type]','offline');
        requestBody('confirm','true');
        HttpResponse responseJson =  StripeConnection.postSetupIntent(Null, body);
        System.debug('SI:'+responseJson+' Body:'+body);
    }
    public static StripeAddUpdateDDonRD.ResponseWrapper createPaymentMethod(string bsb_number, string account_number, string name, String email){
        //Api to create a payment method
        body ='';
        ResponseWrapper response = new ResponseWrapper();
        requestBody('type','au_becs_debit');
        requestBody('au_becs_debit[bsb_number]',bsb_number);
        requestBody('au_becs_debit[account_number]',account_number);
        requestBody('billing_details[name]',name);
        requestBody('billing_details[email]',email);
        
        system.debug(body);
        
        HttpResponse responseJson =  StripeConnection.postPaymentMethod(Null, body);
        System.debug(responseJson.getBody());
        system.debug('responseJson');
        StripeAddUpdateDDonRD.ResponseWrapper rw = (StripeAddUpdateDDonRD.ResponseWrapper) System.JSON.deserialize (responseJson.getBody(), StripeAddUpdateDDonRD.ResponseWrapper.class);
        return rw;
    }
    public class ResponseWrapper{
        public String id;
        public au_becs_debit au_becs_debit;
        public billing_details billing_details;
        public String status;
        
    }
    
    public Class au_becs_debit {
        String bsb_number;
        String fingerprint;
        String last4;
    }
    
    public Class billing_details {
        String email;
        String name;
    }
}