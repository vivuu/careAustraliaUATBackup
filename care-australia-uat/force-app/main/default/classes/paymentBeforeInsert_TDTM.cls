global class paymentBeforeInsert_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert){
            //Added by Akshay for Batch Number Generation Functionality.
          /*List<npe01__OppPayment__c> latestPaymentRecord    = [SELECT Id, npsp__Batch_Number__c 
                                                                 FROM npe01__OppPayment__c
                                                                 WHERE (npsp__Batch_Number__c != null OR npsp__Batch_Number__c != '') AND npsp__Batch_Number__c LIKE 'BN%'
                                                                 ORDER BY npsp__Batch_Number__c DESC
                                                                 LIMIT 1];
            String generatedBatchNumber       = 'BN00000001';
            if(!latestPaymentRecord.isEmpty()){
                generatedBatchNumber        = latestPaymentRecord[0].npsp__Batch_Number__c;
                String batchNumberChars 	= generatedBatchNumber.substring(0,3);
                Decimal batchNumberNums 	= Decimal.valueOf(generatedBatchNumber.substring(3,10));
                batchNumberNums        	   += 1;
                generatedBatchNumber        = batchNumberChars + String.valueOf(batchNumberNums).leftpad(7,'0');
            }*/
           
            
            Latest_Batch_Number__c latestBatchNumber = Latest_Batch_Number__c.getValues('Batch Number');
             String generatedBatchNumber       = 'BN00000001';
             if(latestBatchNumber != null){
                generatedBatchNumber        = latestBatchNumber.Payment_Batch_Number__c;
                String batchNumberChars 	= generatedBatchNumber.substring(0,3);
                Decimal batchNumberNums 	= Decimal.valueOf(generatedBatchNumber.substring(3,10));
                batchNumberNums        	   += 1;
                generatedBatchNumber        = batchNumberChars + String.valueOf(batchNumberNums).leftpad(7,'0');
                latestBatchNumber.Payment_Batch_Number__c = generatedBatchNumber;
                 //update latestBatchNumber;
                 
             }            
            System.System.debug('*******generatedBatchNumberAFTER*****'+generatedBatchNumber);
            
            

            System.System.debug('*******:::::paymentBeforeInsert_TDTM.Size():::::*****'+newlist.size());
            Set<Id> paymentOppIds = new Set<Id>();
            
           
            
            for (npe01__OppPayment__c  payment : (list<npe01__OppPayment__c >)newlist) {
                paymentOppIds.add(payment.npe01__Opportunity__c );
            }
            Boolean Memory_of_Result;
            string memoryof ='<memoryof>';
            Boolean FNAME_Result;
            string FNAME = '<FNAME>';
            
            Map<Id,Opportunity> paymentOpportunityMap; 
            if(paymentOppIds != null){
                paymentOpportunityMap = new Map<Id,Opportunity>([SELECT Id,Donation_Source__c, RecordTypeId,AccountId,Account.Email__c,Solicitor_Email__c,Account.Do_Not_Email__c, npsp__Primary_Contact__c,
                                                                 npsp__Primary_Contact__r.Email,npsp__Primary_Contact__r.Do_Not_Email__c,CampaignId,npe03__Recurring_Donation__c,
                                                                 Campaign.AUS_Code__c,Campaign.GAU__c,Donor_Type__c,Campaign.Email_Content__c,npsp__Honoree_Name__c,
                                                                 npsp__Primary_Contact__r.FirstName 
                                                                 FROM Opportunity Where Id IN: paymentOppIds ]);
            }
            
             List<Finance_Debit_AC_Mapping__mdt> financeACMappingList = [Select AC_Code__c,Card_Type__c,Donation_Source__c,Merchant_Category__c, 
                                                                    Payment_Method__c From Finance_Debit_AC_Mapping__mdt];
            for (Finance_Debit_AC_Mapping__mdt  financeACMapping : financeACMappingList) {
                for (npe01__OppPayment__c  payment : (list<npe01__OppPayment__c >)newlist) {
                    if(payment.Card_Type__c == financeACMapping.Card_Type__c && payment.Merchant_Category__c == financeACMapping.Merchant_Category__c  && 
                       payment.npe01__Payment_Method__c == financeACMapping.Payment_Method__c && 
                       paymentOpportunityMap.get(payment.npe01__Opportunity__c).Donation_Source__c == financeACMapping.Donation_Source__c){
                           
                        payment.Credit_AC_Code__c = financeACMapping.AC_Code__c;
                    }
                }
            }
            
            system.debug('paymentOpportunityMap'+paymentOpportunityMap);
            Opportunity opp = new Opportunity();
            for (npe01__OppPayment__c  payment : (list<npe01__OppPayment__c >)newlist) {
                
                if(payment.npe01__Written_Off__c == true && payment.Refund_Status__c == 'Processed'){
                        payment.npe01__Paid__c = false;
                }
                opp = paymentOpportunityMap.get(payment.npe01__Opportunity__c);
                
                if( opp != null){
                    //Added by Akshay for Batch Number Generation Functionality.
                    if(opp.npe03__Recurring_Donation__c == null){
                        if(String.isBlank(payment.npsp__Batch_Number__c)){
                            payment.npsp__Batch_Number__c = generatedBatchNumber;
                        }
                    }
                    //Add GAU and AUS Code from Oppportunity Campaign
                    if(opp.CampaignId != null){
                        if(opp.Campaign.AUS_Code__c != null){
                            payment.AUS_Code__c = opp.Campaign.AUS_Code__c;
                        }
                        if(opp.Campaign.GAU__c != null){
                            payment.GAU__c = opp.Campaign.GAU__c;
                        }
                        //set Campaign Email Content to payment
                       /*--original--if(opp.Campaign.Email_Content__c != null){
                            Memory_of_Result = opp.Campaign.Email_Content__c.contains(memoryof); 
                            if(Memory_of_Result ){		
                                if(opp.npsp__Honoree_Name__c != null){
                                    payment.Email_Content_Merged__c= opp.Campaign.Email_Content__c.replace(memoryof,opp.npsp__Honoree_Name__c);
                                }
                            }else{
                                payment.Email_Content_Merged__c= opp.Campaign.Email_Content__c;
                            }
                        }-----original ended---*/
                        
                       /*if(opp.npsp__Honoree_Name__c != null){
                            Memory_of_Result = opp.Campaign.Email_Content__c.contains(memoryof); 
                            if(Memory_of_Result )
                            {		
                                payment.Email_Content_Merged__c= opp.Campaign.Email_Content__c.replace(memoryof,opp.npsp__Honoree_Name__c);
                            }              	
                        }else if(opp.Campaign.Email_Content__c != null){

                            payment.Email_Content_Merged__c= opp.Campaign.Email_Content__c;
                        }*/
                        if(opp.Campaign.Email_Content__c != null){
                            system.debug('Email Content Campaign under if : '+ opp.Campaign.Email_Content__c);
                            FNAME_Result = opp.Campaign.Email_Content__c.contains(FNAME);
                            Memory_of_Result = opp.Campaign.Email_Content__c.contains(memoryof); 
                            system.debug('Memory of Result outer if check : '+ Memory_of_Result);
                            
                            if(Memory_of_Result ){
                                system.debug('Memory of Result : '+ Memory_of_Result);
                                if(opp.npsp__Honoree_Name__c != null){
                                    system.debug('Honoree Name : '+ opp.npsp__Honoree_Name__c);
                                    payment.Email_Content_Merged__c= opp.Campaign.Email_Content__c.replace(memoryof,opp.npsp__Honoree_Name__c);
                                    system.debug('Payment Email Content : '+ payment.Email_Content_Merged__c);
                                }   
                            }
                            else if(FNAME_Result) {
                                if(opp.npsp__Primary_Contact__r.FirstName != null){
                                    payment.Email_Content_Merged__c= opp.Campaign.Email_Content__c.replace(FNAME,opp.npsp__Primary_Contact__r.FirstName);
                                    
                                }   
                            }
                            else if(FNAME_Result==False && Memory_of_Result == False){
                                payment.Email_Content_Merged__c= opp.Campaign.Email_Content__c;
                            }
                        } 
                        
                    }
                    //Check opportunity Record Type equals Estate
                    if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Estate').getRecordTypeId()){
                        if(opp.Solicitor_Email__c != null){
                            payment.Donor_Email__c = opp.Solicitor_Email__c;
                        }
                    }else{
                        //Check opportunity Record Type not equals Estate
                        if(opp.Donor_Type__c == 'Account'){
                            if(opp.Account.Email__c != null ){
                                payment.Donor_Email__c = opp.Account.Email__c;
                            }
                        }else if(opp.Donor_Type__c == 'Contact'){
                            if(opp.npsp__Primary_Contact__r.Email != null ){
                                payment.Donor_Email__c = opp.npsp__Primary_Contact__r.Email;
                            }
                        }  
                    }
                    if(opp.npsp__Primary_Contact__c != null){
                        if(opp.npsp__Primary_Contact__r.Email != null 
                           && opp.npsp__Primary_Contact__r.Do_Not_Email__c == false){
                               payment.Contact_Email__c = opp.npsp__Primary_Contact__r.Email;
                           }
                    }
                    
                    
                }
            } 
        } 
        return dmlWrapper; 
    } 
}