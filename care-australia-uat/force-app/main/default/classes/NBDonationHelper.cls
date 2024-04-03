public class NBDonationHelper {
    
    public static String doDonation(
        String session, String firstName, String lastName, String campaign, 
        String paymentMode, String paymentMethod, Decimal amount, 
        String utmSource, String utmCampaign, String utmMedium,
        String street, String city, String state, String postalCode, String country,
        String phone, String email, String formURL,
        String contactMode, String organisation, Integer triggerDupe,
        String reference, String truncatedCard, String cardType,
        String paymentDay, String expM, String expY) 
    {
     	String processedDateHolder = '';
     	String serviceFeeHolder = '';
        return doDonation(session, firstName, lastName, campaign, paymentMode, paymentMethod, amount, utmSource, utmCampaign, utmMedium,
        	street, city, state, postalCode, country, phone, email, formURL, contactMode, organisation, triggerDupe, reference, truncatedCard, 
			cardType, paymentDay, expM, expY, processedDateHolder, serviceFeeHolder);
    }

    public static String doDonation(
        String session, String firstName, String lastName, String campaign, 
        String paymentMode, String paymentMethod, Decimal amount, 
        String utmSource, String utmCampaign, String utmMedium,
        String street, String city, String state, String postalCode, String country,
        String phone, String email, String formURL,
        String contactMode, String organisation, Integer triggerDupe,
        String reference, String truncatedCard, String cardType,
        String paymentDay, String expM, String expY, String processedDate, String serviceFee) 
    {

        if ('' == campaign) {
            return session + '====' + 'ERROR - no campaign';
        }

        Boolean hasError = false; 
        String returnId = ''; 
        String resultPaymentName;

        try {
            Database.DMLOptions dml = new Database.DMLOptions(); 
            phone = NBContactHelper.preProcessPhone(phone);
            phone = NBContactHelper.processAusMobile(phone);
            Boolean isTen = NBContactHelper.isTen(phone);
            String accountId;
            String contactId;
            
            // Split by mode
            if ('organisation' == contactMode) {
                accountId = NBContactHelper.processOrganisation(session, firstName, lastName, campaign, 
                paymentMode, amount, street, city, state, postalCode, country, phone, email, formURL, 
                contactMode, organisation, triggerDupe, isTen);
                contactId = accountId;
            }
            else {
                contactId = NBContactHelper.processIndividual(session, firstName, lastName, campaign, 
                paymentMode, amount, street, city, state, postalCode, country, phone, email, formURL, 
                contactMode, organisation, triggerDupe, isTen);
            }
    
            // Check for error
            if ( hasError ) {
                return session + '====' + 'ERROR - did not create Account-Contact';
            }
    
            Id campaignId = NBOpportunityHelper.getCampaignId(campaign);
            
            if ( 'one-off' == paymentMode ) {     
                resultPaymentName = NBOpportunityHelper.processOneTime(contactId, amount, session, campaign, paymentMethod, paymentMode, formURL, email, firstName, lastName, utmSource, utmCampaign, utmMedium, campaignId, processedDate, serviceFee);
                returnId = NBPaymentHelper.processOneTime(resultPaymentName, session, amount, paymentMethod, reference, truncatedCard, cardType, email, paymentMode, paymentDay, expM, expY, processedDate);
            }
            else if ( 'monthly' == paymentMode ) {
                if ('organisation' == contactMode) {
                    resultPaymentName = NBOpportunityHelper.processMonthlyOrg(contactId, amount, session, campaign, paymentMethod, paymentMode, formURL, email, firstName, lastName, utmSource, utmCampaign, utmMedium, campaignId, reference, truncatedCard, cardType, email, paymentDay, expM, expY);
                }
                else {
                    resultPaymentName = NBOpportunityHelper.processMonthly(contactId, amount, session, campaign, paymentMethod, paymentMode, formURL, email, firstName, lastName, utmSource, utmCampaign, utmMedium, campaignId);
                    returnId = NBPaymentHelper.processMonthly(resultPaymentName, session, amount, paymentMethod, reference, truncatedCard, cardType, email, paymentMode, paymentDay, expM, expY);
                }
            }  
        }
        catch( Exception de) {
            hasError = true;
            returnId = de.getMessage();
        }
              
        // Check for error
        if ( hasError ) {
            return session + '====' + returnId;
        }
        return session + '====' + resultPaymentName;
    }

}