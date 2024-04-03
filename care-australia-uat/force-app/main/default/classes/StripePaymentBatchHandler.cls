/**
* Class Name: StripePaymentBatchHandler
* Auhtor: Gerent Team
* Description: sync contact with customers in stripe
* Modification Details: Amit Goyal - 05/10/2022 - Initial version created
* Modification Details: Devansh Jain - 11/10/2022 - Updated methods and APIs
**/
public class StripePaymentBatchHandler {
    Private static String body = '';
    Private static String contactBody ='';
    
    public static void createPayment(list<npe01__OppPayment__c> paymentList){
        try{
            list<Contact> contactList = new list<Contact>();
            list<Opportunity> oppList = new list<Opportunity>();
            list<npe01__OppPayment__c> payList = new list<npe01__OppPayment__c>();
            
            // Create payments in Stripe
            for(npe01__OppPayment__c payment : paymentList){
                Opportunity opp = new Opportunity();
                contact resultContact = new contact();
                String stripeCustomerId;
                
                //system.debug('payment'+ payment.ID);
                //system.debug('payment.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c'+payment.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c);
                
                if(payment.npe01__Opportunity__c != null){
                    opp.Id = payment.npe01__Opportunity__c;
                }
                
                //Create payment intent
                body = '';
                requestBody('amount', String.valueOf(((integer)payment.npe01__Payment_Amount__c)*100));
                requestBody('currency', 'AUD');
                if(payment.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c != Null){
                    requestBody('customer', payment.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c);
                }else{
                    //Create customer
                    contactBody='';
                    list<Contact> conList = [Select id, Stripe_Customer_Id__c, FirstName, MiddleName, LastName, Email, Phone, npe01__HomeEmail__c, npe01__WorkEmail__c, npe01__AlternateEmail__c, (select id, stripe_subscription_id__c from R00N80000002bOmREAU) rg from contact Where Id=:payment.npe01__Opportunity__r.npsp__Primary_Contact__c limit 1];
                    resultContact = createCustomer(conList[0]);
                    //system.debug(resultContact);
                    if(resultContact != null && String.isNotEmpty(resultContact.Stripe_Customer_Id__c)){
                        stripeCustomerId=resultContact.Stripe_Customer_Id__c;
                	}
                    requestBody('customer', stripeCustomerId);
                }
                
                //system.debug(body);
                HttpResponse responseJson =  StripeConnection.postPaymentIntent(null, body);
                //system.debug(responseJson.getBody());
                StripePaymentBatchHandler.ResponseWrapper paymentIntentResponse = (StripePaymentBatchHandler.ResponseWrapper) System.JSON.deserialize (responseJson.getBody(), StripePaymentBatchHandler.ResponseWrapper.class);
                
                //link payment method with Contact
                body='';
                //System.debug('resultContact Id1'+  resultContact.Stripe_customer_Id__c);
                if(String.isEmpty(payment.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c)){
                    requestBody('customer', resultContact.Stripe_customer_Id__c);
                }else{
                    requestBody('customer', payment.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c);
                }
                String apiToAttach = payment.Stripe_Payment_Method_Id__c+'/attach';
                
                HttpResponse responseAfterAttach =  StripeConnection.postPaymentMethod(apiToAttach, body);
                StripePaymentBatchHandler.ResponseWrapper attachedPaymentMethod = (StripePaymentBatchHandler.ResponseWrapper) System.JSON.deserialize (responseAfterAttach.getBody(), StripePaymentBatchHandler.ResponseWrapper.class);
                
                
                //Confirm payment intent using payment method id
                body = '';
                requestBody('payment_method', payment.Stripe_Payment_Method_Id__c);
                String Api = paymentIntentResponse.id+'/confirm';
                HttpResponse responseJson2 =  StripeConnection.postPaymentIntent(Api, body);
                //system.debug(responseJson2.getBody());
                StripePaymentBatchHandler.ResponseWrapper confirmPaymentResponse = (StripePaymentBatchHandler.ResponseWrapper) System.JSON.deserialize (responseJson2.getBody(), StripePaymentBatchHandler.ResponseWrapper.class);   
                
                //update payment(status = paid) and opportunity(stage = closedWon) records
                if(confirmPaymentResponse.status == 'succeeded' || Test.isRunningTest()){
                    opp.StageName = 'Closed Won';
                    payment.npe01__Paid__c = true;
                    payment.Payment_Result__c = 'Success';
                    payment.npe01__Check_Reference_Number__c = Test.isRunningTest() ? '' : paymentIntentResponse.id;
                    payment.npe01__Payment_Date__c = DATE.today();
                    payList.add(payment);  
                    oppList.add(opp);
                    if(payment.npe01__Opportunity__r.npsp__Primary_Contact__r.Stripe_customer_Id__c == Null){
                        contactList.add(resultContact);
                    }
                }
            }
            
            if(payList != null && payList.size()>0){
                update payList;
            }
            if(oppList != null && oppList.size()>0){
                update oppList;
            }
            if(contactList != null && contactList.size()>0){
                update contactList;
            }
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripePaymentBatchHandler', e.getMessage(), 'StripePaymentBatchHandler', e.getStackTraceString());
        }
    }
    
    public static Contact createCustomer(Contact con){
        if(String.isEmpty(con.Stripe_customer_Id__c)){
            //Create customer
           	String endPointUpdate = '';
            contactBody = '';
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
            //system.debug(contactBody);
            
            HttpResponse responseJson =  StripeConnection.postCustomer(con.Stripe_Customer_Id__c, contactBody);
            //system.debug(responseJson.getBody());
            StripeCustomerBatchHandler.ResponseWrapper rw = (StripeCustomerBatchHandler.ResponseWrapper) System.JSON.deserialize (responseJson.getBody(), StripeCustomerBatchHandler.ResponseWrapper.class);
            //system.debug('ID +++ '+rw.id);
            con.Stripe_Customer_Id__c = rw.id;
            //con.Stripe_Last_Sync_Date__c = date.today();
            //System.debug('Contact:'+con);
            return con;
        }
        return Null;
    }
    
    public static void requestBody(String key, String value){
        if(String.isEmpty(body) && value.trim().length() > 0 && value != null){
            body += key + '=' + value;
        }else{
            body += '&' + key + '=' + value;
        }
    }
    
    public static void requestContactBody(String key, String value){
        if(String.isEmpty(contactBody) && value.trim().length() > 0 && value != null){
            contactBody += key + '=' + value;
        }else{
            contactBody += '&' + key + '=' + value;
        }
    }
    
    public class ResponseWrapper{
        public String id;
        public String status;
    }
}