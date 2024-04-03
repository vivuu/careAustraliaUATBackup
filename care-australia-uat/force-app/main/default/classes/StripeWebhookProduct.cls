@RestResource(urlMapping='/api/webhooks/productapi')
global class StripeWebhookProduct {
	@HttpPost
    global static void handleProduct(){
        // Get's the data from stripe to salesforce (contact object)
     	try{
            if(Stripe_Setting__c.getInstance('Default').Activation__c){
                RestRequest request = RestContext.request;
                RestResponse response = RestContext.response;
                
                Campaign camp = new campaign();
                String requestBody=request.requestBody.toString();
                
                StripeProductWrapper wrapperResponse = StripeProductWrapper.parse(requestBody);
                
                camp.Stripe_Product_Id__c = wrapperResponse.data.object_z.id;
                camp.id = wrapperResponse.data.object_z.metadata.sf_campaign_id;
                camp.Name = wrapperResponse.data.object_z.name;
                camp.IsActive = wrapperResponse.data.object_z.active;
                
                if(String.isEmpty(wrapperResponse.data.object_z.metadata.sf_campaign_id)){
                    upsert camp Stripe_Product_Id__c;    
                }
                else{
                    upsert camp id;
                }
            }   
        }
        catch(Exception e){
            system.debug(e);
        }   
    }
}