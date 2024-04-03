@RestResource(urlMapping='/NBDonationBatch/*')
global with sharing class NBDonationBatch {
    /*
    Base Data Model:
        session_id
        first_name
        last_name
        campaign
        payment_mode (one-time, regular)
        payment_method (paypal, credit card, ach)
        amount
        street
        city
        state
        postal_code
        country
        phone
        email
        contact_mode
        organisation
        form_url
        utm_source
        utm_medium
        utm_campaign

    Data Model A (CC):
        transaction_id
        card_type
        truncated_card
        exp_month
        exp_year
        processed_date

    Data Model B (PayPal):
        payor_id
        transaction_id
        processed_date

    Data Model C (Reg CC):
        transaction_id
        payment_day
        card_type
        truncated_card
        exp_month
        exp_year
        processed_date

    Data Model D (Reg ACH):
        financial_institution
        account_number
        account_name
        bsb
        payment_day
    */
    @HttpPost
    global static String doPost( String[] donation_data ) {
        String results = '';
        System.debug('Payloads Size: ' + donation_data.size() );
        for (Integer i = 0; i<donation_data.size(); i++) {
            String donation = donation_data[i];
            Integer index = 0; // The session appears 2x, so start with 1 and not 0
            List<String> donation_array = donation.split(',');
            System.debug('Payload Size: ' + donation_array.size() );
            String session = donation_array.get(index);
            String session2 = donation_array.get(index++);

            System.debug('Sessions: ' + session + ' ' + session2);

            String ipAddress = donation_array.get(index++);
            String firstName = donation_array.get(index++); // firstName
            String lastName = donation_array.get(index++); // lastName
            String campaign = donation_array.get(index++); // campaign
            String paymentMode = donation_array.get(index++); // paymentMode
            String paymentMethod = donation_array.get(index++); // paymentMethod
            Decimal amount = Decimal.valueOf(donation_array.get(index++)); // amount
            String street = donation_array.get(index++); // street
            String city = donation_array.get(index++); // city
            String state = donation_array.get(index++); // state
            String postalCode = donation_array.get(index++); // postalCode
            String country = donation_array.get(index++); // country
            String phone = donation_array.get(index++); // phone
            String email = donation_array.get(index++); // email
            String contactMode = donation_array.get(index++); // contactMode
            String organisation = donation_array.get(index++); //  organisation
            String formURL = donation_array.get(index++); // formURL
            String utmSource = donation_array.get(index++); // utmSource
            String utmCampaign = donation_array.get(index++); // utmCampaign
            String utmMedium = donation_array.get(index++); // utmMedium
            String reference = donation_array.get(index++); //  reference (transaction_id)
            String paymentDay = donation_array.get(index++); //  paymentDay
            String truncatedCard = donation_array.get(index++); //  truncatedCard, account number
            String cardType = donation_array.get(index++); //  cardType, finacial institution
            String expM = donation_array.get(index++); //  expM, bsb
            String expY = donation_array.get(index++); //  expY, account_name
            
            String processedDate = '';            
            try {
                Integer checkIndexPD = index++;
                System.debug( 'CheckIndex: ' + checkIndexPD + ' Last Item: ' + donation_array.get( ( donation_array.size() - 1 ) ) );
                if ( checkIndexPD < donation_array.size() ) {
                    processedDate = donation_array.get( checkIndexPD );
                }
            }
            catch (Exception expd) {
                System.debug('Processed Date not passed for ' + session);
            }
            
            String serviceFee = '';            
            try {
                Integer checkIndexSF = index++;
                System.debug( 'CheckIndex: ' + checkIndexSF + ' Last Item: ' + donation_array.get( ( donation_array.size() - 1 ) ) );
                if ( checkIndexSF < donation_array.size() ) {
                    serviceFee = donation_array.get( checkIndexSF );
                }
            }
            catch (Exception expsf) {
                System.debug('Service Fee not passed for ' + session);
            }
			
            Integer triggerDupe = 0;

            String paymentResult = NBDonationHelper.doDonation(
                session, firstName, lastName, campaign, 
                paymentMode, paymentMethod, amount, 
                utmSource, utmCampaign, utmMedium, 
                street, city, state, postalCode, country, 
                phone, email, formURL, contactMode, organisation, triggerDupe, 
                reference, truncatedCard, cardType, paymentDay, expM, expY, processedDate, serviceFee);
            results = results + paymentResult + '||||';
        }
        return results;

    }

}