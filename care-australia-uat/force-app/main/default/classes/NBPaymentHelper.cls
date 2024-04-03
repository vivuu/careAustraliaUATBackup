public class NBPaymentHelper {
    public static String processOneTime(String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode, String paymentDay, String expM, String expY) {
    	String processedDateHolder = '';
        return processOneTime(paymentId, sessionId, amount, paymentMethod, reference, truncatedCard, cardType, donorEmail, paymentMode, paymentDay, expM, expY, processedDateHolder);
    }

    public static String processOneTime(String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode, String paymentDay, String expM, String expY, String processedDate) {
        Id opportunityId = null;
        String status = 'ERROR';
        npe01__OppPayment__c payment = null;
        System.debug('Finding Payment ' + paymentId);
        List<npe01__OppPayment__c> pResult = [select Id, Name, npe01__Opportunity__c from npe01__OppPayment__c where Name = :paymentId];            
        if ( null != pResult ) {
            for (npe01__OppPayment__c pFound : pResult) {     
                System.debug('Payment Found ' + pFound.Name);
                opportunityId = pFound.npe01__Opportunity__c;
                payment = pFound;
            }
        }  
        
        if (null == opportunityId) {
            System.debug('Opportunity Not Found');
            status = 'ERROR';
        }
        
        Opportunity o;            
        Opportunity[] os = [SELECT Id, StageName, Name, CampaignId, ContactId, AccountId FROM Opportunity where Id = :opportunityId];
        date donationDate = date.today();
        String donationDateString = donationDate.format();
        if (os.size() > 0) {
            o = os[0];
        }          
        
        if ( null != o && ('Closed Won' == o.StageName || 'Closed Lost' == o.StageName) ) {
            System.debug('Opportunity Closed');
            status = 'ERROR';
        }
        else if ( null != payment ) {     
            System.debug('Closing Payment ' + payment.Name + ' ' + processedDate);
            DateTime processedDateValue = system.Today();
            Date processedDateOnlyValue = system.Today();
            if ( '' != processedDate ) {               
                Datetime processedDateObj = null;        
                try {                   
                    processedDate = processedDate.replace('T', ' ');
                    processedDate = processedDate.substringBefore('.');
                    System.debug('Date to parse: ' + processedDate);
                    Datetime parsedDate = Datetime.valueOf(processedDate);  
                    System.debug('Date before tz: ' + parsedDate.format('yyyy-MM-dd HH:mm:ss'));
                    String zone = 'Australia/Sydney';
                    TimeZone target = TimeZone.getTimeZone(zone);
                    Integer offsetAtUTC = target.getOffset(parsedDate);
                    processedDateObj = parsedDate.addSeconds(offsetAtUTC / 1000);
                    processedDateValue = Datetime.valueOf( processedDateObj.format('yyyy-MM-dd HH:mm:ss') );
                    System.debug('Date parsed to: ' + processedDateObj.format('yyyy-MM-dd HH:mm:ss'));
                    processedDateOnlyValue = date.newinstance(processedDateValue.year(), processedDateValue.month(), processedDateValue.day());
                }
                catch ( Exception dateEx ) {
                    System.debug('Date Parse Error: ' + processedDate);
                }
            }            
            payment.npe01__Payment_Date__c = processedDateOnlyValue;
            payment.npe01__Check_Reference_Number__c = reference;
            payment.npe01__Payment_Amount__c = amount;
            payment.npe01__Paid__c = true;
            payment.npe01__Payment_Method__c = paymentMethod;       
            payment.npsp__Payment_Acknowledgment_Status__c = 'To be Emailed';
            payment.Payment_Result__c = 'Success';
            payment.Response_Code__c = '0';
            payment.Result_Description__c = 'Approved';
            if ('Credit Card' == paymentMethod) {
                // Get the first and last name of the contact to add as the Payee
                Contact contact = null;
                Id contactId = o.ContactId;
                Contact[] contact_lookup = [SELECT Id, FirstName, LastName FROM Contact where Id = :contactId];
                if (contact_lookup.size() > 0) {
                    contact = contact_lookup[0];
                }  
                payment.Card_Number_Masked__c = truncatedCard;
                payment.Card_Type__c = cardType;  
                payment.Merchant_Category__c = 'Bambora';
                payment.npsp__Card_Expiration_Month__c = expM;
                payment.npsp__Card_Expiration_Year__c = expY;
                if ( null != contact ) {
                        payment.Payee_Name__c = contact.FirstName + ' ' + contact.LastName;   
                }
            }
            else if ('paypal' == paymentMethod) {
                payment.Merchant_Category__c = 'PayPal';
                payment.npe01__Check_Reference_Number__c = reference;
            }
            payment.Donor_Email__c = donorEmail;

            update payment;
            System.debug('Payment Updated' + payment.Name);
            // Close the Opportunity
            Id accountId = o.AccountId;
            Account account = null;
            Account[] account_lookup = [SELECT Id, Name FROM Account where Id = :accountId];
            if (account_lookup.size() > 0) {
                account = account_lookup[0];
            }  
            o.StageName = 'Closed Won';
            String accountName = '';
            if ( null != account ) {
                accountName = account.Name;
            }                
            o.Name = accountName + ' Donation ' + donationDateString;
            o.npsp__Acknowledgment_Status__c = 'To Be Acknowledged';
            //o.npsp__Acknowledgment_Date__c = donationDate;
            update o;
            System.debug('Closed Opportunity ' + o.Name);
            status = 'SUCCESS';
        }   
        return status;
    }

    public static String processMonthly(String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode, String paymentDay, String expM, String expY) {
        Id opportunityId = null;
        String status = 'ERROR';
        npe03__Recurring_Donation__c ro;
        List<npe03__Recurring_Donation__c> oRGResult = [SELECT Id, Name, RG_Id__c FROM npe03__Recurring_Donation__c WHERE RG_Id__c = :paymentId and (npsp__Status__c = 'Cancelled' or npsp__Status__c = 'Held' )];
        if ( null != oRGResult ) {
            for (npe03__Recurring_Donation__c oRGFound : oRGResult) {
                // Get the Opportunity Payment Number for return.
                ro = oRGFound;                                  
                break;
            }  
        }
        if ( null == ro ) {
            System.debug('Recurring Not Found ' + paymentId);
            status = 'ERROR';
        }
        else {
            ro.npsp__Status__c = 'Active';
            ro.npsp__PaymentMethod__c = paymentMethod;
            ro.npsp__InstallmentFrequency__c = 1;
            ro.npe03__Installment_Period__c = 'Monthly';
            ro.npsp__Day_of_Month__c = paymentDay;
            if ( 'Credit Card' == paymentMethod ) {
                ro.Card_Type__c = cardType;
                ro.Card_Number_Masked__c = truncatedCard;
                ro.Card_Token__c = reference;
                ro.npsp__CardExpirationMonth__c = expM;
                ro.npsp__CardExpirationYear__c = expY;
            }
            else {
                ro.Account_Number__c = truncatedCard;
                ro.Account_BSB__c = expM;
                ro.Financial_Institution__c = cardType;
                ro.Payee_Name__c = expY;
            }
            update ro;
            System.debug('Recurring Closed ' + ro.RG_Id__c);
            status = 'SUCCESS';
        }
        return status;    
    }

    /*
    public static String processMonthlyOrg(Id accountId, String paymentId, String sessionId, Decimal amount, String paymentMethod, String reference, String truncatedCard, String cardType, String donorEmail, String paymentMode, String paymentDay, String expM, String expY) {
        Id opportunityId = null;
        String status = 'ERROR';
        npe03__Recurring_Donation__c ro;
        List<npe03__Recurring_Donation__c> oRGResult = [SELECT Id, Name, RG_Id__c FROM npe03__Recurring_Donation__c WHERE RG_Id__c = :paymentId and (npsp__Status__c = 'Cancelled' or npsp__Status__c = 'Held' )];
        if ( null != oRGResult ) {
            for (npe03__Recurring_Donation__c oRGFound : oRGResult) {
                // Get the Opportunity Payment Number for return.
                ro = oRGFound;                                  
                break;
            }  
        }
        if ( null == ro ) {
            System.debug('Recurring Not Found ' + paymentId);
            status = 'ERROR';
        }
        else {
            Account roAccount;
            List<Account> aResult = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone FROM Account WHERE Id = :accountId];
            for (Account aFound : aResult) {     
                System.debug('Account Found ' + aFound.Id);
                roAccount = aFound;
            }
            ro.npsp__Status__c = 'Active';
            ro.npsp__PaymentMethod__c = paymentMethod;
            ro.npsp__InstallmentFrequency__c = 1;
            ro.npe03__Installment_Period__c = 'Monthly';
            ro.npsp__Day_of_Month__c = paymentDay;
            ro.npe03__Organization__r = roAccount;
            if ( 'Credit Card' == paymentMethod ) {
                ro.Card_Type__c = cardType;
                ro.Card_Number_Masked__c = truncatedCard;
                ro.Card_Token__c = reference;
                ro.npsp__CardExpirationMonth__c = expM;
                ro.npsp__CardExpirationYear__c = expY;
            }
            else {
                ro.Account_Number__c = truncatedCard;
                ro.Account_BSB__c = expM;
                ro.Financial_Institution__c = cardType;
                ro.Payee_Name__c = expY;
            }
            update ro;
            System.debug('Recurring Closed ' + ro.RG_Id__c);
            status = 'SUCCESS';
        }
        return status;    
    }
    */
}