/**
 * Class Name: StripeSubscriptionBatchHandler
 * Auhtor: Gerent Team
 * Description: sync recurring donation with subscription in stripe
 * Related objects: Contact, Campaigns, RD
 * the Stripe to SFDC Integration
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */
public class StripeSubscriptionBatchHandler {    
    /**
     * Method Name:		createSubscrition
     * Description:		Create subscription for immediate RD's
     * Parameter Details:
     * 		stripe_Customer_Id:
     * 		amount:
     * 		recurringType:
     * 		startDate:
     * 		installments:
     * 		productId:
     * 		installment_Period:
     * 		rd_Id:
     * 		day_Of_Month:
     * 		subscription_Id:
     */
    public static String createSubscrition(String rd_Id, String stripe_Customer_Id,Decimal amount,Decimal installmentFrequency, 
                                           String installmentPeriod, String recurringType,Date startDate,Decimal installments,
        String productId, String installment_Period,String day_Of_Month, String subscription_Id, String status, String paymentMethodId){
            // this method is getting called from StripeSubscriptionBatch, StripeAddUpdateCConRD and StripeAddUpdateDDonRD class
            try{
                system.debug(status);
                system.debug(subscription_Id);
                String responseId;
                String body = '';
                EndDateDetailsWrapper responseDateDetails = calculateEndDate(recurringType,(Integer)installments, installmentPeriod, (Integer)installmentFrequency, installment_Period, day_Of_Month, startDate);
                system.debug(responseDateDetails);
                if(String.isEmpty(subscription_Id)){
                    body = '&customer='+stripe_Customer_Id;  
                    if(responseDateDetails.startDate != null && responseDateDetails.startDate.date() > Date.today()){
                        body += '&billing_cycle_anchor='+((responseDateDetails.startDate.getTime())/1000);
                    }
                    if(responseDateDetails.interval != null){
                        body += '&items[0][price_data][recurring][interval]='+ responseDateDetails.interval;
                    }
                    if(responseDateDetails.intervalCount != null){
                        body += '&items[0][price_data][recurring][interval_count]='+responseDateDetails.intervalCount;
                    }
                    body += '&items[0][price_data][currency]=AUD';
                    body += '&items[0][price_data][product]='+productId;
                    body += '&items[0][price_data][unit_amount]=1';
                    body += '&items[0][quantity]='+(integer)(amount*100);
                    if(status != 'Active'){
                        body += '&payment_behavior=default_incomplete';
                    }
                }
            	else{
                    body += '&quantity='+(integer)(amount*100);
                    if(status == 'Active'){
                        body += '&pause_collection=';
                    }
                }
                
                //system.debug('### '+rd.npe03__Installment_Period__c );
                if(String.isNotBlank(paymentMethodId)){
                    body += '&default_payment_method='+paymentMethodId;
                }
                if(responseDateDetails.endDate != null){
                    body += '&cancel_at=' + (responseDateDetails.endDate.getTime()/1000);
                }
                
                body += '&metadata[salesforce_rd_id]='+rd_Id;
                body += '&proration_behavior=none';
                if(status == 'Cancelled'){
                    body += '&cancel_at_period_end=true';
                }
                else if(status == 'Paused'){
                    body += '&pause_collection[behavior]=mark_uncollectible';
                }
                System.debug( paymentMethodId );
                system.debug('Subscription Body:'+body);
                HttpResponse response;
                if(!String.isEmpty(subscription_Id)){
                    response = StripeConnection.postSubscription(subscription_Id, body);
                    if(response.getStatusCode() < 200 || response.getStatusCode() > 299){
                        //throw new StripeAPIException('Subscription Not Created in Stripe : ('+ rd_Id + ') : ' + response.getStatus());
                    }
                }
                else{
                    response = StripeConnection.postSubscription(null, body);
                    if(response.getStatusCode() < 200 || response.getStatusCode() > 299){
                        //ApexLogCreator.createApexLog('StripeSubscriptionBatchHandler', response.getBody(), 'StripeSubscriptionBatchHandler', response.getStatus());
                    }
                }
                system.debug(response.getBody());    
                if(response != null){
                    responseId = getResponseData(response.getBody());
                }
                return responseId;
            }catch(Exception e){
                //Error Logging
                system.debug('### Exception: '+e.getMessage());
                //ApexLogCreator.createApexLog('StripeSubscriptionBatchHandler', e.getMessage(), 'StripeSubscriptionBatchHandler', e.getStackTraceString());
            }
        return null;
    } 
    
