public class NBOpportunityHelper {

    public static Id getCampaignId(String campaign) {
        Id campaignId;
        List<Campaign> caResult = [SELECT Id, ParentId, Name FROM Campaign WHERE Campaign_Code__c = :campaign];
        if ( null != caResult ) {
            for (Campaign caFound : caResult) {     
                System.debug('NBOpportunity Campaign Found ' + caFound.ParentId + ' ' + caFound.Id);
                campaignId = caFound.Id;
            }
        }
        return campaignId;
    }
    
    public static String processOneTime(String contact, Decimal amount, String session, String campaign, 
        String paymentMethod, String paymentMode, String formURL, String emailAddress, String firstName, 
		String lastName, String utmSource, String utmCampaign, String utmMedium, Id campaignId) {
            String processedDateHolder = '';
            String serviceFeeHolder = '';
			return processOneTime(contact, amount, session, campaign, paymentMethod, paymentMode, formURL, emailAddress, firstName, 
        	lastName, utmSource, utmCampaign, utmMedium, campaignId, processedDateHolder, serviceFeeHolder); 
	}

    public static String processOneTime(String contact, Decimal amount, String session, String campaign, 
        String paymentMethod, String paymentMode, String formURL, String emailAddress, String firstName, 
        String lastName, String utmSource, String utmCampaign, String utmMedium, Id campaignId, String processedDate, String serviceFee) 
    {
        System.debug('Opportunity Requested Contact:' + contact + ' Session:' + session + ' Campaign:' + campaign);

        // See if this is a duplicate call by session Id in pledged state (legacy code)
        List<Opportunity> oResult = [SELECT Id, AccountId, Name, Amount FROM Opportunity WHERE Name = :session and StageName = 'Pledged'];
        Id accountId;
        Opportunity resultOpportunity;
        String resultPaymentName;

        Boolean foundOpp = false;
        if ( null != oResult ) {
            for (Opportunity oFound : oResult) {     
                System.debug('Opportunity Found ' + oFound.AccountId + ' ' + session);
                foundOpp = true;
                resultOpportunity = oFound;
                if ( oFound.Amount != amount ) {
                    oFound.Amount = amount;
                    update oFound;
                }
                List<npe01__OppPayment__c> pResult = [select Id, Name from npe01__OppPayment__c where npe01__Opportunity__c = :oFound.Id];            
                if ( null != pResult ) {
                    for (npe01__OppPayment__c pFound : pResult) {     
                        System.debug('Payment Found ' + pFound.Name);
                        resultPaymentName = pFound.Name;                            
                        break;
                    }
                }           
                break;
            }
        }
        if ( false == foundOpp ) {
            System.debug('Checking session ID in Online_Platform_Id__c ' + session);
            // See if this already exists by session ID field.
            List<Opportunity> oResult2 = [SELECT Id, AccountId, Name, Amount, StageName FROM Opportunity WHERE Online_Platform_Id__c = :session];
            if ( null != oResult2 ) {
                for (Opportunity oFound : oResult2) {     
                    System.debug('Opportunity Found by Session ID ' + oFound.StageName + ' ' + session);
                    resultOpportunity = oFound;
                    List<npe01__OppPayment__c> pResult = [select Id, Name from npe01__OppPayment__c where npe01__Opportunity__c = :oFound.Id];            
                    if ( null != pResult ) {
                        for (npe01__OppPayment__c pFound : pResult) {     
                            System.debug('Payment Found ' + pFound.Name);
                            resultPaymentName = pFound.Name;                            
                            break;
                        }
                    }   

                    if ( resultOpportunity.StageName == 'Pledged') {
                        if ( oFound.Amount != amount ) {
                            oFound.Amount = amount;
                            update oFound;
                        }
                        break;
                    }
                    else {
                        // Donation is already processed.
                        return resultPaymentName;
                    }
                }
            }
        }
        
        List<Contact> cResult = [SELECT Id, AccountId, Name FROM Contact WHERE Id = :contact];
        if ( null != cResult ) {
            for (Contact cFound : cResult) {     
                System.debug('Contact Found ' + cFound.AccountId + ' ' + contact);
                accountId = cFound.AccountId;
            }
        }
        
        if ( null == accountId ) {
            List<Account> aResult = [SELECT Id, Name FROM Account WHERE Id = :contact];
            for (Account aFound : aResult) {     
                System.debug('Account Found ' + aFound.Id);
                accountId = aFound.Id;
                contact = null;
                // See if we can find the contact making the donation
                List<Contact> caResult2 = [SELECT Id, AccountId, Name FROM Contact WHERE Email = :emailAddress];
                if ( null != caResult2 ) {
                    for (Contact caFound : caResult2) {     
                        System.debug('Contact Found ' + caFound.AccountId + ' ' + caFound.Id);
                        contact = caFound.Id;
                        break;
                    }
                }
            }
        }
        
        if ( null == resultPaymentName ) {                        
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
            Decimal transactionCost = 0;
            if ( '' != serviceFee ) {
                try {
                    transactionCost = Decimal.valueOf(!String.isEmpty(serviceFee) ? serviceFee : '0');
					transactionCost = transactionCost.setScale(8, RoundingMode.HALF_EVEN);
                }
                catch (Exception exsf) {
                    System.debug('Service Fee Parse Error: ' + serviceFee);
                }
            }
            // Get the record type for donations
            Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
            System.debug('Creating new Opportunity ' + session + ' ' + amount + ' ' + campaignId + ' Record Type: ' + donationRecordTypeId );
            Opportunity o = new Opportunity();
            o.RecordTypeId = donationRecordTypeId;
            o.Online_Platform_Id__c = session;
            o.Name = session;
            o.Amount = amount;
            o.StageName = 'Pledged';
            o.CloseDate = processedDateOnlyValue;
            o.CampaignId = campaignId;
            o.AccountId = accountId;
            o.Donation_URL__c = formURL;                
            o.Donation_Source__c = 'Web';
            o.Online_Platform_Id__c = session;
            o.Covered_transaction_costs__c = transactionCost;
            o.Type = 'One-Off Gift';
            if ( null != contact ) {
                o.ContactId = contact;   
            }                
            
            insert o;
            System.debug('Opportunity Posted ' + o.Id + ' ' + o.Name);
            resultOpportunity = o;
            
            // Safe to try and update the UTM codes
            if ( null != utmSource && '' != utmSource ) {
                o.Digital_Channel__c = utmSource;
            }
            if ( null != utmMedium && '' != utmMedium ) {
                o.Ad_Group__c = utmMedium;
            }
            if ( null != utmCampaign && '' != utmCampaign ) {
                o.Ad_Id__c = utmCampaign;
            }
            System.debug('Saving UTM: ' + utmCampaign + ' ' + utmSource + ' ' + utmMedium);
            try {
                update o;
            }
            catch( Exception e) {
                System.debug('Error in UTM codes: ' + e.getMessage());
            }
            
            Id opportunityId = o.Id;
            
            // Get the Opportunity Payment Number for return.
            List<npe01__OppPayment__c> pResult = [select Id, Name from npe01__OppPayment__c where npe01__Opportunity__c = :opportunityId];            
            if ( null != pResult ) {
                for (npe01__OppPayment__c pFound : pResult) {     
                    System.debug('Payment Found ' + pFound.Name);
                    resultPaymentName = pFound.Name;
                }
            }  
        }
        return resultPaymentName; 
    }

