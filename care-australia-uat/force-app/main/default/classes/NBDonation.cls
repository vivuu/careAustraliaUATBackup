@RestResource(urlMapping='/NBDonation/*')
global with sharing class NBDonation {

     @HttpPost
    global static String doPost(String session, String firstName, String lastName, String campaign, 
          String paymentMode, String paymentMethod, Decimal amount, 
          String utmSource, String utmCampaign, String utmMedium,
          String street, String city, String state, String postalCode, String country,
          String phone, String email, String formURL,
          String contactMode, String organisation, Integer triggerDupe,
          String reference, String truncatedCard, String cardType,
          String paymentDay, String expM, String expY) {
          
          String resultPaymentName = NBDonationHelper.doDonation(session, firstName, lastName, campaign, 
               paymentMode, paymentMethod, amount, 
               utmSource, utmCampaign, utmMedium,
               street, city, state, postalCode, country,
               phone, email, formURL,
               contactMode, organisation, triggerDupe,
               reference, truncatedCard, cardType,
               paymentDay, expM, expY
               );

          return resultPaymentName;
	}
    
}