    /**
     * Method Name:		createProduct
     * Description:		Create product in stripe for campaigns
     * Parameter Details:
     * 		campaignName: product name in stripe
     */
    public static String createProduct(String campaignName, String campaignId){
        try{
            String body = '';
            body += 'name='+campaignName;
            body += '&active=true';
            body += '&metadata[sf_product_id] = '+campaignId;
            HttpResponse response = StripeConnection.postProduct(null, body);
            if(response.getStatusCode() < 200 || response.getStatusCode() > 299){
                //throw new StripeAPIException('Product Not Created in Stripe : ('+ campaignId + ') : ' + response.getStatus());
            }
            system.debug('### response: '+response);
            //response = JSON.serializePretty( JSON.deserializeUntyped(response.getBody()));
            
            //response = JSON.serializePretty( JSON.deserializeUntyped(respos.getBody()));
            String id = getResponseData(response.getBody());
            /*while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        }
                    }
                }
            }*/
            system.debug('ID +++ '+id);
            return id;
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            //ApexLogCreator.createApexLog('StripeSubscriptionBatchHandler', e.getMessage(), 'StripeSubscriptionBatchHandler', e.getStackTraceString());
        }
        return null;
    }
    
    /**
     * Method Name:		createPrice
     * Description:		Create price in stripe for product / campaigns, will be used to create subscription
     * Parameter Details:
     * 		productId: product id from stripe, reuired to create price for the product
     */
   /* public static void createPrice(String productId){
        try{
            String body = '';
            body += 'currency=aud';
            body += '&product='+productId;
            body += '&unit_amount=1000';
            body += '&recurring[interval]=month';
            HttpResponse response = StripeConnection.postPrice(null, body);
        }catch(Exception e){
            // Error Logging
            system.debug('### Exception: '+e.getMessage());
            ApexLogCreator.createApexLog('StripeSubscriptionBatchHandler', e.getMessage(), 'StripeSubscriptionBatchHandler', e.getStackTraceString());
        }
    }*/
 
    
    public static String getResponseData(String response){
        //response = JSON.serializePretty( JSON.deserializeUntyped(response.getBody()));
       	StripeCustomerBatchHandler.ResponseWrapper rw = (StripeCustomerBatchHandler.ResponseWrapper) System.JSON.deserialize (response, StripeCustomerBatchHandler.ResponseWrapper.class);
		        
        //response = JSON.serializePretty( JSON.deserializeUntyped(respos.getBody()));
        String id = rw.id;
       	
        system.debug('ID +++ '+id);
        return id;
    }
    