    public static String processMonthly(String contact, Decimal amount, String session, String campaign, 
        String paymentMethod, String paymentMode, String formURL, String emailAddress, String firstName, 
        String lastName, String utmSource, String utmCampaign, String utmMedium, Id campaignId) 
    {
        System.debug('Processing Monthly');
        Id accountId;
        Boolean orgDonation = false;
        String resultPaymentName;
        
        try {
            // See if we can find one first by session
            List<npe03__Recurring_Donation__c> oRGResult = [SELECT Id, Name, RG_Id__c FROM npe03__Recurring_Donation__c WHERE Name = :session];
            if ( null != oRGResult ) {
                for (npe03__Recurring_Donation__c oRGFound : oRGResult) {
                    // Get the Opportunity Payment Number for return.
                    resultPaymentName = oRGFound.RG_Id__c;                                  
                    break;
                }  
            }
        }
        catch( Exception eg ) {
            System.debug('Monthly ERROR ' + eg.getMessage());
        }
        
        List<Contact> cResult = [SELECT Id, AccountId, Name FROM Contact WHERE Id = :contact];
        if ( null != cResult ) {
            for (Contact cFound : cResult) {     
                System.debug('Contact Found ' + cFound.AccountId + ' ' + contact);
                accountId = cFound.AccountId;
            }
        }
        
        Account account;
        if ( null == accountId ) {
            List<Account> aResult = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone FROM Account WHERE Id = :contact];
            for (Account aFound : aResult) {     
                System.debug('Account Found ' + aFound.Id);
                orgDonation = true;
                accountId = aFound.Id;
                account = aFound;
                contact = null;
                // See if we can find the contact making the donation
                List<Contact> caResult2 = [SELECT Id, AccountId, Name FROM Contact WHERE Email = :emailAddress];
                if ( null != caResult2 ) {
                    for (Contact caFound : caResult2) {     
                        System.debug('Contact Found ' + caFound.AccountId + ' ' + caFound.Id);
                        contact = caFound.Id;
                        break;
                    }
                }
                if ( null == contact ) {
                    if ( null != account ) {                            
                        Contact newContact = new Contact();                            
                        newContact.AccountId = account.Id;
                        newContact.Email = emailAddress;
                        newContact.FirstName = firstName;
                        newContact.LastName  = lastName; 
                        newContact.MailingStreet = account.BillingStreet;
                        newContact.MailingCity = account.BillingCity;
                        newContact.MailingState = account.BillingState;
                        newContact.MailingPostalCode = account.BillingPostalCode;
                        newContact.MailingCountry = account.BillingCountry;
                        newContact.HomePhone = account.Phone;
                        System.debug('Inserting new Contact ' + emailAddress);
                        insert newContact;
                        contact = newContact.Id;
                    }
                }
                break;
            }
        }            
        
