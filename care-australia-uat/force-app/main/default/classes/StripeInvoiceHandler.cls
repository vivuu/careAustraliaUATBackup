public class StripeInvoiceHandler {
    public static void getInvoice(){
        try{
            if(Stripe_Setting__c.getInstance('Default').Activation__c){
             	Stripe_Batch_Setting__c custoSettingVal;
                DateTime batchRunDate;
                String body;
                String requestUrl;
                custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeInvoiceBatch');
                batchRunDate = custoSettingVal.Last_Run_At__c != null ? custoSettingVal.Last_Run_At__c : null;
                if(batchRunDate == null){
                    //HttpResponse response = StripeConnection.getInvoice(null, body);
                    requestUrl = '/search?query=created>=1665599251&limit=100';
                    
                }
                else{
                    requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
                }
                //system.debug(((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000));
                HttpResponse response = getStripeAPI(requestUrl, 'Stripe_Get_Invoice_API');
                if(response.getStatusCode() < 200 || response.getStatusCode() > 299){
                    throw new StripeAPIException('Invoice Records not received from Stripe : ' + response.getBody());
                }
                StripeGetInvoiceWrapper responseWrapper = StripeGetInvoiceWrapper.parse(response.getBody());
                Map<String, StripeGetInvoiceWrapper.cls_data> invoiceMap = new Map<String, StripeGetInvoiceWrapper.cls_data>();
                Set<String> subscriptionSet = new Set<String>();
                for(integer i=0; i < responseWrapper.data.Size(); i++){
                    if(!invoiceMap.containsKey(responseWrapper.data[i].id)){
                        invoiceMap.put(responseWrapper.data[i].id, responseWrapper.data[i]);
                        if(String.isNotEmpty(responseWrapper.data[i].subscription)){
                            subscriptionSet.add(responseWrapper.data[i].subscription);
                        }
                    }
                }
                while(responseWrapper.has_more != false){
                    if(batchRunDate == null){
                        //HttpResponse response = StripeConnection.getInvoice(null, body);
                        requestUrl = '/search?query=created>=1665599251&limit=100';
                        
                    }
                    else{
                        requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
                    }
                    requestUrl = requestUrl+'&page='+responseWrapper.next_page;
                    response = getStripeAPI(requestUrl, 'Stripe_Get_Invoice_API');
                    responseWrapper = StripeGetInvoiceWrapper.parse(response.getBody());
                    for(integer i=0; i < responseWrapper.data.Size(); i++){
                        if(!invoiceMap.containsKey(responseWrapper.data[i].id)){
                            invoiceMap.put(responseWrapper.data[i].id, responseWrapper.data[i]);
                            if(String.isNotEmpty(responseWrapper.data[i].subscription)){
                                subscriptionSet.add(responseWrapper.data[i].subscription);
                            }
                        }
                    }    
                }
                
                Map<String, StripeGetPaymentIntentWrapper.Data_Z> paymentIntentMap = getPaymentIntent();
                Map<String, StripeGetChargeWrapper.cls_data> chargeMap = getCharge();
                Map<String, String> customerMap = getCustomer();
                
                list<Opportunity> oppList = new List<Opportunity>();
                list<npe03__Recurring_Donation__c> rdListUpdateList = new list<npe03__Recurring_Donation__c>();
                
                //system.debug(invoiceMap.keySet().size());
                List<npe03__Recurring_Donation__c> rdList = [Select Id, stripe_subscription_id__c, (Select id, CloseDate from npe03__Donations__r  where StageName = 'Pledged' order by CreatedDate desc Limit 1) from npe03__Recurring_Donation__c WHERE Stripe_Subscription_Id__c  in: subscriptionSet];
                Map<String, npe03__Recurring_Donation__c> rdMap = new Map<String, npe03__Recurring_Donation__c>();
                for(npe03__Recurring_Donation__c rd : rdList){
                    if(!rdMap.containsKey(rd.stripe_subscription_id__c)){
                        rdMap.put(rd.stripe_subscription_id__c, rd);
                    }
                }
                system.debug(rdList);
                for(StripeGetInvoiceWrapper.cls_data invoicerRec : invoiceMap.values()){
                    system.debug(invoicerRec.subscription);
                    StripeGetPaymentIntentWrapper.Data_Z piValue = paymentIntentMap.get(invoicerRec.id);
                    if(String.isNotEmpty(invoicerRec.subscription) && rdMap.containsKey(invoicerRec.subscription)){
                        npe03__Recurring_Donation__c rdRec = rdMap.get(invoicerRec.subscription);
                        if(piValue != null && piValue.charges != null && !piValue.charges.data.isEmpty() && piValue.charges.data[0].payment_method_details != null && piValue.charges.data[0].payment_method_details.type == 'card'){
                            rdRec.Card_Number_Masked__c = ('************' + piValue.charges.data[0].payment_method_details.card.last4);
                            rdRec.npsp__PaymentMethod__c = 'Credit Card';
                            rdRec.Card_Type__c = piValue.charges.data[0].payment_method_details.card.brand;
                            rdRec.Card_Token__c = piValue.charges.data[0].payment_method_details.card.fingerprint;
                            rdRec.npsp__CardExpirationMonth__c = String.valueOf(piValue.charges.data[0].payment_method_details.card.exp_month);
                            rdRec.npsp__CardExpirationYear__c = String.valueOf(piValue.charges.data[0].payment_method_details.card.exp_year);
                            rdRec.Stripe_Payment_Method_Id__c = piValue.charges.data[0].payment_method;
                        }
                        rdListUpdateList.add(rdRec);
                        for(integer i = 0; i < rdRec.npe03__Donations__r.size(); i++){
                            system.debug(rdRec.npe03__Donations__r);
                            system.debug(rdRec.npe03__Donations__r[0].CloseDate + ' ' + DateTime.newInstance(long.valueOf(invoicerRec.created)*1000).date());
                            if(rdRec.npe03__Donations__r[0].CloseDate == DateTime.newInstance(long.valueOf(invoicerRec.created)*1000).date()){
                                Opportunity opp = new Opportunity();
                                opp.id = rdRec.npe03__Donations__r[0].id;
                                opp.Stripe_Invoice_Id__c = invoicerRec.id;
                                if(invoicerRec.status == 'Paid'){
                                    opp.StageName = 'Closed Won';
                                }
                                if(piValue != null && piValue.charges != null && !piValue.charges.data.isEmpty() && piValue.charges.data[0].payment_method_details != null && piValue.charges.data[0].payment_method_details.type == 'card'){
                                    opp.Card_Number_Masked__c = ('************' + piValue.charges.data[0].payment_method_details.card.last4);
                                    opp.Payment_Method__c = 'Credit Card';
                                    opp.Card_Type__c = piValue.charges.data[0].payment_method_details.card.brand;
                                    opp.Card_Token__c = piValue.charges.data[0].payment_method_details.card.fingerprint;
                                    opp.Card_Expiration_Month__c = String.valueOf(piValue.charges.data[0].payment_method_details.card.exp_month);
                                    opp.Card_Expiration_Year__c = String.valueOf(piValue.charges.data[0].payment_method_details.card.exp_year);
                                    opp.Stripe_Payment_Method_Id__c = piValue.charges.data[0].payment_method;
                                }
                                oppList.add(opp);
                            }
                        }
                    }
                }
                
                if(oppList != null && oppList.size()>0){
                    update oppList;
                }
               
                List<npe03__Recurring_Donation__c> rdListUpdate = new List<npe03__Recurring_Donation__c>();
                List<Opportunity> oppListUpdate = new List<Opportunity>();
                for(Opportunity oppRec : [Select id, StageName, Stripe_PI_ID__c, Stripe_Invoice_Id__c, npe03__Recurring_Donation__c  from Opportunity WHERE Stripe_Invoice_Id__c IN : paymentIntentMap.keySet() AND  Stripe_Invoice_Id__c != null]){
                    npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
                    rd.id = oppRec.npe03__Recurring_Donation__c;
                    StripeGetPaymentIntentWrapper.Data_Z piValue = paymentIntentMap.get(oppRec.Stripe_Invoice_Id__c);
                    StripeGetChargeWrapper.cls_data chargeValue = chargeMap.get(piValue.Id);
                    oppRec.Stripe_PI_ID__c = piValue.Id;
                    system.debug('ININ');
                    if(piValue.status == 'succeeded'){
                        rd.Failed_Consecutive_Opportunities__c = 0;
                        oppRec.StageName = 'Closed Won';
                    }
                    else if(piValue.status != 'succeeded' && chargeValue != null && chargeValue.status == 'failed'){
                        oppRec.StageName = 'Closed Lost';
                        rd.Failed_Consecutive_Opportunities__c += 1;
                        if(rd.Failed_Consecutive_Opportunities__c == 3){
                            rd.npsp__Status__c = 'Cancelled';
                        }
                        system.debug('IN');
                    }
                    rdListUpdate.add(rd);
                    oppListUpdate.add(oppRec);
                }
                
                List<Contact> contactIdList = [SELECT Id, stripe_customer_id__c, Name FROM Contact WHERE stripe_customer_id__c IN: customerMap.values()];
                Map<String, Contact> contactIdMap = new Map<String, Contact>();
                if(!contactIdList.isEmpty()){
                    for(Contact con : contactIdList){
                        if(!contactIdMap.containsKey(con.stripe_customer_id__c) &&  String.isNotEmpty(con.stripe_customer_id__c)){
                            contactIdMap.put(con.stripe_customer_id__c, con);
                        }
                    }
                }
                
                System.debug(contactIdList);
                System.debug(contactIdMap.size());
                System.debug(contactIdMap);
                List<Opportunity> oppListCustomer = new List<Opportunity>();
                for(npe01__OppPayment__c paymentRec : [SELECT Id, npe01__Opportunity__c, stripe_charge_id__c, npe01__Scheduled_Date__c  FROM npe01__OppPayment__c WHERE stripe_charge_id__c IN: customerMap.keySet()]){
                    if(contactIdMap.get(customerMap.get(paymentRec.Stripe_Charge_ID__c)) != null){
                        Opportunity opp = new Opportunity();
                        opp.Id = paymentRec.npe01__Opportunity__c;
                        opp.npsp__Primary_Contact__c = contactIdMap.get(customerMap.get(paymentRec.Stripe_Charge_ID__c)).Id;
                        opp.Name = contactIdMap.get(customerMap.get(paymentRec.Stripe_Charge_ID__c))?.Name + ' ' + String.valueOf(paymentRec.npe01__Scheduled_Date__c);
                        oppListCustomer.add(opp);    
                    }
                }
                
                if(!rdListUpdateList.isEmpty()){
                    update rdListUpdate;
                }
                
                if(rdListUpdate != null && rdListUpdate.size()>0){
                    update rdListUpdate;
                }
                
                if(oppListUpdate != null && oppListUpdate.size()>0){
                    update oppListUpdate;
                }
                
                if(!oppListCustomer.isEmpty()){
                    update oppListCustomer;
                }
                
                
                if(custoSettingVal != null){
                    custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeInvoiceBatch');
                    custoSettingVal.Last_Run_At__c = Date.today();
                    update custoSettingVal;
                }   
            }   
        }catch(Exception e){
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripeInvoiceHandler', e.getMessage(), 'StripeInvoiceHandler', e.getStackTraceString());
        }
    }
    
    public static Map<String, StripeGetPaymentIntentWrapper.Data_Z> getPaymentIntent(){
        Stripe_Batch_Setting__c custoSettingVal;
        DateTime batchRunDate;
        String body;
        String requestUrl;
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeInvoiceBatch');
        batchRunDate = custoSettingVal.Last_Run_At__c != null ? custoSettingVal.Last_Run_At__c : null;
        if(batchRunDate == null){
            //HttpResponse response = StripeConnection.getInvoice(null, body);
            requestUrl = '/search?query=created>=1665599251&limit=100';
            
        }
        else{
            requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
        }
        //system.debug(((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000));
        HttpResponse response = getStripeAPI(requestUrl, 'Stripe_Get_Payment_Intent_API');
        if(response.getStatusCode() < 200 || response.getStatusCode() > 299){
            throw new StripeAPIException('PaymentIntent Records not received from Stripe : ' + response.getBody());
        }
        StripeGetPaymentIntentWrapper responseWrapper = StripeGetPaymentIntentWrapper.parse(response.getBody());
        Map<String, StripeGetPaymentIntentWrapper.Data_Z> paymentIntentMap = new Map<String, StripeGetPaymentIntentWrapper.Data_Z>();
        Set<String> invoiceSet = new Set<String>();
        for(integer i=0; i < responseWrapper.data.Size(); i++){
            if(!paymentIntentMap.containsKey(responseWrapper.data[i].id) && String.isNotEmpty(responseWrapper.data[i].invoice)){
                paymentIntentMap.put(responseWrapper.data[i].invoice, responseWrapper.data[i]);
            }
        }
        while(responseWrapper.has_more != false){
            if(batchRunDate == null){
                //HttpResponse response = StripeConnection.getInvoice(null, body);
                requestUrl = '/search?query=created>=1665599251&limit=100';
                
            }
            else{
                requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
            }
            requestUrl = requestUrl+'&page='+responseWrapper.next_page;
            response = getStripeAPI(requestUrl, 'Stripe_Get_Payment_Intent_API');
            responseWrapper = StripeGetPaymentIntentWrapper.parse(response.getBody());
            for(integer i=0; i < responseWrapper.data.Size(); i++){
                if(!paymentIntentMap.containsKey(responseWrapper.data[i].id) && String.isNotEmpty(responseWrapper.data[i].invoice)){
                    paymentIntentMap.put(responseWrapper.data[i].invoice, responseWrapper.data[i]);
                }
            }    
        }
        
        return paymentIntentMap;
    }
    
    public static Map<String,StripeGetChargeWrapper.cls_data> getCharge(){
        Stripe_Batch_Setting__c custoSettingVal;
        DateTime batchRunDate;
        String body;
        String requestUrl;
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeInvoiceBatch');
        batchRunDate = custoSettingVal.Last_Run_At__c != null ? custoSettingVal.Last_Run_At__c : null;
        if(batchRunDate == null){
            //HttpResponse response = StripeConnection.getInvoice(null, body);
            requestUrl = '/search?query=created>=1665599251&limit=100';
            
        }
        else{
            requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
        }
        //system.debug(((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000));
        HttpResponse response = getStripeAPI(requestUrl,'Stripe_Get_Charges_API');
        if(response.getStatusCode() < 200 || response.getStatusCode() > 299){
            throw new StripeAPIException('Charges Records not received from Stripe : ' + response.getBody());
        }
        StripeGetChargeWrapper responseWrapper = StripeGetChargeWrapper.parse(response.getBody());
        Map<String, StripeGetChargeWrapper.cls_data> chargeMap = new Map<String, StripeGetChargeWrapper.cls_data>();
        Set<String> PaymentIntentSet = new Set<String>();
        for(integer i=0; i < responseWrapper.data.Size(); i++){
            if(!chargeMap.containsKey(responseWrapper.data[i].id)){
                chargeMap.put(responseWrapper.data[i].id, responseWrapper.data[i]);
            }
        }
        while(responseWrapper.has_more != false){
            if(batchRunDate == null){
                //HttpResponse response = StripeConnection.getInvoice(null, body);
                requestUrl = '/search?query=created>=1665599251&limit=100';
                
            }
            else{
                requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
            }
            requestUrl = requestUrl+'&page='+responseWrapper.next_page;
            response = getStripeAPI(requestUrl, 'Stripe_Get_Charges_API');
            responseWrapper = StripeGetChargeWrapper.parse(response.getBody());
            for(integer i=0; i < responseWrapper.data.Size(); i++){
                if(!chargeMap.containsKey(responseWrapper.data[i].id) && String.isNotEmpty(responseWrapper.data[i].payment_intent)){
                    chargeMap.put(responseWrapper.data[i].payment_intent, responseWrapper.data[i]);
                }
            }    
        }
        return chargeMap;
    }
    
    public static Map<String,String> getCustomer(){
        Stripe_Batch_Setting__c custoSettingVal;
        DateTime batchRunDate;
        String body;
        String requestUrl;
        custoSettingVal =  Stripe_Batch_Setting__c.getInstance('StripeInvoiceBatch');
        batchRunDate = custoSettingVal.Last_Run_At__c != null ? custoSettingVal.Last_Run_At__c : null;
        if(batchRunDate == null){
            //HttpResponse response = StripeConnection.getInvoice(null, body);
            requestUrl = '/search?query=created>=1665599251&limit=100';
            
        }
        else{
            requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
        }
        //system.debug(((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000));
        HttpResponse response = getStripeAPI(requestUrl,'Stripe_Get_Charges_API');
        if(response.getStatusCode() < 200 || response.getStatusCode() > 299){
            throw new StripeAPIException('Charges Records not received from Stripe : ' + response.getBody());
        }
        StripeGetChargeWrapper responseWrapper = StripeGetChargeWrapper.parse(response.getBody());
        Map<String, String> chargeMap = new Map<String, String>();
        for(integer i=0; i < responseWrapper.data.Size(); i++){
            if(!chargeMap.containsKey(responseWrapper.data[i].id)){
                chargeMap.put(responseWrapper.data[i].id, responseWrapper.data[i].customer);
            }
        }
        while(responseWrapper.has_more != false){
            if(batchRunDate == null){
                //HttpResponse response = StripeConnection.getInvoice(null, body);
                requestUrl = '/search?query=created>=1665599251&limit=100';
                
            }
            else{
                requestUrl = '/search?query=created>='+((DateTime.newInstanceGmt(batchRunDate.year(), batchRunDate.month(), batchRunDate.day()).addDays(-1).getTime())/1000)+'&limit=100';
            }
            requestUrl = requestUrl+'&page='+responseWrapper.next_page;
            response = getStripeAPI(requestUrl, 'Stripe_Get_Charges_API');
            responseWrapper = StripeGetChargeWrapper.parse(response.getBody());
            for(integer i=0; i < responseWrapper.data.Size(); i++){
                if(!chargeMap.containsKey(responseWrapper.data[i].id)){
                    chargeMap.put(responseWrapper.data[i].id, responseWrapper.data[i].customer);
                }
            }    
        }
        system.debug(chargeMap.size());
        system.debug(chargeMap);
        return chargeMap;
    }
    
    Public static HttpResponse getStripeAPI(String urlString, String apiName){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Stripe_Config__mdt apiMDT = Stripe_Config__mdt.getInstance(apiName);
        String endPoint = apiMDT.Endpoint__c + urlString;
        request.setEndpoint(endPoint);
        request.setMethod(apiMDT.Method__c); 
        request.setTimeout((integer)apiMDT.Timeout__c);
        Map<String,String> headerMap = getHeaderMap(apiMDT.HeaderParameters__c);
        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                request.setHeader(key, headerMap.get(key));
            }
        }
        if(apiMDT.isActive__c){
            response = http.send(request);   
        }else{
            response.setStatusCode(404);
            response.setBody('Api is not active in the system');
        }
        response = http.send(request);     
        //system.debug(response.getBody());
        return response;
    } 
    
    private static Map<String,String> getHeaderMap(String parameterInfo){
        Map<String, String> parametersMap = new Map<String, String>();
        List<String> parameters = parameterInfo.split('\n');
        for(String urlParam : parameters) {
            List<String> keyValuePair = urlParam.trim().split(':');
            if(!keyValuePair.isEmpty() && keyValuePair.size() == 2) {
                if(String.isNotEmpty(keyValuePair[0]) && String.isNotEmpty(keyValuePair[1])) {
                    parametersMap.put(keyValuePair[0], keyValuePair[1]);
                }
            }
        }
        return parametersMap;
    }
    
    public class StripeAPIException extends Exception {}
}