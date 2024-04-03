/**
 * Class Name: StripeConnection
 * Auhtor: Gerent Team
 * Description: all the callout related methods
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */
public class StripeConnection {
    /*@future
    public static void updateSObject(Id sfId, String stripeId){
        SObject record = sfId.getSObjectType().newSObject(sfId);
        if(String.valueOf(sfId).startsWith('003')){
            record.put('Stripe_Customer_Id__c',stripeId);
        }else{
            record.put('stripe_product_id__c',stripeId);
        }
        update record;
    }*/

    public static HttpResponse postCharge(String body) {
        //get the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Charges_API');
        HttpResponse response = httpCallout.doCallout(null, body);    
        return response;
    }
    
    public static HttpResponse getCustomer(String stripeId, String body)
    {
        //get the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Get_Customer_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);    
        return response;
    }

    public static HttpResponse postCustomer(String stripeId, String body)
    {
        //Post the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Customer_API');
        //tpResponse response = new HttpResponse();
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    
    @future(callout=true)
    public static void postCustomerFuture(String stripeId, String body)
    {
        //Post the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Customer_API');
        //tpResponse response = new HttpResponse();
        HttpResponse response = httpCallout.doCallout(stripeId, body);
    }

    public static HttpResponse postCustomerSource(String stripeId, String body)
    {
        //Post the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Customer_API');
        //tpResponse response = new HttpResponse();
        HttpResponse response = httpCallout.doCalloutForCustomerSource(stripeId, body);
        return response;
    }
    
    public static HttpResponse deleteCustomer(String stripeId)
    {
        //Post the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Delete_Customer_API');
        //tpResponse response = new HttpResponse();
        HttpResponse response = httpCallout.doCallout(stripeId, '');
        return response;
    }

    /*
    public static void getSubscription(String stripeId, String body)
    {
        //get the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Get_Subscription_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
       
    }*/
    
    //@future (callout=true)
    public static HttpResponse postSubscription(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Subscription_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    /*
    public static HttpResponse postSubscriptionSchedule(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Subscription_Schedule_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }*/
    
    public static HttpResponse postPaymentMethod(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Payment_Method_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    
     public static HttpResponse getPaymentMethod(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Get_Payment_Method_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    
    public static HttpResponse postProduct(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Product_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;        
    }
    /*
    public static HttpResponse postPrice(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Price_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    
    public static HttpResponse postToken(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Token_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }*/
    
    public static HttpResponse postPaymentIntent(String stripeId, String body)
    {
        //Post the data from salesforce to stripe Subscription Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_PaymentIntent_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    public static HttpResponse postSetupIntent(String stripeId, String body)
    {
        //Create SetupIntent for DD transaction
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_SetupIntent_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    
    public static HttpResponse getSearchInvoice(String query) {
        //Get the data from salesforce to stripe Invoice Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Get_Invoice_Search_API');
        HttpResponse response = httpCallout.doCalloutForInvoiceSearch(query);
        return response;
    }
    
    public static HttpResponse getCharge(String stripeId) {
        //get the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Get_Charges_API');
        HttpResponse response = httpCallout.doCallout(stripeId, null);    
        return response;
    }
    
    public static HttpResponse postRefund(String body) {
        //get the data from salesforce to stripe
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Refund_Charge_API');
        HttpResponse response = httpCallout.doCallout(null, body);
        return response;
    }
    
    /*public static HttpResponse getInvoice(String stripeId, String body)
    {
        //Get the data from salesforce to stripe Invoice Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Get_Invoice_Search_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;
    }
    
    public static HttpResponse postCheckoutSession(String stripeId, String body)
    {
      	//Get the data from salesforce to stripe CheckoutSession Object
        StripeHttpCalloutHelper httpCallout = new StripeHttpCalloutHelper('Stripe_Post_Checkout_Session_API');
        HttpResponse response = httpCallout.doCallout(stripeId, body);
        return response;  
    }*/
}