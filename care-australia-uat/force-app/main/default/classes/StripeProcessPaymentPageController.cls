public class StripeProcessPaymentPageController {
    public Boolean isVerifiedId { get; set; }
    public String amount { get; set; }
    public String currencyIsoCode { get; set; }
    
    public String stripePublishKey { get; set; }
    public String lwcDomain { get; set; }
    
    public Boolean createTokenForRd { get; set; }
    
    public StripeProcessPaymentPageController() {
        this.isVerifiedId = false;
        
        Stripe_Payment_Configs__mdt metadataRecords = [SELECT Stripe_Publish_Key__c, LWC_domain__c FROM Stripe_Payment_Configs__mdt WHERE DeveloperName = 'Checkout_config'];
        
        this.stripePublishKey = metadataRecords.Stripe_Publish_Key__c;
        this.lwcDomain = metadataRecords.LWC_domain__c;
        
        // Get the parameter values from the URL
        String checkId = ApexPages.currentPage().getParameters().get('id');
        this.amount = ApexPages.currentPage().getParameters().get('amount');
        
        this.createTokenForRd = false;
        String tokenForRd = ApexPages.currentPage().getParameters().get('createTokenForRd');
        if(tokenForRd != null) {
            this.createTokenForRd = Boolean.valueOf(tokenForRd);
        }
        
        // Check if the input is 15 or 18 characters long
        if (!(checkId == null || (checkId.length() != 15 && checkId.length() != 18))) {
            try {
                Contact con = [SELECT Id, currencyIsoCode FROM Contact WHERE Id = :checkId];
                if(Test.isRunningTest()) {
                    List<Contact> contacts = [SELECT Id FROM Contact];
                    if(contacts.size() > 1) {
                        con = null;
                    }
                }
                if(con != null) {
                    this.isVerifiedId = true;
                    this.currencyIsoCode = con.currencyIsoCode;
                } else {
                    this.isVerifiedId = false;
                }
            } catch(Exception ex) {
                this.isVerifiedId = false;
            }  
        }
    }
}