        if ( null == resultPaymentName ) {
            npe03__Recurring_Donation__c rgo = new npe03__Recurring_Donation__c();
            rgo.Name = session;
            rgo.npe03__Amount__c = amount;
            rgo.npsp__PaymentMethod__c = paymentMethod;
            rgo.npsp__Status__c = 'Held';
            rgo.npe03__Recurring_Donation_Campaign__c = campaignId;      
            rgo.Online_Platform_Id__c = session;        
            rgo.Payee_Name__c = firstName + ' ' + lastName;  
            System.debug('Contact: ' + contact + ' Account: ' + account);
            System.debug('Organization Mode: ' + orgDonation);
            if ( null != contact && orgDonation == false ) {
                rgo.npe03__Contact__c = contact;   
            } 
            else if ( null != account && orgDonation ) {
                rgo.npe03__Contact__c = contact;
                rgo.npe03__Organization__r = account;
            }                
            
            insert rgo;
            System.debug('Insert npe03__Recurring_Donation__c Id:' + rgo.Id);
            // Get the RG_Id__c
            Id oid = rgo.Id;
            npe03__Recurring_Donation__c rg = [ SELECT RG_Id__c from npe03__Recurring_Donation__c where Id = :oid ];
            resultPaymentName = rg.RG_Id__c;
        }
        return resultPaymentName;
    }

    public static String processMonthlyOrg(String accountIdstr, Decimal amount, String session, String campaign, 
        String paymentMethod, String paymentMode, String formURL, String emailAddress, String firstName, 
        String lastName, String utmSource, String utmCampaign, String utmMedium, Id campaignId,
        String reference, String truncatedCard, String cardType, String donorEmail,
        String paymentDay, String expM, String expY) 
    {
        System.debug('Processing Monthly');
        String resultPaymentName;

        // See if we can find one first by session
        Boolean foundDonaton = false;
        List<npe03__Recurring_Donation__c> oRGResult = [SELECT Id, Name, RG_Id__c FROM npe03__Recurring_Donation__c WHERE Name = :session];
        if ( null != oRGResult ) {
            for (npe03__Recurring_Donation__c oRGFound : oRGResult) {
                // Get the Opportunity Payment Number for return.
                resultPaymentName = oRGFound.RG_Id__c;    
                foundDonaton = true;                              
                break;
            }  
        }

        if ( ! foundDonaton ) {
            List<npe03__Recurring_Donation__c> oRGResultP = [SELECT Id, Name, RG_Id__c FROM npe03__Recurring_Donation__c WHERE Online_Platform_Id__c = :session];
            if ( null != oRGResultP ) {
                for (npe03__Recurring_Donation__c oRGFoundP : oRGResultP) {
                    // Get the Opportunity Payment Number for return.
                    resultPaymentName = oRGFoundP.RG_Id__c;    
                    break;
                }  
            }
        }

        if ( null == resultPaymentName ) {
            npe03__Recurring_Donation__c rgo = new npe03__Recurring_Donation__c();
            rgo.Name = session;
            rgo.npe03__Amount__c = amount;
            rgo.npsp__PaymentMethod__c = paymentMethod;
            rgo.npe03__Installment_Period__c = 'Monthly';
            rgo.npsp__Day_of_Month__c = paymentDay;
            rgo.npsp__Status__c = 'Active';
            rgo.npe03__Recurring_Donation_Campaign__c = campaignId;  
            rgo.Online_Platform_Id__c = session;
            rgo.Payee_Name__c = firstName + ' ' + lastName;
            if ( 'Credit Card' == paymentMethod ) {
                rgo.Card_Type__c = cardType;
                rgo.Card_Number_Masked__c = truncatedCard;
                rgo.Card_Token__c = reference;
                rgo.npsp__CardExpirationMonth__c = expM;
                rgo.npsp__CardExpirationYear__c = expY;
            }
            else {
                rgo.Account_Number__c = truncatedCard;
                rgo.Account_BSB__c = expM;
                rgo.Financial_Institution__c = cardType;
                rgo.Payee_Name__c = expY;
            }

            rgo.npe03__Organization__c = accountIdstr;
            
            insert rgo;
            System.debug('Inserted npe03__Recurring_Donation__c Id:' + rgo.Id + ' Org ID: ' + account.Id );
            Id oid = rgo.Id;
            npe03__Recurring_Donation__c rg = [ SELECT RG_Id__c, npe03__Organization__c, npe03__Contact__c from npe03__Recurring_Donation__c where Id = :oid ];
            resultPaymentName = rg.RG_Id__c;
        }
        return resultPaymentName;
    }
}