    /**
     * Method Name:		calculateEndDate
     * Description:		Calculate EndDate for the subscription
     * Parameter Details:
     * 		recurringType: 
     * 		numberOfPlannedInstallments: 
     * 		every: 
     * 		installmentPeriod: 
     * 		dateOfMonth: 
     * 		effectiveDate: 
     */
    public static EndDateDetailsWrapper calculateEndDate(String recurringType, Integer numberOfPlannedInstallments, 
                                        String recurringPeriod, Integer every, String installmentPeriod, 
                                        String stringDateOfMonth, Date effectiveDate){
        try{
            System.debug(recurringType + ' ' + numberOfPlannedInstallments + ' ' + recurringPeriod + ' ' + every + ' ' + installmentPeriod + ' ' + stringDateOfMonth + ' '  + effectiveDate );
            DateTime endDate;
            DateTime startDate;
            Integer dateOfMonth;
            if(!String.isEmpty(stringDateOfMonth)){
                dateOfMonth = Integer.valueOf(stringDateOfMonth);
            }
            if(recurringType == 'Fixed' && effectiveDate != null){
                endDate = createDateTime(effectiveDate);
                startDate = createDateTime(effectiveDate);
                if(numberOfPlannedInstallments != null){           
                    Integer duration = numberOfPlannedInstallments;
                    if(every != null){
                        duration = numberOfPlannedInstallments*every;
                    }
                    if(installmentPeriod == 'Monthly'){
                        if(every != null){
                            if(dateOfMonth < startDate.day()){
                                startDate = startDate.addMonths(1);
                                startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                                endDate = startDate.addMonths(duration);
                                return new EndDateDetailsWrapper(endDate, startDate, 'month', every);
                            }
                            else{
                                startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                                endDate = startDate.addMonths(duration);
                                return new EndDateDetailsWrapper(endDate, startDate, 'month', every);
                            }
                        }
                        else{
                            if(dateOfMonth < startDate.day()){
                                startDate = startDate.addMonths(1);
                                startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                                endDate = startDate.addMonths(duration);
                                return new EndDateDetailsWrapper(endDate, startDate, 'month', 1);
                            }
                            else{
                                startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                                endDate = startDate.addMonths(duration);
                                return new EndDateDetailsWrapper(endDate, startDate, 'month', 1);
                            }
                        }
                    }
                    else if(installmentPeriod == 'Yearly'){
                        if(every != null){
                            endDate = endDate.addYears(duration);
                            return new EndDateDetailsWrapper(endDate, startDate, 'year', every);
                        }
                        else{
                            endDate = endDate.addYears(duration);
                            return new EndDateDetailsWrapper(endDate, startDate, 'year', 1);
                        }
                    }
                    else if(installmentPeriod == 'Quarterly'){
                        if(every != null){
                            duration = duration*3;
                            endDate = endDate.addMonths(duration);
                            return new EndDateDetailsWrapper(endDate, startDate, 'month', every*3);
                        }
                        else{
                            duration = duration*3;
                            endDate = endDate.addMonths(duration);
                            return new EndDateDetailsWrapper(endDate, startDate, 'month', 1*3);
                        }
                    }
                    else if(installmentPeriod == 'Weekly'){
                            if(every != null){
                                duration = duration*7;
                                endDate = endDate.addDays(duration);
                                return new EndDateDetailsWrapper(endDate, startDate, 'week', every);
                            }
                            else{
                                duration = duration*7;
                                endDate = endDate.addDays(duration);
                                return new EndDateDetailsWrapper(endDate, startDate, 'week', 1);
                            }
                        }
                }
                else{
                    //create error object
                    //system.debug('### Exception: '+e.getMessage());
                    //ApexLogCreator.createApexLog('StripeSubscriptionBatchHandler', 'Missing Number of Planned installments', 'StripeCustomerBatchHandler', 'Missing Number of Planned installments');
                }
            }
            else if(recurringType == 'Open' && effectiveDate != null){
                startDate = createDateTime(effectiveDate);
                system.debug('tets');
                if(installmentPeriod == 'Monthly'){
                    if(every != null){
                        if(dateOfMonth < startDate.day()){
                            startDate = startDate.addMonths(1);
                            startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                            return new EndDateDetailsWrapper(null, startDate, 'month', every);
                        }
                        else{
                            startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                            return new EndDateDetailsWrapper(null, startDate, 'month', every);
                        }
                    }
                    else{
                        if(dateOfMonth < startDate.day()){
                            startDate = startDate.addMonths(1);
                            startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                            return new EndDateDetailsWrapper(null, startDate, 'month', 1);
                        }
                        else{
                            startDate = DateTime.newInstanceGmt(startDate.year(), startDate.month(), dateOfMonth);
                            return new EndDateDetailsWrapper(null, startDate, 'month', 1);
                        }
                    }
                }
                else if(installmentPeriod == 'Yearly'){
                    if(every != null){
                        return new EndDateDetailsWrapper(null, startDate, 'year', every);
                    }
                    else{
                        return new EndDateDetailsWrapper(null, startDate, 'year', 1);
                    }
                }
                else if(installmentPeriod == 'Quarterly'){
                    if(every != null){
                        return new EndDateDetailsWrapper(null, startDate, 'month', every*3);
                    }
                    else{
                        return new EndDateDetailsWrapper(null, startDate, 'month', 1*3);
                    }
                }
                else if(installmentPeriod == 'Weekly'){
                    if(every != null){
                        return new EndDateDetailsWrapper(null, startDate, 'week', every);
                    }
                    else{
                        return new EndDateDetailsWrapper(null, startDate, 'week', 1);
                    }
                }
            }
            else{
                //system.debug('### Exception: '+e.getMessage());
            }
            return null;
        }
		catch(exception e){
            system.debug(e.getMessage());
            //ApexLogCreator.createApexLog('StripeSubscriptionBatchHandler', e.getMessage(), 'StripeCustomerBatchHandler', e.getStackTraceString());
        }
        return null;
    }
    
   	 /**
     * Class Name:		EndDateDetailsWrapper
     * Description:		Wrapper for Stripe Attribute
     * Parameter Details:
     * 		endDate: endDate for stripe Subscription
     * 		interval: Duration 'Month, Week, Year'
     * 		intervalCount: Gap between the duration
     */
    
    public class EndDateDetailsWrapper{
        public DateTime endDate {get; set;}
        public DateTIme startDate {get; set;}
        public String interval {get; set;}
        public Integer intervalCount {get; set;}
        
        public EndDateDetailsWrapper(DateTime endDate, DateTime startDate, String interval, Integer intervalCount){
            this.endDate = endDate;
            this.startDate = startDate;
            this.interval = interval;
            this.intervalCount = intervalCount;
        }
    }
    
     /**
     * Method Name:		createDateTime
     * Description:		convert date to datetime
     * Parameter Details:
     * 		conDate: date attribute to convert in DateTime
     */
    
    public static datetime createDateTime(date conDate){
        Datetime convertedDT = datetime.newInstanceGmt(conDate.year(), conDate.month(), conDate.day());
    	return convertedDt;
	}
    
    public class StripeAPIException extends Exception {}
}