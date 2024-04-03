@RestResource(urlMapping='/NBContact/*')
global with sharing class NBContact {
    
    /**
     * Get a contact by ID. Contact information is never sent back to the user's browser from the Donation Bridge.
     * Uses the NBContactHelper to execute functionality.
     * Gordon Jackson October 2021 gordon@gordonjackson.org 
     */
    @HttpGet
    global static Contact doGet() {
        RestRequest req = RestContext.request;
        
        String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Contact result = [SELECT Id, AccountId, Email, MobilePhone, HomePhone FROM Contact WHERE Id = :contactId];
        return result;
    }
    
    @HttpPost
    global static String doPost(String sessionId, String firstName, String lastName, String campaign, String paymentMode, String amount, 
                                String street, String city, String state, String postalCode, String country,
                                String phone, String email, String formURL,
                                String contactMode, String organisation) {
		return NBContact.doPost(sessionId, firstName, lastName, campaign, paymentMode, amount, street, city, state, postalCode, country, phone, email, formURL, contactMode, organisation, 0);
	}
    
 	@HttpPut
    global static String doPost(String sessionId, String firstName, String lastName, String campaign, String paymentMode, String samount, 
                                String street, String city, String state, String postalCode, String country,
                                String phone, String email, String formURL,
                                String contactMode, String organisation, Integer triggerDupe) {
        String returnId = 'ERROR';
        Decimal amount = Decimal.valueOf( samount );
		Database.DMLOptions dml = new Database.DMLOptions(); 
		phone = NBContactHelper.preProcessPhone(phone);
        phone = NBContactHelper.processAusMobile(phone);

		System.debug('PHONE: ' + phone);
		Boolean isTen = NBContactHelper.isTen(phone);
		// Split by mode
		if ('organisation' == contactMode) {
            try {
                returnId = NBContactHelper.processOrganisation(sessionId, firstName, lastName, campaign, 
                paymentMode, amount, street, city, state, postalCode, country, phone, email, formURL, 
                contactMode, organisation, triggerDupe, isTen);
            }
            catch(Exception ex) {
                returnId = 'ERROR';
            }
		}
        else {
            try {
                returnId = NBContactHelper.processIndividual(sessionId, firstName, lastName, campaign, 
                paymentMode, amount, street, city, state, postalCode, country, phone, email, formURL, 
                contactMode, organisation, triggerDupe, isTen);
            }
            catch(Exception ex) {
                returnId = 'ERROR';
            }
        }
        return returnId;
    }
}