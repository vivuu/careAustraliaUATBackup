@RestResource(urlMapping='/api/webhooks/PaymentMethod')
global without sharing class StripeWebhookPaymentMethod {
    @HttpPost
    global static void handlePaymentMethod(){
        try{
            if(Stripe_Setting__c.getInstance('Default').Activation__c){
                RestRequest request = RestContext.request;
                RestResponse response = RestContext.response;
                
                system.debug(request.requestBody.toString() + 'Testing Apex');
                system.debug(JSON.deserializeUntyped(request.requestBody.toString()) + 'Testing Apex');
                String requestBody=request.requestBody.toString();
                
                StripePaymentMethodWrapper wrapperResponse = StripePaymentMethodWrapper.parse(requestBody);
                
                String conId = [Select Id 
                                   from contact where stripe_customer_id__c =: wrapperResponse.data.object_z.customer limit 1].id;
                
                list<npe03__Recurring_Donation__c> RDs = [Select Id, npsp__PaymentMethod__c, Card_Token__c, npsp__CardLast4__c, Card_Type__c, npsp__CardExpirationMonth__c,npsp__CardExpirationYear__c
                                                        from npe03__Recurring_Donation__c where npe03__Contact__c =: conId];
                
                for(npe03__Recurring_Donation__c RD :RDs){
                    RD.npsp__PaymentMethod__c = 'Credit Card'; 
                    RD.Card_Token__c= wrapperResponse.data.object_z.card.fingerprint;
                    RD.Card_Number_Masked__c = ('************'+wrapperResponse.data.object_z.card.last4);
                    RD.Card_Type__c = wrapperResponse.data.object_z.card.brand;
                    RD.npsp__CardExpirationMonth__c = String.valueOf((integer)wrapperResponse.data.object_z.card.exp_month);
                    RD.npsp__CardExpirationYear__c = String.valueOf((integer)wrapperResponse.data.object_z.card.exp_year);
                }
                
                //Update RDs;
            }
        }catch(Exception e){
            system.debug(e);
        }   
    }

}