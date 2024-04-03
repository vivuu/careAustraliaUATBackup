@RestResource(urlMapping='/NBPayment/*')
global with sharing class NBPayment {
    /**
     * Creates the payment reference for one-time gifts against the opportunity.
     * Gordon Jackson October 2021 gordon@gordonjackson.org
     */
 	@HttpPost
    global static String doPost(String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode, String paymentDay, String expM, String expY) {
        RestRequest req   = RestContext.request;
        RestResponse res  = RestContext.response;
		String status = 'ERROR';
  
        if ( 'onetime' == paymentMode ) {
            status = NBPaymentHelper.processOneTime(paymentId, sessionId, amount, paymentMethod, reference, truncatedCard, cardType, donorEmail, paymentMode, paymentDay, expM, expY);
        }
        else if ( 'monthly' == paymentMode ) {
            status = NBPaymentHelper.processMonthly(paymentId, sessionId, amount, paymentMethod, reference, truncatedCard, cardType, donorEmail, paymentMode, paymentDay, expM, expY);
        }  
        return status;
    }    
}