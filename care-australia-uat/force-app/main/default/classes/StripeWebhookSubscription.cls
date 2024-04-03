/**
 * Class Name: StripeWebhookSubscription
 * Auhtor: Gerent Team
 * Description: update subscription from stripe to salesforce
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */
@RestResource(urlMapping='/api/webhooks/RD')
global without sharing class StripeWebhookSubscription {
	@HttpPost
    global static void handleRecurringDonation(){
        // Get's the data from stripe to salesforce (contact object)
     	try{
            if(Stripe_Setting__c.getInstance('Default').Activation__c){
                RestRequest request = RestContext.request;
                RestResponse response = RestContext.response;
                system.debug(request.requestBody.toString() + 'Testing Apex');
                system.debug(JSON.deserializeUntyped(request.requestBody.toString()) + 'Testing Apex');
                StripeSubscriptionWrapper wrapperResponse = StripeSubscriptionWrapper.parse(request.requestBody.toString());
                // String conId = [Select Id from contact where stripe_customer_id__c =: wrapperResponse.data.object_z.customer limit 1].id;
                List<npe03__Recurring_Donation__c> rdList = [Select Id from npe03__Recurring_Donation__c where Stripe_Subscription_Id__c =: wrapperResponse.data.object_z.Id limit 1];
                String RdID = !rdList.isEmpty() ? rdList[0].Id : '';
                String api = '';
                if(String.isNotEmpty(RdID)){
                    if(String.isNotEmpty(wrapperResponse.data.object_z.default_source)){
                        api = wrapperResponse.data.object_z.customer+'/sources/'+wrapperResponse.data.object_z.default_source;
                    }
                    System.debug('Webhook subscription source api -> ' + api);
                    HttpResponse responseJson =  StripeConnection.getCustomer(api, Null);
                    system.debug(responseJson.getBody());
                    if(responseJson.getStatusCode() < 200 || responseJson.getStatusCode() > 299){
                        throw new StripeAPIException('Error while retirving card infomation from stripe : ' + responseJson.getBody());
                    }
                    StripeWebhookSubscription.ResponseWrapper rw = (StripeWebhookSubscription.ResponseWrapper) System.JSON.deserialize (responseJson.getBody(), StripeWebhookSubscription.ResponseWrapper.class);
                    npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
                    if(wrapperResponse.data.object_z.status == 'cancelled'){
                        rd.npsp__Status__c = 'Cancelled';
                    }
                    else if(wrapperResponse.data.object_z.status == 'incomplete_expired' || wrapperResponse.data.object_z.status == 'incomplete'){
                        rd.npsp__Status__c = 'Paused';
                    }
                    else if(wrapperResponse.data.object_z.status == 'unpaid' || wrapperResponse.data.object_z.status == 'past_due'){
                        rd.npsp__Status__c = 'Held';
                    }
                    upsert rd;
                }    
            }     
        }
        catch(Exception e){
            system.debug(e);
            ApexLogCreator.createApexLog('StripeWebhookSubscription', e.getMessage(), 'handleRecurringDonation', e.getStackTraceString());
        }   
    }
    
    public class ResponseWrapper{
        public String id;
        public Card card;
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
    
    public class StripeAPIException extends Exception {}
}