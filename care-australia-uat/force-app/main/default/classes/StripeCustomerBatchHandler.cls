/**
 * Class Name: StripeCustomerBatchHandler
 * Auhtor: Gerent Team
 * Description: sync contact with customers in stripe
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */
public class StripeCustomerBatchHandler {
    Private static String body = '';
    public static void CreateUpdateCustomer(list<Contact> conList){
        try{
            ResponseWrapper response = new ResponseWrapper();
            map<String, Contact> stripeContactsMap = new map<String, Contact>();
            for(Contact con : conList){
                // Check if the contact have Rd or contact contain stripe id (one-off payment exists)
                if((con.Stripe_Customer_Id__c != null && con.Stripe_Customer_Id__c.trim().length()>0) || (con.R00N80000002bOmREAU != null && con.R00N80000002bOmREAU.size()>0)){
                    Contact resultCon=getStripeCustomerId(con);
                    stripeContactsMap.put(resultCon.Id, resultCon);
                }
            }
            
            if(stripeContactsMap != null && stripeContactsMap.size()>0){
                upsert stripeContactsMap.values();
            }
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripeCustomerBatchHandler', e.getMessage(), 'StripeCustomerBatchHandler', e.getStackTraceString());
        }
    }
    
    public static Contact getStripeCustomerId(Contact con){
        // Check if the contact have Rd or contact contain stripe id (one-off payment exists)
        if(String.isNotEmpty(con.Stripe_Customer_Id__c)  || !con.R00N80000002bOmREAU.isEmpty()){
            String endPointUpdate = '';
            body = '';
            String phone = '';
            String fullname = (!String.isEmpty(con.FirstName) ? con.FirstName + ' ': '') + (!String.isEmpty(con.LastName)? con.LastName + ' ': '');
            if( con.phone != null && con.Phone.trim() != ''){
                system.debug('phone number ' + con.phone);
                phone = '%2b' + con.Phone.substring(1);
                system.debug('phone number sub ' + phone);
            }
            
            requestBody('name',fullname); 
            requestBody('phone',phone);
            if(!String.isEmpty(con.Email)){
                requestBody('email',con.Email);
            }
            
            requestBody('metadata[sf_contact_id]', con.id);
            requestBody('metadata[firstName]',(!String.isEmpty(con.FirstName) ? con.FirstName + ' ': ''));
            requestBody('metadata[lastName]',(!String.isEmpty(con.LastName) ? con.LastName + ' ': ''));
            system.debug(body);
            
            HttpResponse responseJson =  StripeConnection.postCustomer(con.Stripe_Customer_Id__c, body);
            if(responseJson.getStatusCode() < 200 || responseJson.getStatusCode() > 299){
                throw new AuraHandledException('Customer Not Created in Stripe : ('+ con.id + ') : ' + responseJson.getStatus());
            }
            system.debug(responseJson.getBody());
            StripeCustomerBatchHandler.ResponseWrapper rw = (StripeCustomerBatchHandler.ResponseWrapper) System.JSON.deserialize (responseJson.getBody(), StripeCustomerBatchHandler.ResponseWrapper.class);
            system.debug('ID +++ '+rw.id);
            con.Stripe_Customer_Id__c = rw.id;
            //con.Stripe_Last_Sync_Date__c = date.today();
            return con;
        }
        return null;
    }
    // Create the body for request
    public static void requestBody(String key, String value){
        if(String.isEmpty(body) && value.trim().length() > 0 && value != null){
            body += key + '=' + value;
        }else{
            body += '&' + key + '=' + value;
        }
    }
    // Wrapper for response
    public class ResponseWrapper{
        public String id;
    }
 }