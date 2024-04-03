/**
* @class             : RD_TriggerHandler_TDTM
* @description       : Activate Held RD when update payment details.
*                      Cancel RD, when Failed Consecutive Opportunities >=3
* @group             : 
* @created on        : 08-25-2021
**/
global class RD_TriggerHandler_TDTM extends npsp.TDTM_Runnable {
    
    // the Trigger Handler’s Run method we must provide
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, 
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction, 
                                                      Schema.DescribeSObjectResult objResult) 
    {
        
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        DateTime dT = System.now();
        Date todaysDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            System.System.debug('*******:::::BeforeUpdate.Size():::::*****'+newlist.size());
            
            RG_Process_Value__mdt rgProcessValue = [Select Failed_Consecutive_Opportunities__c,Retry_Attempt__c From RG_Process_Value__mdt limit 1];
            Map<Id,npe03__Recurring_Donation__c> rdOldMap = new Map<Id,npe03__Recurring_Donation__c>();
            
            //Map<Id,Opportunity> rgOppMap = new Map<Id,Opportunity>();
            Map<Id,Opportunity> oppRgMap = new Map<Id,Opportunity>();
            
            for (Opportunity opp : [SELECT Id,npe03__Recurring_Donation__c FROM Opportunity where npe03__Recurring_Donation__c IN:newlist and StageName ='Processing']) {
                oppRgMap.put(opp.npe03__Recurring_Donation__c,opp);
            }
            
            
            for (npe03__Recurring_Donation__c rdOld : (list<npe03__Recurring_Donation__c>)oldlist) {
                rdOldMap.put(rdOld.Id,rdOld);
            }
            //npe03__Recurring_Donation__c rdOld = new npe03__Recurring_Donation__c();
            for (npe03__Recurring_Donation__c rdNew : (list<npe03__Recurring_Donation__c>)newlist) {
                //rdOld=rdOldMap.get(rdNew.Id)
                
                if(rdNew.npsp__Status__c == 'Held'){
                    
                    if(rdNew.npsp__PaymentMethod__c == 'Credit Card'){
                        if(rdNew.Card_Token__c != rdOldMap.get(rdNew.Id).Card_Token__c || rdNew.Card_Number_Masked__c != rdOldMap.get(rdNew.Id).Card_Number_Masked__c){

                            rdNew.npsp__Status__c = 'Active';
                             rdNew.npsp__ClosedReason__c = '';
                        }
                        
                    }else if(rdNew.npsp__PaymentMethod__c == 'Direct Debit'){
                        if( rdNew.Account_BSB__c != rdOldMap.get(rdNew.Id).Account_BSB__c || rdNew.Account_Number__c != rdOldMap.get(rdNew.Id).Account_Number__c){
                            rdNew.npsp__Status__c = 'Active';
                            rdNew.npsp__ClosedReason__c = '';
                        }
                    }
                    
                    
                }
                if(rdNew.npsp__Status__c != 'Cancelled' && rdNew.Failed_Consecutive_Opportunities__c >= rgProcessValue.Failed_Consecutive_Opportunities__c){
                    rdNew.npsp__Status__c = 'Cancelled';
                    rdNew.npsp__ClosedReason__c = 'Multi Rejections';
                    rdNew.Cancellation_Date__c = todaysDate;
                }
                if(rdNew.npsp__Status__c == 'Cancelled' ){
                    if(oppRgMap.containsKey(rdNew.Id)){
                        rdNew.addError('Do not cancel; payments are being processed');
                        //rdNew.npsp__Status__c.addError('Recurring Donation have processing opportunity');
                    }
                }
                
            }
            //dmlWrapper.objectsToUpdate.addAll((list<SObject>)listRD);
        }
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            System.System.debug('*******:::::AfterInsert.Size():::::*****'+newlist.size());
            Set<Id> donnorAccIds = new Set<Id>();
            Set<Id> donnorConIds = new Set<Id>();
            for (npe03__Recurring_Donation__c rd : (list<npe03__Recurring_Donation__c>)newlist) {
                if(rd.Donor_Type__c == 'Account'){
                    donnorAccIds.add(rd.npe03__Organization__c);
                }else if(rd.Donor_Type__c == 'Contact') {
                    donnorConIds.add(rd.npe03__Contact__c );
                }  
            }
            System.System.debug('Contact ***'+donnorConIds);
            System.System.debug('Account ***'+donnorAccIds);
            
            List<Donor_Constituency__c> dcListToCreate = new List<Donor_Constituency__c>();
            
            if(donnorAccIds!=null && !donnorAccIds.isEmpty()) {
                //Update RD status in Account
                List<Account> donnorAccounts = [Select Recurring_Donor_Status__c From Account Where Id IN: donnorAccIds];
                
                for (Account con : donnorAccounts) {
                    con.Recurring_Donor_Status__c = 'Active';
                }
                dmlWrapper.objectsToUpdate.addAll((list<Account>)donnorAccounts);
                
                //Account Donor Constituency check
                Map<ID, Donor_Constituency__c> accDCMap = new Map<ID, Donor_Constituency__c>();
                
                System.System.debug('accDCs ***'+accDCMap);
                Set<Id> accIdsWithOutDC = new Set<Id>();
                
                for (Donor_Constituency__c dc : [SELECT Id, Name, Account__c, Contact__c, 
                                                 Start_Date__c, End_Date__c FROM Donor_Constituency__c
                                                 Where Constituency_Type__c = 'Regular Giver' and End_Date__c = null and Account__c IN: donnorAccIds]) {
                    accDCMap.put(dc.Account__c, dc);
                }
                for (Id accId : donnorAccIds) {
                    if(!accDCMap.keyset().contains(accId)){
                        accIdsWithOutDC.add(accId);
                    }
                }
                
                if(accIdsWithOutDC!=null && !accIdsWithOutDC.isEmpty()) {
                    
                    List<Account> accToCreateDC = [SELECT Id,Name,npe01__One2OneContact__c FROM Account where Id IN: accIdsWithOutDC];
                    for (Account acc : accToCreateDC) {
                        dcListToCreate.add(new Donor_Constituency__c(
                            Account__c = acc.Id,
                            Contact__c = acc.npe01__One2OneContact__c,
                            Start_Date__c =todaysDate ,
                            Constituency_Type__c = 'Regular Giver'
                        ));
                    }
                }    
            }
            if(donnorConIds!=null && !donnorConIds.isEmpty()) {
                //Update RD status in Contact
                List<Contact> donnorContacts = [Select Recurring_Donor_Status__c From Contact Where Id IN: donnorConIds];
                
                for (Contact con : donnorContacts) {
                    con.Recurring_Donor_Status__c = 'Active';
                }
                dmlWrapper.objectsToUpdate.addAll((list<Contact>)donnorContacts);
                
                //Contact Donor Constituency check
                Map<ID, Donor_Constituency__c> conDCMap = new Map<ID, Donor_Constituency__c>();
                
                Set<Id> conIdsWithOutDC = new Set<Id>();
                
                for (Donor_Constituency__c dc : [SELECT Id, Name, Account__c, Contact__c, Start_Date__c, End_Date__c, 
                                                 Constituency_Type__c FROM Donor_Constituency__c 
                                                 Where Constituency_Type__c = 'Regular Giver' and End_Date__c = null and Contact__c IN: donnorConIds]) {
                    conDCMap.put(dc.Contact__c, dc);
                }
                
                System.System.debug('conDCs ***'+conDCMap);
                
                for (Id conId : donnorConIds) {
                    if(!conDCMap.keyset().contains(conId)){
                        conIdsWithOutDC.add(conId);
                    }
                }
                if(conIdsWithOutDC!=null && !conIdsWithOutDC.isEmpty()) {
                    List<Contact> conToCreateDC = [SELECT Id,Name,AccountId FROM Contact where Id IN: conIdsWithOutDC];
                    
                    for (Contact con : conToCreateDC) {
                        dcListToCreate.add(new Donor_Constituency__c(
                            Account__c = con.AccountId,
                            Contact__c = con.Id,
                            Start_Date__c =todaysDate ,
                            Constituency_Type__c = 'Regular Giver'
                        ));
                    }
                }
                
            }
            
            System.System.debug('Donor Constituency Records ***'+dcListToCreate);
            if(dcListToCreate!=null && !dcListToCreate.isEmpty()) {
                dmlWrapper.objectsToInsert.addAll((list<Donor_Constituency__c>)dcListToCreate);
            }
            
        }
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            System.System.debug('*******:::::AfterUpdate.Size():::::*****'+newlist.size());
            
           /* List<Id> activeAccIds = new List<Id>();
            List<Id> activeConIds = new List<Id>();
            Map<Id,npe03__Recurring_Donation__c> rdOldMap = new Map<Id,npe03__Recurring_Donation__c>();           
            for (npe03__Recurring_Donation__c rdOld : (list<npe03__Recurring_Donation__c>)oldlist) {
                rdOldMap.put(rdOld.Id,rdOld);
            }
            for (npe03__Recurring_Donation__c rdNew : (list<npe03__Recurring_Donation__c>)newlist) {
                if(rdNew.npsp__Status__c == 'Active' && rdNew.npsp__Status__c != rdOldMap.get(rdNew.Id).npsp__Status__c){
                    if(rd.Donor_Type__c == 'Account'){
                        activeAccIds.add(rd.npe03__Organization__c);
                    }else if(rd.Donor_Type__c == 'Contact') {
                        activeConIds.add(rd.npe03__Contact__c );
                    } 
                }
            }*/
            
            Set<Id> closedDCAccIds = new Set<Id>();
            Set<Id> closedDCConIds = new Set<Id>();
            for (npe03__Recurring_Donation__c rd : (list<npe03__Recurring_Donation__c>)newlist) {
                if(rd.npsp__Status__c == 'Cancelled'){
                    if(rd.Donor_Type__c == 'Account'){
                        closedDCAccIds.add(rd.npe03__Organization__c);
                    }else if(rd.Donor_Type__c == 'Contact') {
                        closedDCConIds.add(rd.npe03__Contact__c );
                    } 
                }
            }
            
            System.System.debug('Cancelled Account ***'+closedDCAccIds);
            System.System.debug('Cancelled Contact ***'+closedDCConIds);
            Set<Id> accWithNoActiveRD = new Set<Id>();
            //Cancelled RD - Account related operations
            if(closedDCAccIds!=null && !closedDCAccIds.isEmpty()) {
                Map<ID, npe03__Recurring_Donation__c> accDCMap = new Map<ID, npe03__Recurring_Donation__c>();
                
                for (npe03__Recurring_Donation__c rd : [SELECT Id, npe03__Organization__c, npe03__Contact__c, Name, npsp__Status__c 
                     FROM npe03__Recurring_Donation__c Where npsp__Status__c != 'Cancelled' and npe03__Organization__c IN: closedDCAccIds]) {
                    accDCMap.put(rd.npe03__Organization__c, rd);
                }
                
                
                for (Id accId : closedDCAccIds) {
                    if (accDCMap!=null && !accDCMap.isEmpty()) {
                        if(!accDCMap.keyset().contains(accId)){
                            accWithNoActiveRD.add(accId);
                        }
                    }else{
                        accWithNoActiveRD.add(accId);
                    }
                }
                System.System.debug('accWithNoActiveRD ***'+accWithNoActiveRD);
            }
            
            Set<Id> conWithNoActiveRD = new Set<Id>();
            //Cancelled RD - Contact related Operations
            if(closedDCConIds!=null && !closedDCConIds.isEmpty()) {
                Map<ID, npe03__Recurring_Donation__c> conDCMap = new Map<ID, npe03__Recurring_Donation__c>();
                System.System.debug('conDCMap ***'+conDCMap);
                
                for (npe03__Recurring_Donation__c rd : [SELECT Id, npe03__Organization__c, npe03__Contact__c, Name, npsp__Status__c 
                     FROM npe03__Recurring_Donation__c Where npsp__Status__c != 'Cancelled' and npe03__Contact__c IN: closedDCConIds]) {
                    conDCMap.put(rd.npe03__Contact__c, rd);
                }
                
                
                for (Id conId : closedDCConIds) {
                    if (conDCMap!=null && !conDCMap.isEmpty()) {
                        if(!conDCMap.keyset().contains(conId)){
                            conWithNoActiveRD.add(conId);
                        }
                    }else{
                        conWithNoActiveRD.add(conId);
                    }
                } 
                System.System.debug('conWithNoActiveRD ***'+conWithNoActiveRD);
            }
            List<Donor_Constituency__c> dcListToUpdate = new List<Donor_Constituency__c>();
            if(accWithNoActiveRD!=null && !accWithNoActiveRD.isEmpty()) {
                //Update RD status in Account to Inactive
                List<Account> accWithNoActiveRDList = [Select Recurring_Donor_Status__c From Account Where Id IN: accWithNoActiveRD];
                
                for (Account acc : accWithNoActiveRDList) {
                    acc.Recurring_Donor_Status__c = 'Inactive';
                }
                dmlWrapper.objectsToUpdate.addAll((list<Account>)accWithNoActiveRDList);
                
                //End Date added to Donor Constituency
                for (Donor_Constituency__c dc : [SELECT Id, End_Date__c, Contact__c, Account__c 
                                                 FROM Donor_Constituency__c Where Constituency_Type__c = 'Regular Giver' and End_Date__c = null and Account__c IN:accWithNoActiveRD  ]) 
                {
                    dc.End_Date__c = todaysDate;
                    dcListToUpdate.add(dc);
                }
                
                
            }
            
            if(conWithNoActiveRD!=null && !conWithNoActiveRD.isEmpty()) {
                 //Update RD status in Contact to Inactive
                List<Contact> conWithNoActiveRDList = [Select Recurring_Donor_Status__c From Contact Where Id IN: conWithNoActiveRD];
                
                for (Contact con : conWithNoActiveRDList) {
                    con.Recurring_Donor_Status__c = 'Inactive';
                }
                dmlWrapper.objectsToUpdate.addAll((list<Contact>)conWithNoActiveRDList);
                
                //End Date added to Donor Constituency
                for (Donor_Constituency__c dc : [SELECT Id, End_Date__c, Contact__c, Account__c 
                                                 FROM Donor_Constituency__c Where Constituency_Type__c = 'Regular Giver' and End_Date__c = null and  Contact__c IN:conWithNoActiveRD  ])
                {
                    dc.End_Date__c = todaysDate;
                    dcListToUpdate.add(dc);
                }
            }
            System.System.debug('Donor Constituency Records to Update End_Date__c ***'+dcListToUpdate);
            if(dcListToUpdate!=null && !dcListToUpdate.isEmpty()) {
                dmlWrapper.objectsToUpdate.addAll((list<Donor_Constituency__c>)dcListToUpdate);
            }
            
        } 
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            System.System.debug('*******:::::BeforeInsert.Size():::::*****'+newlist.size());
            Set<Id> donnorAccIds = new Set<Id>();
            Set<Id> donnorConIds = new Set<Id>();
            for (npe03__Recurring_Donation__c rd : (list<npe03__Recurring_Donation__c>)newlist) {
                if(rd.Donor_Type__c == 'Account'){
                    donnorAccIds.add(rd.npe03__Organization__c);
                }else if(rd.Donor_Type__c == 'Contact') {
                    donnorConIds.add(rd.npe03__Contact__c );
                }  

                if(rd.npsp__PaymentMethod__c == 'Credit Card' && rd.Card_Token__c == null){
                    rd.npsp__Status__c = 'Held';
                    rd.npsp__ClosedReason__c = 'Waiting for Payment details';
                }else if(rd.npsp__PaymentMethod__c == 'Direct Debit' && (rd.Account_Number__c == null || rd.Account_BSB__c == null) ){
                    rd.npsp__Status__c = 'Held';
                    rd.npsp__ClosedReason__c = 'Waiting for Payment details';
                }else if(rd.npsp__PaymentMethod__c == null){
                    rd.npsp__Status__c = 'Held';
                    rd.npsp__ClosedReason__c = 'Waiting for Payment details';
                }

                
            }
            Map<Id,Account> accountRDMap;
            Map<Id,Contact> contactRDMap;
            if(donnorAccIds != null){
                accountRDMap = new Map<Id,Account>([Select Id,Email__c From Account Where Id IN:donnorAccIds and Email__c != null  ]);
            }
            if(donnorConIds != null){
               contactRDMap = new Map<Id,Contact>([Select Id,Email From Contact Where Id IN:donnorConIds and Email != null  ]);
            }
            for (npe03__Recurring_Donation__c rd : (list<npe03__Recurring_Donation__c>)newlist) {
                if(rd.Donor_Type__c == 'Account' ){
                    if(accountRDMap.get(rd.npe03__Organization__c) != null){
                        rd.Donor_Email__c = accountRDMap.get(rd.npe03__Organization__c).Email__c;
                    }
                }else if(rd.Donor_Type__c == 'Contact') {
                    if(contactRDMap.get(rd.npe03__Contact__c) != null){
                        rd.Donor_Email__c = contactRDMap.get(rd.npe03__Contact__c).Email;
                    }
                } 
            }
        }
        
        return dmlWrapper;
    }
}