@RestResource(urlMapping='/api/webhooks/Charge')
global class StripeWebhookCharge { 
    @HttpPost
    global static void handleCharge() {
        try {
            if(Stripe_Setting__c.getValues('Default').Activation__c) {
                Boolean insertCharge = true;
                List<String> methodTypes = System.Label.Stripe_Payment_Methods.toUpperCase().split(';');
                String paymentMethodType;
                RestRequest request = RestContext.request;
                Map<String, Object> jsonWrapper = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
                Map<String, Object> dataWrapper = (Map<String, Object>)jsonWrapper.get('data');
                Map<String, Object> chargeWrapper = (Map<String, Object>)dataWrapper.get('object');
                Map<String, Object> paymentMethodWrapper = (Map<String, Object>)chargeWrapper.get('payment_method_details');
                Map<String, Object> sourceWrapper = (Map<String, Object>)chargeWrapper.get('source');
                Map<String, Object> outcomeWrapper = (Map<String, Object>)chargeWrapper.get('outcome');
                Map<String, Object> metadataWrapper = (Map<String, Object>)chargeWrapper.get('metadata');
                Boolean createRD = false;
                Boolean charge_captured = Boolean.valueOf(chargeWrapper.get('captured'));
                
                Charge__c charge = new Charge__c(
                    Stripe_Charge_Id__c = String.valueOf(chargeWrapper.get('id')),
                    Stripe_Payment_Intent_Id__c = String.valueOf(chargeWrapper.get('payment_intent')),
                    Stripe_Charge_Status__c = String.valueOf(chargeWrapper.get('status')),
                    Stripe_Customer_Id__c = String.valueOf(chargeWrapper.get('customer')),
                    Stripe_Invoice_Id__c = String.valueOf(chargeWrapper.get('invoice')),
                    Stripe_Charge_Amount__c =  ((Decimal)(chargeWrapper.get('amount')))/100,
                    Method_Type__c = String.valueOf(paymentMethodWrapper.get('type')),
                    Payment_Created_Date__c = DateTime.newInstance((Long)(chargeWrapper.get('created'))*1000).date(),
                    Stripe_Payment_Method_Id__c = String.valueOf(chargeWrapper.get('payment_method')),
                    Failure_Code__c = String.valueOf(chargeWrapper.get('failure_code')),
                    Outcome_Reason__c = String.valueOf(outcomeWrapper.get('reason'))
                );
                if (charge.Method_Type__c == 'card') {
                    paymentMethodType = 'Credit Card';//Actual Method_Type__c from coming charge is different and custom label payment type are different
                    Map<String, Object> cardWrapper = (Map<String, Object>)paymentMethodWrapper.get('card');
                    charge.Card_Last_Digits__c = String.valueOf(cardWrapper.get('last4'));
                    charge.Card_Type__c = String.valueOf(cardWrapper.get('brand'));
                    charge.Card_Token__c = String.valueOf(cardWrapper.get('fingerprint'));
                    charge.Card_Expiration_Month__c = String.valueOf(cardWrapper.get('exp_month'));
                    charge.Card_Expiration_Year__c = String.valueOf(cardWrapper.get('exp_year'));
                } else if (charge.Method_Type__c == 'au_becs_debit') {
                    paymentMethodType = 'Direct Debit'; //Actual Method_Type__c from coming charge is different and custom label payment type are different
                    Map<String, Object> accountWrapper = (Map<String, Object>)paymentMethodWrapper.get('au_becs_debit');
                    charge.Account_Token__c = String.valueOf(accountWrapper.get('fingerprint'));
                    String BSB = String.valueOf(accountWrapper.get('bsb_number'));
                    charge.Account_BSB__c = BSB.left(3)+'-'+BSB.right(3);
                    charge.Account_Last_Digits__c = String.valueOf(accountWrapper.get('last4'));
                }
                //metadata will always from Sequence Shift only
                //that also means that for recurring payments when charge is prepared from Stripe
                String campaign_code;
                if (!metadataWrapper.isEmpty()) {
                    if (metadataWrapper.containsKey('Campaign-Id')) {
                        campaign_code = String.valueOf(metadataWrapper.get('Campaign-Id'));
                        List<Campaign> campaignRec = [SELECT Id FROM Campaign WHERE Campaign_Code__c =: campaign_code LIMIT 1];
                        if (campaignRec.size() > 0) {
                            charge.Campaign_Id__c = campaignRec[0].Id;   
                        }   
                    }
                    if (metadataWrapper.containsKey('IsRecurring')) {
                        charge.Is_Recurring__c = Boolean.valueOf(metadataWrapper.get('IsRecurring'));
                    }
                    if (metadataWrapper.containsKey('donation_source')) {
                        charge.Donation_Source__c = String.valueOf(metadataWrapper.get('donation_source'));
                        Stripe_Charge_Settings__c mc = Stripe_Charge_Settings__c.getOrgDefaults();
                        List<String> sources = mc.Type_of_donation_source__c.toUpperCase().split(',');
                        if (charge.Donation_Source__c != null && !sources.contains(charge.Donation_Source__c.toUpperCase())) {
                            insertCharge = false;
                        }
                    }
                    if (metadataWrapper.containsKey('opp-id')) {
                        charge.Opportunity_Id__c = String.valueOf(metadataWrapper.get('opp-id'));
                    }
                    if (metadataWrapper.containsKey('rg-id')) {
                        charge.Recurring_Donation_Id__c = String.valueOf(metadataWrapper.get('rg-id'));
                    }
                    
                    //Need to update the custom_parameter_frequency
                    if (metadataWrapper.containsKey('custom_parameter_frequency')) {
                        charge.RD_Installment_Every__c = String.valueOf(metadataWrapper.get('custom_parameter_frequency'));
                        createRD = true;
                    }
                    //Need to update the custom_parameter_frequency
                    
                    if (metadataWrapper.containsKey('period')) {
                        charge.RD_Installment_Period__c = String.valueOf(metadataWrapper.get('period'));
                        createRD = true;
                    }
                    if (metadataWrapper.containsKey('day_of_month')) {
                        charge.RD_Installment_Day_Of_Month__c = String.valueOf(metadataWrapper.get('day_of_month'));
                        createRD = true;
                    }
                    if (metadataWrapper.containsKey('effective_date')) {
                        charge.RD_Installment_Effective_Date__c = Date.valueOf(String.valueOf(metadataWrapper.get('effective_date')));
                        createRD = true;
                    }
                    if (metadataWrapper.containsKey('number_of_installment')) {
                        charge.RD_Number_of_Installments__c = String.valueOf(metadataWrapper.get('number_of_installment'));
                        createRD = true;
                    }
                    if(metadataWrapper.containsKey('is_processed')) {
                        if(Boolean.valueOf(metadataWrapper.get('is_processed'))) {
                         	insertCharge = false;   
                        }
                    }
                }
                
                System.debug('charge -> ' + charge);
                //Charge record should be created only when
                //1. Donation source is valid
                //2. Payment method types are valid
                //3. Charge was captured by stripe
                if (insertCharge && methodTypes.contains(paymentMethodType.toUpperCase()) && charge_captured) {
                 	insert charge;   
                }
                
                if(String.isNotBlank(charge.Recurring_Donation_Id__c) && !charge_captured) {
                    List<npe03__Recurring_Donation__c> rdList = [SELECT Id, npsp__Status__c FROM npe03__Recurring_Donation__c WHERE Id =: charge.Recurring_Donation_Id__c];
                    if(rdList.size() > 0) {
                        if(rdList[0].npsp__Status__c != 'Active') {
                            rdList[0].npsp__Status__c = 'Active';
                        }
                        update rdList;
                    }
                } 
                
                if (createRD && charge.Is_Recurring__c) {
                    //Create RD in active status so that Opportunity and Payment get created
                    //Also the active status will create a active subscription on Stripe
                    //Will get createRD only when the payment has been done from PHP system.
                    System.debug('Create RD from charge webhook');
                    List<String> splitCustomerId = charge.Stripe_Customer_Id__c.split('_');//Split the customer id for SOSL
                    Set<String> customerIds = new Set<String>{'*' + splitCustomerId[1] + '*'}; //to be considered in SOSL query as wildcard character
                    Map<String, Contact> contactMap = getContactCustomerIdMap(customerIds);
                    Contact con = contactMap.get(charge.Stripe_Customer_Id__c);
                    
                    Stripe_Setting__c stripeSettings = Stripe_Setting__c.getInstance('Default');
                    charge.Campaign_Id__c = stripeSettings.Default_Campaign__c;
                    
                    npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(
                        npe03__Organization__c = con.AccountId,
                    	npe03__Contact__c = con.Id,
                        npe03__Date_Established__c = charge.Payment_Created_Date__c,
                        npe03__Amount__c = charge.Stripe_Charge_Amount__c,
                        Payment_Gateway__c = 'Stripe',
                        npsp__PaymentMethod__c = charge.Method_Type__c,
                        npsp__InstallmentFrequency__c = Decimal.valueOf(charge.RD_Installment_Every__c),
                        npe03__Installment_Period__c = charge.RD_Installment_Period__c,
                        npsp__Day_of_Month__c = charge.RD_Installment_Day_Of_Month__c,
                        npsp__StartDate__c = charge.RD_Installment_Effective_Date__c,
                        Stripe_payment_method_id__c = charge.Stripe_Payment_Method_Id__c,
                        npe03__Recurring_Donation_Campaign__c = charge.Campaign_Id__c
                    );
                    if(charge_captured) {
                        rd.npsp__Status__c = 'Active';
                    }
                    if(String.isEmpty(charge.RD_Number_of_Installments__c) || charge.RD_Number_of_Installments__c == 'Forever') {
                        rd.npsp__RecurringType__c = 'Open';
                    } else {
                        rd.npsp__RecurringType__c = 'Fixed';
                        rd.npe03__Installments__c = Decimal.valueOf(charge.RD_Number_of_Installments__c);
                    }
                    insert rd;
                    
                    charge.Recurring_Donation_Id__c = rd.Id;
                    update charge;
                    
                    StripeSubscriptionQueueable queueable = new StripeSubscriptionQueueable(charge, rd);
                    System.enqueueJob(queueable);
                }
            }
        } catch(Exception e) {
            ApexLogCreator.createApexLog('StripeWebhookCharge', e.getMessage(), 'handleCharge', e.getStackTraceString());
            system.debug(e);
        }
    }
    
    private static Map<String, Contact> getContactCustomerIdMap(Set<String> customerIds) {
        String searchTerm = String.join(new List<String>(customerIds), ' OR ');
        List<List<SObject>> listOfResults = [FIND :searchTerm IN ALL FIELDS RETURNING Contact(Id, Name, AccountId, Stripe_Customer_Id__c, Stripe_Customer_Ids__c)];
        Map<String, Contact> contactMap = new Map<String, Contact>();
        
        System.debug('listOfResults -> ' + listOfResults);
        for(Contact con: (Contact[])listOfResults[0]) {
            if(con.Stripe_Customer_Ids__c != null) {
                List<String> customers = con.Stripe_Customer_Ids__c.split(',');
                for(String cus: customers) {
                    contactMap.put(cus, con);
                }
            } else {
                contactMap.put(con.Stripe_Customer_Id__c, con);
            }
        }
        return contactMap;
    }
}