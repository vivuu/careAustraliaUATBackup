global class paymentAfterInsertUpdate_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                                      List<SObject> oldlist,
                                                      npsp.TDTM_Runnable.Action triggerAction,
                                                      Schema.DescribeSObjectResult objResult)
    {
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate){
            
            Set<Id> oppid = new Set<Id>();
            npe01__OppPayment__c payObj;
            Map<Id,Boolean> paymentPaidMap = new Map<Id,Boolean>();
            Map<Id,Date> paymentDateMap = new Map<Id,Date>();
            Map<Id,Decimal> paymentAmountMap = new Map<Id,Decimal>();
            
            if(newlist != null){
                for(SObject pNew : newlist){
                    payObj = (npe01__OppPayment__c)pNew;
                    oppid.add(payObj.npe01__Opportunity__c);
                    paymentPaidMap.put(payObj.npe01__Opportunity__c,payObj.npe01__Paid__c);
                    paymentDateMap.put(payObj.npe01__Opportunity__c,payObj.npe01__Payment_Date__c);
                    paymentAmountMap.put(payObj.npe01__Opportunity__c, payObj.npe01__Payment_Amount__c);
                }
            }
            
            List<Opportunity> oppList = [select id,name,RecordType.Name,Number_of_Consecutive_payments__c,Last_Bounced_Date__c,Bounced_Payments__c,Last_Payment_Date__c from Opportunity where id in : oppid];
            List<Opportunity> oppUpdtList = new List<Opportunity>();
            system.debug('*****oppList*****'+oppList);
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    if(paymentPaidMap.get(opp.Id) != null && opp.RecordType.Name == 'Recurring Donation' && paymentPaidMap.get(opp.Id) == true){
                        if(opp.Number_of_Consecutive_payments__c == null){
                            opp.Number_of_Consecutive_payments__c = 1;
                        }else{
                            if(opp.Last_Payment_Date__c != null){
                                if(paymentDateMap.get(opp.Id) != null && paymentDateMap.get(opp.Id).month() == opp.Last_Payment_Date__c.month()+1){
                                    opp.Number_of_Consecutive_payments__c = opp.Number_of_Consecutive_payments__c + 1;
                                }else{
                                    if(paymentDateMap.get(opp.Id) != null && paymentDateMap.get(opp.Id).year() == opp.Last_Payment_Date__c.year()+1 && opp.Last_Payment_Date__c.month() == 12){
                                        system.debug('Cons Year Change*****');
                                        opp.Number_of_Consecutive_payments__c = opp.Number_of_Consecutive_payments__c + 1;
                                    }else{
                                        system.debug('Streak Break*****');
                                        opp.Number_of_Consecutive_payments__c = 1;
                                    }
                                } 
                            }
                            
                        }
                        if(paymentAmountMap.get(opp.Id) != null && paymentAmountMap.get(opp.Id) == 0){
                            if(opp.Bounced_Payments__c == null){
                                opp.Bounced_Payments__c = 1;
                            }else{
                                if(opp.Last_Bounced_Date__c != null && paymentDateMap.get(opp.Id).month() != null && paymentDateMap.get(opp.Id).month() == opp.Last_Bounced_Date__c.month()+2){
                                    opp.Bounced_Payments__c = 1;
                                }
                                opp.Bounced_Payments__c = opp.Bounced_Payments__c + 1;
                            }
                        }
                    }
                    oppUpdtList.add(opp);
                }
            }
            
            if(!oppUpdtList.isEmpty()){
                system.debug('*****oppUpdtList*****'+oppUpdtList);
                update oppUpdtList;
            }
        }
        
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate || triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){
            
            Set<Id> paymentId = new Set<Id>();
            List<npe01__OppPayment__c> financeRepError = new List<npe01__OppPayment__c>();
            Map<Id,String> payRefundOldMap = new Map<Id,String>();
            Map<Id,Boolean> payWriteOldMap = new Map<Id,Boolean>();
            Map<Id,String> payChargebackOldMap = new Map<Id,String>();
            Map<Id,String> payAdjustOldMap = new Map<Id,String>();
            Map<Id,String> payGAUOldMap = new Map<Id,String>();
            Map<Id,String> payAusCodeOldMap = new Map<Id,String>();
            Map<Id,String> accMap = new Map<Id,String>();
            Map<Id,String> conMap = new Map<Id,String>();
            List<Finance_Reporting__c> frList = new List<Finance_Reporting__c>();
            List<Finance_Reporting__c> frListPaid = new List<Finance_Reporting__c>();
            List<Finance_Reporting__c> frList2 = new List<Finance_Reporting__c>();
            List<Finance_Reporting__c> frList3 = new List<Finance_Reporting__c>();
            String payError;
            npe01__OppPayment__c payObj;
            
            if(oldlist != null){
                for(SObject pOld : oldlist){
                    payObj = (npe01__OppPayment__c)pOld;
                    payRefundOldMap.put(payObj.Id , payObj.Refund_Status__c);
                    payWriteOldMap.put(payObj.Id , payObj.npe01__Written_Off__c);
                    payChargebackOldMap.put(payObj.Id, payObj.Chargeback_Status__c);
                    payAdjustOldMap.put(payObj.Id, payObj.Adjustment_Status__c);
                    payGAUOldMap.put(payObj.Id, payObj.GAU__c);
                    payAusCodeOldMap.put(payObj.Id, payObj.AUS_Code__c);
                }
            }
            
            
            Set<String> oppid = new Set<String>();
            if(newlist != null){
                for(SObject pNew : newlist){
                    payObj = (npe01__OppPayment__c)pNew;
                    paymentId.add(payObj.Id);
                    oppid.add(payObj.npe01__Opportunity__c);
                }
            }
            
            List<Opportunity> oppList = [select id,name,AccountId,npsp__Primary_Contact__c from Opportunity where Id =: oppid];
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    accMap.put(opp.Id , opp.AccountId);
                    if(opp.npsp__Primary_Contact__c != null){
                        conMap.put(opp.Id , opp.npsp__Primary_Contact__c);
                    }
                }
            }
            
            //List<Finance_Reporting__c> getAllFrList = [select id,name,Transaction_Number__c,Transaction_Type__c from Finance_Reporting__c];
            
            for(SObject pNew : newlist){
                payObj = (npe01__OppPayment__c)pNew;
                
                //Payment Paid
                
                if(payObj.npe01__Payment_Amount__c != null && payObj.npe01__Paid__c == true && payObj.Adjustment_Status__c != 'Processed' && payObj.FinanceReportCheck__c == false){
                    Finance_Reporting__c fr = new Finance_Reporting__c();
                    fr.Transaction_Type__c = 'Payment';
                    fr.Amount__c = payObj.npe01__Payment_Amount__c;
                    fr.GAU__c = payObj.GAU__c;
                    fr.AUS_Code__c = payObj.AUS_Code__c;
                    fr.Transaction_Number__c = payObj.Name;
                    fr.Transaction_Date__c = payObj.npe01__Payment_Date__c;
                    fr.Opportunity__c = payObj.npe01__Opportunity__c;
                    fr.Payment__c = payObj.Id;
                    fr.Account__c = accMap.get(payObj.npe01__Opportunity__c);
                    fr.Contact__c = conMap.get(payObj.npe01__Opportunity__c);
                    fr.Credit_AC_Code__c = payObj.Credit_AC_Code__c;
                    fr.Debit_AC_Code__c = payObj.Debit_AC_Code__c;
                    fr.Period__c = getPeriod(payObj.Refund_Date__c);
                    frListPaid.add(fr);
                }
                
                
                //Payment Refund
                
                if(payObj.npe01__Payment_Amount__c != null && payObj.Refund_Status__c == 'Processed' && payObj.npe01__Written_Off__c == true && 
                   (payRefundOldMap.get(payObj.Id) != payObj.Refund_Status__c 
                    || payWriteOldMap.get(payObj.Id) != payObj.npe01__Written_Off__c)){
                        Finance_Reporting__c fr = new Finance_Reporting__c();
                        fr.Transaction_Type__c = 'Refund';
                        fr.Amount__c = -(payObj.npe01__Payment_Amount__c);
                        fr.GAU__c = payObj.GAU__c;
                        fr.AUS_Code__c = payObj.AUS_Code__c;
                        fr.Transaction_Number__c = payObj.Name;
                        fr.Transaction_Date__c = payObj.Refund_Date__c;
                        fr.Opportunity__c = payObj.npe01__Opportunity__c;
                        fr.Payment__c = payObj.Id;
                        fr.Account__c = accMap.get(payObj.npe01__Opportunity__c);
                        fr.Contact__c = conMap.get(payObj.npe01__Opportunity__c);
                        fr.Credit_AC_Code__c =payObj.Credit_AC_Code__c;
                        fr.Debit_AC_Code__c =payObj.Debit_AC_Code__c;
                        fr.Period__c = getPeriod(payObj.Refund_Date__c);
                        frList.add(fr);
                    }
                
                // Payment Chargeback
                
                if(payObj.npe01__Payment_Amount__c != null && payObj.Chargeback_Status__c == 'Approved' && payObj.npe01__Written_Off__c == true &&
                   (payChargebackOldMap.get(payObj.Id) != payObj.Chargeback_Status__c 
                    || payWriteOldMap.get(payObj.Id) != payObj.npe01__Written_Off__c)){
                        
                        Finance_Reporting__c fr = new Finance_Reporting__c();
                        fr.Transaction_Type__c = 'Chargeback';
                        fr.Amount__c = -(payObj.npe01__Payment_Amount__c);
                        fr.GAU__c = payObj.GAU__c;
                        fr.AUS_Code__c = payObj.AUS_Code__c;
                        fr.Transaction_Number__c = payObj.Name;
                        fr.Transaction_Date__c = payObj.Chargeback_Date__c;
                        fr.Opportunity__c = payObj.npe01__Opportunity__c;
                        fr.Payment__c = payObj.Id;
                        fr.Account__c = accMap.get(payObj.npe01__Opportunity__c);
                        fr.Contact__c = conMap.get(payObj.npe01__Opportunity__c);
                        fr.Credit_AC_Code__c =payObj.Credit_AC_Code__c;
                        fr.Debit_AC_Code__c =payObj.Debit_AC_Code__c;
                        fr.Period__c = getPeriod(payObj.Chargeback_Date__c);
                        frList2.add(fr);
                        
                    }
                
                // Payment Adjustment
                
                if(payObj.npe01__Payment_Amount__c != null && payObj.Adjustment_Status__c == 'Processed' && payAdjustOldMap.get(payObj.Id) != payObj.Adjustment_Status__c
                   && (payObj.GAU__c != payGAUOldMap.get(payObj.Id)
                       || payObj.AUS_Code__c != payAusCodeOldMap.get(payObj.Id))){
                           
                           // Negative entry with old AUS Code and GAU
                           
                           Finance_Reporting__c fr = new Finance_Reporting__c();
                           fr.Transaction_Type__c = 'Adjustment';
                           fr.Amount__c = -(payObj.npe01__Payment_Amount__c);
                           fr.GAU__c = payGAUOldMap.get(payObj.Id);
                           fr.AUS_Code__c = payAusCodeOldMap.get(payObj.Id);
                           fr.Transaction_Number__c = payObj.Name;
                           fr.Transaction_Date__c = payObj.Adjustment_Date__c;
                           fr.Opportunity__c = payObj.npe01__Opportunity__c;
                           fr.Payment__c = payObj.Id;
                           fr.Account__c = accMap.get(payObj.npe01__Opportunity__c);
                           fr.Contact__c = conMap.get(payObj.npe01__Opportunity__c);
                           fr.Credit_AC_Code__c =payObj.Credit_AC_Code__c;
                           fr.Debit_AC_Code__c =payObj.Debit_AC_Code__c;
                           fr.Period__c = getPeriod(payObj.Adjustment_Date__c);
                           frList3.add(fr);
                           
                           // Positive entry with AUS Code and GAU
                           
                           Finance_Reporting__c frP = new Finance_Reporting__c();
                           frP.Transaction_Type__c = 'Adjustment';
                           frP.Amount__c = payObj.npe01__Payment_Amount__c;
                           frP.GAU__c = payObj.GAU__c;
                           frP.AUS_Code__c = payObj.AUS_Code__c;
                           frP.Transaction_Number__c = payObj.Name;
                           frP.Transaction_Date__c = payObj.Adjustment_Date__c;
                           frP.Opportunity__c = payObj.npe01__Opportunity__c;
                           frP.Payment__c = payObj.Id;
                           frP.Account__c = accMap.get(payObj.npe01__Opportunity__c);
                           frP.Contact__c = conMap.get(payObj.npe01__Opportunity__c);
                           fr.Credit_AC_Code__c =payObj.Credit_AC_Code__c;
                           fr.Debit_AC_Code__c =payObj.Debit_AC_Code__c;
                           fr.Period__c = getPeriod(payObj.Adjustment_Date__c);
                           frList3.add(frP);
                           
                       }
            }
            
            if(frListPaid.isEmpty()){
                system.debug('No Finance Records to create for Payment!!');
            }else{
                Database.SaveResult[] srList = Database.insert(frListPaid, false);
                system.debug('srList=='+srList);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted Payment Finance Record: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            String str = JSON.serialize(err);
                            system.debug('Exception jason=='+err);
                            payError = str;
                        }
                    }
                }
            }
            
            if(frList.isEmpty()){
                system.debug('No Finance Records to create for refund!!');
            }else{
                Database.SaveResult[] srList = Database.insert(frList, false);
                system.debug('srList=='+srList);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted Finance Record: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            String str = JSON.serialize(err);
                            system.debug('Exception jason=='+err);
                            payError = str;
                        }
                    }
                }
            }
            if(frList2.isEmpty()){
                system.debug('No Finance Records to create for Chargeback!!');
            }else{
                Database.SaveResult[] srList = Database.insert(frList2, false);
                system.debug('srList=='+srList);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted Finance Record: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            String str = JSON.serialize(err);
                            system.debug('Exception json=='+err);
                            payError = str;
                        }
                    }
                }
            }
            if(frList3.isEmpty()){
                system.debug('No Finance Records to create for Adjustment!!');
            }else{
                Database.SaveResult[] srList = Database.insert(frList3, false);
                system.debug('srList=='+srList);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted Finance Record: ' + sr.getId());
                    }
                    else {                
                        for(Database.Error err : sr.getErrors()) {
                            String str = JSON.serialize(err);
                            system.debug('Exception json=='+err);
                            payError = str;
                        }
                    }
                }
            }
            if(payError != null){
                List<npe01__OppPayment__c> payRec = [select id,name,Finance_Report_Error__c from npe01__OppPayment__c where id =: paymentId];
                for(npe01__OppPayment__c pNew : payRec){
                    pNew.Finance_Report_Error__c = payError;
                    financeRepError.add(pNew);
                }
                update financeRepError;
            }
        }
        return dmlWrapper;
    }
    
    public String getPeriod(Date newDate){
        if(newDate != null){
            Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization 
                                            where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
            Integer fiscalYear;
            Financial_Year_Period__mdt fyp = [Select Value__c from Financial_Year_Period__mdt where Month__c =: newDate.month()];
            if(newDate.month() >= FiscalYearStartMonth){
                fiscalYear = newDate.year()   ;
            }else{
                fiscalYear = newDate.year() - 1   ;
            }   
            String Period = fiscalYear+fyp.Value__c;
            return Period;
        }
        return '';
    }
}