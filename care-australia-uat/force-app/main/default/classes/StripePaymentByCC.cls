/**
* Class Name: StripePaymentByCC
* Auhtor: Gerent Team
* Description: update add credit card and change payment method
* Modification Details: Devansh Jain - 26/09/2022 - Initial version created
* */
global class StripePaymentByCC {
    public string lexOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0] + '.lightning.force.com';} set;}
    Private static String body = '';
    Private static String Contactbody ='';
    public StripePaymentByCC(){}
    
    @RemoteAction
    global static void doPayment(String recordId, String responseBody){
        try{
            String paymentKeyPrefix = Schema.getGlobalDescribe().get('npe01__OppPayment__c').getDescribe().getKeyPrefix();
            String rdKeyPrefix = Schema.getGlobalDescribe().get('npe03__Recurring_Donation__c').getDescribe().getKeyPrefix();
            String contactKeyPrefix = Schema.getGlobalDescribe().get('Contact').getDescribe().getKeyPrefix();
            //System.debug('rcordId:'+recordId);
            //System.debug('recordId.left(4)'+recordId.startsWith('a01'));
            //System.debug('Stripe_Setting__c'+Stripe_Setting__c.getInstance('Default').Activation__c);
            if(recordId.startsWith(paymentKeyPrefix)){
                if(Stripe_Setting__c.getInstance('Default').Activation__c){
                    //system.debug('### responseBody: '+ responseBody);
                    StripeGetPaymentMethodWrapper rw = StripeGetPaymentMethodWrapper.parse(responseBody);
                    //system.debug('rw'+ rw);
                    
                    Boolean isContactNew = False;
                    String stripeCustomerId;
                    npe01__OppPayment__c paymentRec = new npe01__OppPayment__c();
                    Opportunity opp = new Opportunity();
                    Contact con = new Contact();
                    
                    Boolean createPayment=false;
                    
                    if(!String.isEmpty(rw.paymentMethod.Card.last4) && !String.isEmpty(String.valueOf(rw.paymentMethod.Card.exp_month)) && !String.isEmpty(String.valueOf(rw.paymentMethod.Card.exp_year)) && (!String.isEmpty(recordId))){
                        if(recordId != null && recordId.trim().length()>0){
                            paymentRec = [Select Id, 
                                          npe01__Opportunity__c,
                                          npe01__Opportunity__r.npsp__Primary_Contact__c, 
                                          Payment_Status__c, npe01__Opportunity__r.StageName, 
                                          npe01__Opportunity__r.npe03__Recurring_Donation__c,
                                          npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c, 
                                          npe01__Payment_Amount__c, 
                                          Stripe_Payment_Method_Id__c from npe01__OppPayment__c where Id =: recordId FOR UPDATE];
                            
                            if(paymentRec.npe01__Opportunity__c != null){
                                opp.Id =paymentRec.npe01__Opportunity__c;
                                //System.debug('Opp.Id'+opp.Id);
                            }
                            if(paymentRec.npe01__Opportunity__c != null && paymentRec.npe01__Opportunity__r.StageName == 'Pledged' && paymentRec.Payment_Status__c == 'Unpaid'){
                                createPayment=true;
                            }
                        }
                        
                        // check for customer
                        if(String.isEmpty(paymentRec.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c)){
                            isContactNew = true;
                            con = [ SELECT id, Stripe_Customer_Id__c, FirstName, MiddleName, LastName, Email, Phone, 
                                   npe01__HomeEmail__c,npe01__WorkEmail__c, npe01__AlternateEmail__c from Contact 
                                   where id =: paymentRec.npe01__Opportunity__r.npsp__Primary_Contact__c];
                            Contactbody = '';
                            String phone = '';
                            String fullname = (!String.isEmpty(con.FirstName) ? con.FirstName + ' ': '') + (!String.isEmpty(con.LastName)? con.LastName + ' ': '');
                            if( con.phone != null && con.Phone.trim() != ''){
                                //system.debug('phone number ' + con.phone);
                                phone = '%2b' + con.Phone.substring(1);
                                //system.debug('phone number sub ' + phone);
                            }
                            
                            requestContactBody('name',fullname); 
                            requestContactBody('phone',phone);
                            if(!String.isEmpty(con.Email)){
                                requestContactBody('email',con.Email);
                            }
                            
                            requestContactBody('metadata[sf_contact_id]', con.id);
                            requestContactBody('metadata[firstName]',(!String.isEmpty(con.FirstName) ? con.FirstName + ' ': ''));
                            requestContactBody('metadata[lastName]',(!String.isEmpty(con.LastName) ? con.LastName + ' ': ''));
                            //system.debug(body);
                            
                            HttpResponse responseJson3 =  StripeConnection.postCustomer(con.Stripe_Customer_Id__c, Contactbody);
                            //system.debug(responseJson3.getBody());
                            
                            StripeCustomerBatchHandler.ResponseWrapper contactResponse = (StripeCustomerBatchHandler.ResponseWrapper) System.JSON.deserialize (responseJson3.getBody(), StripeCustomerBatchHandler.ResponseWrapper.class);
                            //system.debug('ID +++ '+contactResponse.id);
                            
                            con.Stripe_Customer_Id__c = contactResponse.id;
                            //con.Stripe_Last_Sync_Date__c = date.today();
                            
                        }else{
                            con.Id = paymentRec.npe01__Opportunity__r.npsp__Primary_Contact__c;
                        }
                        
                        
                        //link payment method with Contact
                        body='';
                        //System.debug('Con Id1'+  con.Stripe_customer_Id__c);
                        if(String.isEmpty(paymentRec.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c)){
                            requestBody('customer', con.Stripe_customer_Id__c);
                        }else{
                            requestBody('customer', paymentRec.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c);
                        }
                        String API1 = rw.paymentMethod.id+'/attach';
                        
                        HttpResponse responseJson4 =  StripeConnection.postPaymentMethod(API1, body);
                        StripePaymentByCC.ResponseWrapper attachedPaymentMethod = (StripePaymentByCC.ResponseWrapper) System.JSON.deserialize (responseJson4.getBody(), StripePaymentByCC.ResponseWrapper.class);
                        
                        if(isContactNew)
                        {
                            //Make payment method default
                            body = 'invoice_settings[default_payment_method]'+'='+attachedPaymentMethod.id;
                            //System.debug('BODY:'+body);
                            HttpResponse responseJson2 = StripeConnection.postCustomer(con.Stripe_customer_Id__c, body);
                        }
                        
                        if(createPayment == true){
                            //Create a payment intent in stripe
                            body = '';
                            requestBody('amount', String.valueOf(((integer)paymentRec.npe01__Payment_Amount__c)*100));
                            requestBody('currency', 'AUD');
                            
                            if(paymentRec.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c != Null){
                                requestBody('customer', paymentRec.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c);
                            }
                            else{
                                //System.debug('Con Id2'+  con.Stripe_customer_Id__c);
                                requestBody('customer', con.Stripe_customer_Id__c);
                            }
                            //system.debug(body);
                            HttpResponse responseJson1 =  StripeConnection.postPaymentIntent(null, body);
                            //system.debug(responseJson1.getBody());
                            StripePaymentByCC.ResponseWrapper rww = (StripePaymentByCC.ResponseWrapper) System.JSON.deserialize (responseJson1.getBody(), StripePaymentByCC.ResponseWrapper.class);
                            
                            //Confirm payment intent using payment method id
                            body = '';
                            requestBody('payment_method', rw.paymentMethod.id);
                            String Api = rww.id+'/confirm';
                            HttpResponse responseJson2 =  StripeConnection.postPaymentIntent(Api, body);
                            //system.debug(responseJson2.getBody());
                            StripePaymentByCC.ResponseWrapper rwww = (StripePaymentByCC.ResponseWrapper) System.JSON.deserialize (responseJson2.getBody(), StripePaymentByCC.ResponseWrapper.class);   
                            
                            //update payment(status = paid) and opportunity(stage = closedWon) records
                            if(rwww.status == 'succeeded'){
                                opp.stageName ='Closed Won';
                                paymentRec.npe01__Paid__c = true;
                                paymentRec.npe01__Payment_Date__c = DATE.today();
                                paymentRec.Payment_Result__c = 'Success';
                            }
                            
                            if(paymentRec != null && paymentRec.Id != null){
                                paymentRec.Card_Number_Masked__c = ('************' + attachedPaymentMethod.card.last4);
                                paymentRec.npe01__Payment_Method__c = 'Credit Card';
                                paymentRec.Card_Type__c = attachedPaymentMethod.card.brand;
                                paymentRec.Card_Token__c = attachedPaymentMethod.card.fingerprint;
                                paymentRec.Payee_Name__c = attachedPaymentMethod.card.name;
                                paymentRec.npsp__Card_Expiration_Month__c = String.valueOf(attachedPaymentMethod.card.exp_month);
                                paymentRec.npsp__Card_Expiration_Year__c = String.valueOf(attachedPaymentMethod.card.exp_year);
                                paymentRec.Stripe_Payment_Method_Id__c = attachedPaymentMethod.Id;
                                paymentRec.Merchant_Category__c = 'Stripe';
                                paymentRec.npe01__Check_Reference_Number__c = rwww.Id;
                                update paymentRec;
                            }
                            if(opp!= null && opp.Id!= null){
                                opp.Card_Number_Masked__c=('************' + attachedPaymentMethod.card.last4);
                                opp.Payment_Method__c = 'Credit Card';
                                opp.Card_Type__c = attachedPaymentMethod.card.brand;
                                opp.Card_Token__c = attachedPaymentMethod.Card.fingerprint;
                                opp.Payee_Name__c = attachedPaymentMethod.card.name;
                                opp.Card_Expiration_Month__c = String.valueOf(attachedPaymentMethod.card.exp_month);
                                opp.Card_Expiration_Year__c = String.valueOf(attachedPaymentMethod.card.exp_year);
                                opp.Stripe_Payment_Method_Id__c = attachedPaymentMethod.Id;
                                //System.debug('Opp:'+opp.Card_Token__c);
                                //System.debug('StageName'+opp.StageName);
                                update opp;
                            }
                            
                            update con;
                        }else{
                            system.debug('### Error: one or more attribute are not specified.');
                        }
                    }   
                }else{
                    system.debug('### Error: one or more attribute are not specified.');
                }
            } else if(recordId.startsWith(rdKeyPrefix)){
                if(Stripe_Setting__c.getInstance('Default').Activation__c){
                    //system.debug('### responseBody: '+ responseBody);
                    StripeGetPaymentMethodWrapper rw = StripeGetPaymentMethodWrapper.parse(responseBody);
                    
                    //update card details on RD
                    npe03__Recurring_Donation__c VarRD = [SELECT Id FROM npe03__Recurring_Donation__c WHERE id =: recordId];
                    VarRD.Stripe_Payment_Method_Id__c = rw.PaymentMethod.id;
                    VarRD.Card_Number_Masked__c = ('************' + rw.PaymentMethod.card.last4);
                    VarRD.npsp__PaymentMethod__c = 'Credit Card';
                    VarRD.Card_Type__c = rw.PaymentMethod.card.brand;
                    VarRD.Card_Token__c = rw.PaymentMethod.Card.fingerprint;
                    VarRD.npsp__CardExpirationMonth__c = String.valueOf(rw.PaymentMethod.card.exp_month);
                    VarRD.npsp__CardExpirationYear__c = String.valueOf(rw.PaymentMethod.card.exp_year);
                    update VarRD;
                    
                }
                
            }else if(recordId.startsWith(contactKeyPrefix)){
                if(Stripe_Setting__c.getInstance('Default').Activation__c){
                    //check new customer
                    Boolean isContactNew = false;
                    contact varCon = [SELECT id, Stripe_Customer_Id__c, FirstName, MiddleName, LastName, Email, Phone, 
                                      npe01__HomeEmail__c,npe01__WorkEmail__c, npe01__AlternateEmail__c from Contact 
                                      where id =: recordId];
                    if(varCON.Stripe_Customer_Id__c == NULL || VarCON.Stripe_Customer_Id__c == ''){
                        isContactNew= true;
                    }
                    //create new contact
                    if(isContactNew){
                        Contactbody = '';
                        String phone = '';
                        String fullname = (!String.isEmpty(varCon.FirstName) ? varCon.FirstName + ' ': '') + (!String.isEmpty(varCon.LastName)? varCon.LastName + ' ': '');
                        if( varCon.phone != null && varCon.Phone.trim() != ''){
                            phone = '%2b' + varCon.Phone.substring(1);
                        }
                        requestContactBody('name',fullname); 
                        requestContactBody('phone',phone);
                        if(!String.isEmpty(varCon.Email)){
                            requestContactBody('email',varCon.Email);
                        }
                        
                        requestContactBody('metadata[sf_contact_id]', varCon.id);
                        requestContactBody('metadata[firstName]',(!String.isEmpty(varCon.FirstName) ? varCon.FirstName + ' ': ''));
                        requestContactBody('metadata[lastName]',(!String.isEmpty(varCon.LastName) ? varCon.LastName + ' ': ''));
                        
                        HttpResponse responseJsonContact =  StripeConnection.postCustomer(varCon.Stripe_Customer_Id__c, Contactbody);
                        
                        StripeCustomerBatchHandler.ResponseWrapper contactResponse = (StripeCustomerBatchHandler.ResponseWrapper) System.JSON.deserialize (responseJsonContact.getBody(), StripeCustomerBatchHandler.ResponseWrapper.class);
                        varCon.Stripe_Customer_Id__c = contactResponse.id;
                    }
                    StripeGetPaymentMethodWrapper rw = StripeGetPaymentMethodWrapper.parse(responseBody);
                    
                    //link payment method with Contact
                    body='';
                    requestBody('customer', varCon.Stripe_customer_Id__c);
                    String API1 = rw.paymentMethod.id+'/attach';
                    
                    HttpResponse responseJsonlinkedPaymentMethod =  StripeConnection.postPaymentMethod(API1, body);
                    StripePaymentByCC.ResponseWrapper attachedPaymentMethod = (StripePaymentByCC.ResponseWrapper) System.JSON.deserialize (responseJsonlinkedPaymentMethod.getBody(), StripePaymentByCC.ResponseWrapper.class);
                    
                    if(isContactNew)
                    {
                        //Make payment method default
                        body = 'invoice_settings[default_payment_method]'+'='+attachedPaymentMethod.id;
                        HttpResponse responseJson2 = StripeConnection.postCustomer(varCon.Stripe_customer_Id__c, body);
                    }
                    varCon.Stripe_Payment_Method_Id__c = attachedPaymentMethod.id;
                    update varCon;
                }   
             }
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripePaymentByCC', e.getMessage(), 'StripePaymentByCC', e.getStackTraceString());
        }
    }
    
    
    @AuraEnabled
    public static boolean getPaymentStatus(String paymentId){
        npe01__OppPayment__c paymentRec = [SELECT Id, npe01__Paid__c FROM npe01__OppPayment__c WHERE Id =: paymentId];
        if(paymentRec != null && paymentRec.npe01__Paid__c == true){
            return true;
        }
        return false;
    }
    
    
    public static void requestBody(String key, String value){
        if(String.isEmpty(body) && value.trim().length() > 0 && value != null){
            body += key + '=' + value;
        }else{
            body += '&' + key + '=' + value;
        }
    }
    public static void requestContactBody(String key, String value){
        if(String.isEmpty(Contactbody) && value.trim().length() > 0 && value != null){
            Contactbody += key + '=' + value;
        }else{
            Contactbody += '&' + key + '=' + value;
        }
    } 
    public class ResponseWrapper{
        public String id;
        public Card card;
        public String status;
    }
    
    public Class Card {
        String id;
        String name;
        String brand;
        String last4;
        String fingerprint;
        Integer exp_month;
        Integer exp_year;
    }
}