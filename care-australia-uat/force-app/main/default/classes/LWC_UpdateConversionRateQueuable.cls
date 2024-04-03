/**
* Name          :       LWC_UpdateConversionRateQueuable
* Date          :       29/08/2023
* Author        :       Amit Goyal
* Description   :       Run at 1:00 Daily to update the FX Rate
*/
public class LWC_UpdateConversionRateQueuable implements Queueable, Database.AllowsCallouts{
    Set<String> currencies = new Set<String>();
    public LWC_UpdateConversionRateQueuable( Set<String> curr ){
        currencies = curr;
    }
    public void execute(QueueableContext context) {
        try{
            String baseCurrency='AUD';
            list<CurrencyType> currencies = [SELECT Id, ConversionRate, IsoCode, IsCorporate FROM CurrencyType WHERE IsActive = true AND IsoCode IN :currencies];
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
                    String endpoint = instanceUrl+'/services/data/v48.0/sobjects/CurrencyType/' + ct.Id;
                    Map<String, Object> conversionRateData = new Map<String, Object>{'ConversionRate' => newConversionRate};
                        // Serialize the data to JSON
                        String jsonData = JSON.serialize(conversionRateData);
                    // Make the PATCH request
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('PATCH');
                    request.setHeader('Authorization', 'Bearer ' + sessionId);
                    request.setHeader('Content-Type', 'application/json');
                    request.setBody(jsonData);
                    HttpResponse response = new Http().send(request);
                    
                    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                        System.debug('DatedConversionRate record updated successfully.');
                    } else {
                        System.debug('An error occurred while updating DatedConversionRate record: ' + response.getBody());
                    }
                }
            }
        }catch(Exception ex){
            system.debug('### Fatal Error: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_UpdateConversionRateQueuable', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=ex.getStackTraceString());
            insert err;
        }
    }
}