/**
 * Class Name: StripeWebhookCustomer
 * Auhtor: Gerent Team
 * Description: update contact on customer creation
 * Modification Details: AG/DB/DJ - 08/09/2022 - Initial version created
 * */
@RestResource(urlMapping='/api/webhooks/customerAPI')
global without sharing class StripeWebhookCustomer{

    global static String sf_contact_id;
    global static String customerId;

    @HttpPost
    global static void handleCustomer(){
        // Get's the data from stripe to salesforce (contact object)
        try {
            if (Stripe_Setting__c.getInstance('Default').Activation__c) {
             	RestRequest request = RestContext.request;
                StripeCustomerWrapper wrapperResponse = StripeCustomerWrapper.parse(request.requestBody.toString());
                List<Contact> conList = new List<Contact>();
                conList = [Select Id, FirstName, LastName, Stripe_Customer_Id__c, Stripe_Customer_Ids__c, LastModifiedDate, Stripe_Last_Sync_Date__c, CreatedDate  FROM Contact WHERE Id =: wrapperResponse.data.object_Z.metadata.sf_contact_id OR Stripe_Customer_Id__c =: wrapperResponse.data.object_Z.id];
                if (conList.isEmpty() && (String.isNotEmpty(wrapperResponse.data.object_Z.email) || String.isNotEmpty(wrapperResponse.data.object_Z.phone))){
                    conList = [Select Id, FirstName, LastName, Stripe_Customer_Id__c, Stripe_Customer_Ids__c, Stripe_Last_Sync_Date__c, LastModifiedDate  FROM Contact WHERE (Phone != null AND Name =: wrapperResponse.data.object_Z.name AND Phone =: wrapperResponse.data.object_Z.phone) OR (Email != null AND Name =: wrapperResponse.data.object_Z.name AND Email =: wrapperResponse.data.object_Z.email)];    
                }
                if(!conList.isEmpty()){
                    if(conList[0].Stripe_Last_Sync_Date__c == null || conList[0].Stripe_Last_Sync_Date__c < DateTime.now().addMinutes(-5)) {
                        createContact(wrapperResponse,conList[0]);       
                    }
                }
                else if(wrapperResponse.type == 'customer.created'){
                    createContact(wrapperResponse,null);
                }   
            }
        }
        catch(Exception e){
            ApexLogCreator.createApexLog('StripeWebhookCustomer', e.getMessage(), 'handleCustomer', e.getStackTraceString());
            system.debug(e);
        }   
    }



    private static Contact createContact(StripeCustomerWrapper wrapperResponse, Contact contact){
        Contact con = new Contact();
        if(contact != null) {
            con = contact;
        }
        if(wrapperResponse.data.object_z.metadata != null && String.isNotEmpty(wrapperResponse.data.object_z.metadata.first_name) && String.isNotEmpty(wrapperResponse.data.object_z.metadata.last_name)){
            if(wrapperResponse.data.object_z.metadata.first_name != null){
                con.firstName = wrapperResponse.data.object_z.metadata.first_name;
            }
            if(wrapperResponse.data.object_z.metadata.last_name != null){
                con.LastName = wrapperResponse.data.object_z.metadata.last_name;
            }
        }
        else{
            if(wrapperResponse.data.object_z.name.indexOf(' ') == -1){
                con.LastName = wrapperResponse.data.object_z.name;
            }
            else{
                con.FirstName = wrapperResponse.data.object_z.name.substring(0,wrapperResponse.data.object_z.name.indexOf(' '));
                con.LastName = wrapperResponse.data.object_z.name.substring(wrapperResponse.data.object_z.name.indexOf(' ')+1);
            }
        } 
        
        if(con.Stripe_Customer_Id__c != wrapperResponse.data.object_z.id){
            if (String.isEmpty(con.Stripe_Customer_Ids__c)) {
                con.Stripe_Customer_Ids__c = wrapperResponse.data.object_z.id;
            }
            List<String> stripeIdsList = con.Stripe_Customer_Ids__c.split(',');
            stripeIdsList.add(wrapperResponse.data.object_z.id);
            Set<String> uniqueStripeIds = new Set<String>(stripeIdsList);
            con.Stripe_Customer_Ids__c = String.join(new List<String>(uniqueStripeIds), ',');
        }
    
        con.Stripe_Customer_Id__c = wrapperResponse.data.object_z.id;
        con.email = wrapperResponse.data.object_z.email;
        if(!String.isEmpty(wrapperResponse.data.object_z.phone)){
            /*if(wrapperResponse.data.object_z.phone.left(4) == '+610' && wrapperResponse.data.object_z.phone.length() == 13){
                String phoneNumber = wrapperResponse.data.object_z.phone.subString(0,3) +  wrapperResponse.data.object_z.phone.subString(4,13);
                if(phoneNumber.left(4) == '+614'){
                    con.npe01__PreferredPhone__c = 'Mobile';
                    con.Phone = phoneNumber;
                } 
                else{
                    con.npe01__PreferredPhone__c = 'Home';
                    con.Phone = phoneNumber;
                }
            }
            else if(wrapperResponse.data.object_z.phone.left(4) == '+614' && wrapperResponse.data.object_z.phone.length() == 12){
                con.npe01__PreferredPhone__c = 'Mobile';
                con.Phone = wrapperResponse.data.object_z.phone;
            }
            else if(wrapperResponse.data.object_z.phone.left(3) == '+61' && wrapperResponse.data.object_z.phone.left(4) != '+610' && wrapperResponse.data.object_z.phone.length() == 12){
                con.npe01__PreferredPhone__c = 'Home';
                con.Phone = wrapperResponse.data.object_z.phone;
            }*/
            
            if((wrapperResponse.data.object_z.phone.left(5) == '+6104' && wrapperResponse.data.object_z.phone.length() == 13) || (wrapperResponse.data.object_z.phone.left(2) == '04' && wrapperResponse.data.object_z.phone.length() == 10) || (wrapperResponse.data.object_z.phone.left(4) == '+614' && wrapperResponse.data.object_z.phone.length() == 12) && (wrapperResponse.data.object_z.phone.left(3) == '614' && wrapperResponse.data.object_z.phone.length() == 11)){
                con.npe01__PreferredPhone__c = 'Mobile';
                if(wrapperResponse.data.object_z.phone.left(5) == '+6104'){
                	con.Phone = wrapperResponse.data.object_z.phone.subString(0,3) +  wrapperResponse.data.object_z.phone.subString(4,13);
                } else if(wrapperResponse.data.object_z.phone.left(2) == '04'){
                    con.Phone = '+61' + wrapperResponse.data.object_z.phone.subString(1,10);
                } else if(wrapperResponse.data.object_z.phone.left(4) == '+614'){
                    con.Phone = wrapperResponse.data.object_z.phone;
                } else if(wrapperResponse.data.object_z.phone.left(3) == '614'){
                    con.Phone = '+' + wrapperResponse.data.object_z.phone;
                }
            } else if(((wrapperResponse.data.object_z.phone.left(2) == '02' || wrapperResponse.data.object_z.phone.left(2) == '03' || wrapperResponse.data.object_z.phone.left(2) == '07' || wrapperResponse.data.object_z.phone.left(2) == '08') && wrapperResponse.data.object_z.phone.length() == 10)
            || ((wrapperResponse.data.object_z.phone.left(5) == '+6102' || wrapperResponse.data.object_z.phone.left(5) == '+6103' || wrapperResponse.data.object_z.phone.left(5) == '+6107' || wrapperResponse.data.object_z.phone.left(5) == '+6108') && wrapperResponse.data.object_z.phone.length() == 13)
            || ((wrapperResponse.data.object_z.phone.left(4) == '+612' || wrapperResponse.data.object_z.phone.left(4) == '+613' || wrapperResponse.data.object_z.phone.left(4) == '+617' || wrapperResponse.data.object_z.phone.left(4) == '+618') && wrapperResponse.data.object_z.phone.length() == 12)
            || ((wrapperResponse.data.object_z.phone.left(3) == '612' || wrapperResponse.data.object_z.phone.left(3) == '613' || wrapperResponse.data.object_z.phone.left(3) == '617' || wrapperResponse.data.object_z.phone.left(3) == '618') && wrapperResponse.data.object_z.phone.length() == 11)){
                con.npe01__PreferredPhone__c = 'Home';
                if(wrapperResponse.data.object_z.phone.left(4) == '+610'){
                	con.Phone = wrapperResponse.data.object_z.phone.subString(0,3) +  wrapperResponse.data.object_z.phone.subString(4,13);
                } else if(wrapperResponse.data.object_z.phone.left(1) == '0'){
                    con.Phone = '+61' + wrapperResponse.data.object_z.phone.subString(1,10);
                } else if(wrapperResponse.data.object_z.phone.left(3) == '+61'){
                    con.Phone = wrapperResponse.data.object_z.phone;
                } else if(wrapperResponse.data.object_z.phone.left(2) == '61'){
                    con.Phone = '+' + wrapperResponse.data.object_z.phone;
                }
            } else{
                con.npe01__PreferredPhone__c = 'Other';
                con.OtherPhone = wrapperResponse.data.object_z.phone;
            }
        }
        con.Stripe_Last_Sync_Date__c = Date.today();
        upsert con;
        
        //Send Response
        String body = 'metadata[sf_contact_id]='+con.id;
        if(String.isNotEmpty(con.FirstName)){
        	body += '&metadata[firstName]='+con.FirstName;    
        }
        body += '&metadata[lastName]='+con.LastName;
        StripeConnection.postCustomerFuture(con.Stripe_Customer_Id__c, body);    
        system.debug('###'+ con.Id);
        return con;
    }
}