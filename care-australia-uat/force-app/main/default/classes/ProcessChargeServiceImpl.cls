public class ProcessChargeServiceImpl implements IProcessChargeService {
    public void createOpportunityAndUpdatePaymentFromCharge(Map<String, Charge__c> chargeMap, Set<String> customerIds, Map<String, String> declineCodeMap) {
        try {
            Map<String, Contact> contactMap = this.getContactCustomerIdMap(customerIds);
            
            if (contactMap.size() > 0) {
                Map<String, Opportunity> chargeOppMap = new Map<String, Opportunity>();
                for (Charge__c charge : chargeMap.values()) {
                    Opportunity opp = this.getOpportunityFromCharge(charge, contactMap.get(charge.Stripe_Customer_Id__c));
                    chargeOppMap.put(charge.Stripe_Charge_Id__c, opp);
                }
                if (chargeOppMap.size() > 0) {
                    upsert chargeOppMap.values();
                    
                    Map<Id, String> opportunitiesIdStatusMap = new Map<Id, String>();
					Map<Id, Charge__c> opportunityIdChargeMap = new Map<Id, Charge__c>();
                    for(String chargeId: chargeOppMap.keySet()) {
                        Opportunity opp = chargeOppMap.get(chargeId);
                        Charge__c charge = chargeMap.get(chargeId);
                        opportunitiesIdStatusMap.put(opp.Id, this.getStatusForCharge(charge, declineCodeMap));
                        opportunityIdChargeMap.put(opp.Id, charge);
                    }
                    this.updatePaymentsForOpportunities(opportunitiesIdStatusMap, opportunityIdChargeMap, declineCodeMap);
                }   
            }
        } catch (Exception ex) {
            System.debug('Issue in ProcessChargeService.createOpportunityAndUpdatePaymentFromCharge');
            System.debug(ex);
        }
    }
    
    public void updateOpportunityAndPaymentFromCharge(Map<String, Charge__c> invoiceChargeMap, Map<String, String> declineCodeMap) {
        try {
            Map<String, String> subscriptionInvoiceIdMap = new Map<String, String>();
            for (Invoice__c invoice : [SELECT Stripe_Invoice_Id__c, Stripe_Subscription_Id__c FROM Invoice__c WHERE Stripe_Invoice_Id__c IN :invoiceChargeMap.keySet()]) {
                subscriptionInvoiceIdMap.put(invoice.Stripe_Subscription_Id__c, invoice.Stripe_Invoice_Id__c);
            } 
            
            Map<Id, Charge__c> opportunitiesChargeStatusMap = new Map<Id, Charge__c>();
            for (npe03__Recurring_Donation__c rd: [SELECT Id, Stripe_Subscription_Id__c, (SELECT Id, Name, StageName FROM npe03__Donations__r WHERE StageName = 'Pledged') FROM npe03__Recurring_Donation__c WHERE Stripe_Subscription_Id__c IN :subscriptionInvoiceIdMap.keySet()]) {
                Opportunity opp = rd.npe03__Donations__r[0];
                String invoiceId = subscriptionInvoiceIdMap.get(rd.Stripe_Subscription_Id__c);
                Charge__c charge = invoiceChargeMap.get(invoiceId);
                opportunitiesChargeStatusMap.put(opp.Id, charge);
            }
            
            if (opportunitiesChargeStatusMap.size() > 0) {
                this.updatePaymentsAndOpportunityForCharge(opportunitiesChargeStatusMap, declineCodeMap);
            }
        } catch(Exception ex) {
            System.debug('Issue in ProcessChargeService.updateOpportunityAndPaymentFromCharge');
            System.debug(ex);
        }
    }
    
    public void updateProcessedCharges(List<Charge__c> processedCharges) {
        List<Charge__c> updateCharges = new List<Charge__c>();
        for(Charge__c charge: processedCharges) {
            charge.Is_Processed__c = true;
            updateCharges.add(charge);
        }
        update updateCharges;
    }
    
    private Map<String, Contact> getContactCustomerIdMap(Set<String> customerIds) {
        String searchTerm = String.join(new List<String>(customerIds), ' OR ');
        List<List<SObject>> listOfResults = [FIND :searchTerm IN ALL FIELDS RETURNING Contact(Id, Name, AccountId, Stripe_Customer_Id__c, Stripe_Customer_Ids__c)];
        Map<String, Contact> contactMap = new Map<String, Contact>();
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
    
    private Opportunity getOpportunityFromCharge(Charge__c charge, Contact contact) {
        //The method can be optimize to bulkify the process to update existing opportunity.
        //Or if we don't insert opportunity from gift entry.
        //Because charge can create an opportunity by itself and also attach payment
        
        Opportunity opp = new Opportunity();
        List<Opportunity> existingOpportunityList;
        if(String.isNotEmpty(charge.Opportunity_Id__c)) {
            existingOpportunityList = [SELECT Id, ContactId, AccountId, Name, CampaignId FROM Opportunity WHERE Id =: charge.Opportunity_Id__c];
        } else {
            existingOpportunityList = [SELECT Id, ContactId, AccountId, Name, CampaignId FROM Opportunity WHERE ContactId =:contact.Id AND Type = 'One-Off Gift' AND StageName = 'Pledged' AND Amount = :charge.Stripe_Charge_Amount__c];  
        }
        
        if (existingOpportunityList.size() > 0) {
            //There should be and must be only one opportunity on the contact with above condition
            opp = existingOpportunityList[0];
        } 
        
        System.debug(contact.Name);
        if(String.isEmpty(opp.Name)) {
            opp.Name = contact.Name + ' ' + String.valueOf(date.today());
        }
        
        if(String.isEmpty(opp.CampaignId)) {
            opp.CampaignId = charge.Campaign_Id__c == null ? Stripe_Setting__c.getValues('Default').Default_Campaign__c : charge.Campaign_Id__c;
        }
        
        if(opp.ContactId == null) {
            opp.ContactId = contact.Id;
        }
        if(opp.AccountId == null) {
         	opp.AccountId = contact.AccountId;   
        }
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        opp.Type = 'One-Off Gift';
        opp.Amount = charge.Stripe_Charge_Amount__c;
        if (charge.Failure_Code__c == null) {
         	opp.StageName = 'Closed Won';   
        } else {
            opp.StageName = 'Closed Lost';
        }
        opp.CloseDate = charge.Payment_Created_Date__c;
        opp.stripe_pi_id__c = charge.Stripe_Payment_Intent_Id__c;
        if (charge.Donation_Source__c != null) {
            opp.Donation_Source__c = charge.Donation_Source__c;
        } else {
            opp.Donation_Source__c = 'Phone';
        }
        if (charge.Method_Type__c == 'card') {
            opp.Card_Number_Masked__c = ('************' + charge.Card_Last_Digits__c);
            opp.Payment_Method__c = 'Credit Card';
            opp.Card_Type__c = charge.Card_Type__c;
            opp.Card_Token__c = charge.Card_Token__c;
            opp.Card_Expiration_Month__c = charge.Card_Expiration_Month__c;
            opp.Card_Expiration_Year__c = charge.Card_Expiration_Year__c;
        } else if (charge.Method_Type__c == 'au_becs_debit') {
            opp.Payment_Method__c = 'Direct Debit';
            opp.Account_Number__c = ('************' + charge.Account_Last_Digits__c);
            opp.Card_Token__c = charge.Account_Token__c;
            opp.Account_BSB__c = charge.Account_BSB__c;
        }
        opp.Stripe_Payment_Method_Id__c = charge.Stripe_Payment_Method_Id__c;
        opp.Payee_Name__c = contact.Name;
        return opp;
    }
    
    private void updatePaymentsForOpportunities(Map<Id, String> opportunitiesIdStatusMap, Map<Id, Charge__c> opportunityIdChargeMap, Map<String, String> declineCodeMap) {
        List<npe01__OppPayment__c> payments = new List<npe01__OppPayment__c>();
        for (Opportunity opp: [SELECT Id, PrimaryContactName__c, (SELECT Id FROM npe01__OppPayment__r) FROM Opportunity WHERE Id IN :opportunitiesIdStatusMap.keySet()]) {
            npe01__OppPayment__c payment = opp.npe01__OppPayment__r[0];
            Charge__c charge = opportunityIdChargeMap.get(opp.Id);
            if (opportunitiesIdStatusMap.get(opp.Id) == 'Success') {
                payment.Payment_Result__c = 'Success';
                payment.npe01__Paid__c = true;
            } else {
                payment.Response_Code__c = opportunitiesIdStatusMap.get(opp.Id);
                payment.Payment_Result__c = declineCodeMap.get(payment.Response_Code__c);
            }
            
            if (charge.Method_Type__c == 'card') {
                payment.Card_Number_Masked__c = ('************' + charge.Card_Last_Digits__c);
                payment.npe01__Payment_Method__c = 'Credit Card';
                payment.Card_Type__c = charge.Card_Type__c;
                payment.Card_Token__c = charge.Card_Token__c;
                payment.npsp__Card_Expiration_Month__c = charge.Card_Expiration_Month__c;
                payment.npsp__Card_Expiration_Year__c = charge.Card_Expiration_Year__c;
            } else if (charge.Method_Type__c == 'au_becs_debit') {
                payment.npe01__Payment_Method__c = 'Direct Debit';
                payment.Account_Number__c = ('************' + charge.Account_Last_Digits__c);
                payment.Card_Token__c = charge.Account_Token__c;
                payment.Account_BSB__c = charge.Account_BSB__c;
            }
            payment.Payee_Name__c = opp.PrimaryContactName__c;
            payment.Merchant_Category__c = 'Stripe';
            payment.npe01__Check_Reference_Number__c = charge.Stripe_Charge_Id__c;
            payment.Stripe_Payment_Method_Id__c = charge.Stripe_Payment_Method_Id__c;
            payments.add(payment);
        }
        update payments;
    }
    
    private void updatePaymentsAndOpportunityForCharge(Map<Id, Charge__c> opportunitiesChargeStatusMap, Map<String, String> declineCodeMap) {
        Set<Id> rdIdListToCancel = new Set<Id>();
        Set<Id> rdIdListToUpdateConsecutiveOpp = new Set<Id>();
        Map<Id, Charge__c> rdMapToUpdatePaymentFromCharge = new Map<Id, Charge__c>();
        List<npe01__OppPayment__c> payments = new List<npe01__OppPayment__c>();
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Opportunity opp: [SELECT Id, npe03__Recurring_Donation__c, PrimaryContactName__c, (SELECT Id FROM npe01__OppPayment__r), CreatedDate FROM Opportunity WHERE Id IN :opportunitiesChargeStatusMap.keySet() ORDER BY CreatedDate desc]) {
            npe01__OppPayment__c payment = new npe01__OppPayment__c();
            if (opp.npe01__OppPayment__r.size() > 0) {
                payment = opp.npe01__OppPayment__r[0];   
            } else {
                payment.npe01__Opportunity__c = opp.Id;
            }
            
            Charge__c charge = opportunitiesChargeStatusMap.get(opp.Id);
            
            String status = this.getStatusForCharge(charge, declineCodeMap);
            if (status == 'Success') {
                payment.Payment_Result__c = 'Success';
                payment.npe01__Paid__c = true;
            } else {
                payment.Response_Code__c = status;
                payment.Payment_Result__c = declineCodeMap.get(payment.Response_Code__c);
                if (payment.Payment_Result__c == 'Fail Hard') {
                 	rdIdListToCancel.add(opp.npe03__Recurring_Donation__c);   
                } else {
                    rdIdListToUpdateConsecutiveOpp.add(opp.npe03__Recurring_Donation__c);
                }
            }
            payment.npe01__Payment_Date__c = charge.Payment_Created_Date__c;
            if (charge.Method_Type__c == 'card') {
                payment.Card_Number_Masked__c = ('************' + charge.Card_Last_Digits__c);
                payment.npe01__Payment_Method__c = 'Credit Card';
                payment.Card_Type__c = charge.Card_Type__c;
                payment.Card_Token__c = charge.Card_Token__c;
                payment.npsp__Card_Expiration_Month__c = charge.Card_Expiration_Month__c;
                payment.npsp__Card_Expiration_Year__c = charge.Card_Expiration_Year__c;
            } else if (charge.Method_Type__c == 'au_becs_debit') {
                payment.npe01__Payment_Method__c = 'Direct Debit';
                payment.Account_Number__c = ('************' + charge.Account_Last_Digits__c);
                payment.Card_Token__c = charge.Account_Token__c;
                payment.Account_BSB__c = charge.Account_BSB__c;
            }
            payment.Stripe_Payment_Method_Id__c = charge.Stripe_Payment_Method_Id__c;
            payment.Merchant_Category__c = 'Stripe';
            payment.npe01__Check_Reference_Number__c = charge.Stripe_Charge_Id__c;
            payment.Payee_Name__c = opp.PrimaryContactName__c;
            
            opp.CloseDate = charge.Payment_Created_Date__c;
            if (status == 'Success') {
                opp.StageName = 'Closed Won';
            } else {
                opp.StageName = 'Closed Lost';
            }
            if (charge.Donation_Source__c != null) {
                opp.Donation_Source__c = charge.Donation_Source__c;
            } else {
                opp.Donation_Source__c = 'Phone';
            }
            if (charge.Method_Type__c == 'card') {
                opp.Card_Number_Masked__c = ('************' + charge.Card_Last_Digits__c);
                opp.Payment_Method__c = 'Credit Card';
                opp.Card_Type__c = charge.Card_Type__c;
                opp.Card_Token__c = charge.Card_Token__c;
                opp.Card_Expiration_Month__c = charge.Card_Expiration_Month__c;
                opp.Card_Expiration_Year__c = charge.Card_Expiration_Year__c;
            } else if (charge.Method_Type__c == 'au_becs_debit') {
                opp.Payment_Method__c = 'Direct Debit';
                opp.Account_Number__c = ('************' + charge.Account_Last_Digits__c);
                opp.Card_Token__c = charge.Account_Token__c;
                opp.Account_BSB__c = charge.Account_BSB__c;
            }
            opp.Stripe_Payment_Method_Id__c = charge.Stripe_Payment_Method_Id__c; 
            opp.Payee_Name__c = opp.PrimaryContactName__c;
            rdMapToUpdatePaymentFromCharge.put(opp.npe03__Recurring_Donation__c, charge);
            opportunities.add(opp);
            payments.add(payment);
        }
        upsert payments;
        update opportunities;
        
        if (rdMapToUpdatePaymentFromCharge.size() > 0) {
            this.updateRDpaymentDetails(rdMapToUpdatePaymentFromCharge, rdIdListToUpdateConsecutiveOpp);
        }
        
        if (rdIdListToCancel.size() > 0 ) {
            this.updateRDStatusToCancel(rdIdListToCancel);
        }
    }
    
    private void updateRDpaymentDetails(Map<Id, Charge__c> rdMapToUpdatePaymentFromCharge, Set<Id> rdIdListToUpdateConsecutiveOpp) {
        List<npe03__Recurring_Donation__c> updateRdPaymentList = new List<npe03__Recurring_Donation__c>();
        for(npe03__Recurring_Donation__c rd: [SELECT Id, npe03__Contact__r.Name, Failed_Consecutive_Opportunities__c FROM npe03__Recurring_Donation__c WHERE Id IN :rdMapToUpdatePaymentFromCharge.keySet()]) {
            Charge__c charge = rdMapToUpdatePaymentFromCharge.get(rd.Id);
            if (charge.Method_Type__c == 'card') {
                rd.npsp__PaymentMethod__c = 'Credit Card';
                rd.Card_Number_Masked__c = ('************' + charge.Card_Last_Digits__c);
                rd.Card_Token__c = charge.Card_Token__c;
                rd.npsp__CardExpirationMonth__c = charge.Card_Expiration_Month__c;
                rd.npsp__CardExpirationYear__c = charge.Card_Expiration_Year__c;
                rd.Card_Type__c = charge.Card_Type__c;
            } else if (charge.Method_Type__c == 'au_becs_debit') {
                rd.npsp__PaymentMethod__c = 'Direct Debit';
                rd.Account_BSB__c = charge.Account_BSB__c;
                rd.Account_Number__c = ('************' + charge.Account_Last_Digits__c);
                rd.Card_Token__c = charge.Account_Token__c;
            }
            rd.Payment_Gateway__c = 'Stripe';
            rd.Stripe_Payment_Method_Id__c = charge.Stripe_Payment_Method_Id__c;
            rd.Payee_Name__c = rd.npe03__Contact__r.Name;
            if (rdIdListToUpdateConsecutiveOpp.contains(rd.Id)) {
                rd.Failed_Consecutive_Opportunities__c = rd.Failed_Consecutive_Opportunities__c + 1;
            }
            updateRdPaymentList.add(rd);
        }
        update updateRdPaymentList;
    }
    
    private void updateRDStatusToCancel(Set<Id> rdIdList) {
        List<npe03__Recurring_Donation__c> rdList = new List<npe03__Recurring_Donation__c>();
        for(npe03__Recurring_Donation__c rd: [SELECT Id FROM npe03__Recurring_Donation__c WHERE Id IN :rdIdList]) {
            rd.npsp__Status__c = 'Cancelled';
            rdList.add(rd);
        }
        update rdList;
    }
    
    private String getStatusForCharge(Charge__c charge, Map<String, String> declineCodeMap) {
        if (declineCodeMap.containsKey(charge.Outcome_Reason__c)) {
            return charge.Outcome_Reason__c;
        }
        if (declineCodeMap.containsKey(charge.Failure_Code__c)) {
            return charge.Failure_Code__c;
        }
        return 'Success';
    }
}