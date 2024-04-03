global class LWC_UpdateConversionRateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    Static Integer i = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String Query = 'SELECT Id, ConversionRate, IsoCode, IsCorporate FROM CurrencyType WHERE IsActive = true';
        if( Test.isRunningTest() ){
            Query+=' AND IsoCode != \'AUD\'  LIMIT 1';
        }
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<CurrencyType> currencies) {
        changeCurrency( currencies );
    }
    void changeCurrency( list<CurrencyType> currencies ){
        try{
            i++;
            String baseCurrency='AUD';
            map<String, CurrencyType> dcrMap = new map<String, CurrencyType>();
            for(CurrencyType ct: currencies){
                if(ct.IsCorporate){
                    baseCurrency=ct.IsoCode;
                }
            }
            
            map<String, CurrencyType> ctMap = new map<String, CurrencyType>();
            for(CurrencyType ct: currencies){
                if(!ct.IsCorporate){
                    // Get updated currency conversion rate.
                    Decimal newConversionRate = LWCUtilityFX.getCurrencyConversion(baseCurrency, ct.IsoCode, 1);
                    String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
                    string sessionId = UserInfo.getOrganizationId()+''+UserInfo.getSessionId().substring(15);
                    String endpoint = instanceUrl+'/services/data/v48.0/sobjects/CurrencyType/' + ct.Id+'?_HttpMethod=PATCH';
                    Map<String, Object> conversionRateData = new Map<String, Object>{'ConversionRate' => newConversionRate};
                        // Serialize the data to JSON
                        String jsonData = JSON.serialize(conversionRateData);
                    // Make the PATCH request
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('POST');
                    request.setHeader('Authorization', 'Bearer ' + sessionId);
                    request.setHeader('Content-Type', 'application/json');
                    request.setBody(jsonData);
                    HttpResponse response = new Http().send(request);
                    
                    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                        System.debug('DatedConversionRate record updated successfully.');
                    } else {
                        System.debug('An error occurred while updating DatedConversionRate record: ' + response.getBody()+' Retrying');
                        if(i<10)
                        changeCurrency( currencies );
                    }
                }
            }
        }catch(Exception ex){
            system.debug('### Fatal Error: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            String e = ex.getStackTraceString();
            if( e!=null && e.length() > 254 )	e = e.substring(0,254); 
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_UpdateConversionRateQueuable', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=e);
            //insert err;
            if(i<10)
            changeCurrency( currencies );
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}