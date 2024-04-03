/**
* @class             : AccountFutureOperations
* @description       : Future methods for update emails in RD and Payments
* @group             : 
* @created on        : 10-05-2021
**/
global class AccountFutureOperations {
    @future 
    public static void UpdateRDDonorEmail(Set<Id> accIdSet){
        system.debug(':::::::::::::::::AccountFutureOperations.UpdateRDDonorEmail:::::::::::::::::::::');
        list<npe03__Recurring_Donation__c > listRD = [SELECT Id, npsp__ClosedReason__c, npsp__Status__c,npe03__Organization__r.Email__c 
                                                      FROM npe03__Recurring_Donation__c where npsp__Status__c != 'Cancelled' 
                                                      and npe03__Organization__c in :accIdSet and Donor_Type__c = 'Account' ];
        system.debug(':::::::::::::::::listRD:::::::::::::::::::::'+listRD.size());
        if(listRD != null){
            for(npe03__Recurring_Donation__c rd : listRD){
                rd.Donor_Email__c = rd.npe03__Organization__r.Email__c;
            }
            Database.update(listRD,false);
            
        }
    }
    @future 
    public static void UpdatePaymentDonorEmail(Set<Id> accIdSet){
        system.debug(':::::::::::::::::AccountFutureOperations.UpdatePaymentDonorEmail:::::::::::::::::::::');
        list<npe01__OppPayment__c > listPayment = [SELECT Id,Donor_Type__c,npe01__Opportunity__r.Donor_Email__c FROM npe01__OppPayment__c 
                                                           where npe01__Opportunity__r.AccountId in :accIdSet and npe01__Opportunity__r.Donor_Type__c = 'Account' 
                                                   and (Payment_Result__c = 'Not Processed' or Payment_Result__c = 'Processing') and 
                                                   npe01__Opportunity__r.StageName != 'Closed Lost' and npe01__Opportunity__r.StageName != 'Closed Won'];
        system.debug(':::::::::::::::::listPayment:::::::::::::::::::::'+listPayment.size());
        if(listPayment != null){
            for(npe01__OppPayment__c payment : listPayment){
                payment.Donor_Email__c = payment.npe01__Opportunity__r.Donor_Email__c;
            }
            Database.update(listPayment,false);
            
        }
        
    }
}