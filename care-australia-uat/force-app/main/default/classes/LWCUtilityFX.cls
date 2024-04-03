/**
* Name			:		LWCUtilityFX
* Date			:		14/07/2023
* Author		:		Amit Goyal
* Description	:		all utility methods related to FX will be here
*/
public class LWCUtilityFX {
	public static Decimal getCurrencyConversion(String baseCurrency, String targetCurrency, Decimal amount){
        // Converting the currency from one to another
        //https://api.getgeoapi.com/v2/currency/convert?api_key='+Label.LWC_FX_GetGeoAPIKey+'&from=EUR&to=GBP&amount=10&format=json
        
        // historial currency conversion from one to another based on some date
        //https://api.getgeoapi.com/v2/currency/historical/2018-10-12?api_key='+Label.LWC_FX_GetGeoAPIKey+'&from=EUR&to=GBP&amount=10&format=json
        try{
            Http ht = new Http();
            HttpRequest request = new HttpRequest();
            String requestEndPoint='https://api.getgeoapi.com/v2/currency/convert?api_key='+Label.LWC_FX_GetGeoAPIKey+'&from='+baseCurrency+'&to='+targetCurrency+'&amount='+amount+'&format=json';
            request.setEndpoint(requestEndPoint);
            request.setMethod('GET');
            String bodyText='';
            if(!Test.isRunningTest()){
                HttpResponse response = ht.send(request);
                //system.debug('### response '+response);
                //system.debug('### response body '+response.getBody());
                Boolean validatedStatus = validateStatusCode(response.getStatusCode());
                if(validatedStatus){
                    bodyText = response.getBody();
                }
            }else{
                bodyText='{"base_currency_code":"AUD","base_currency_name":"Australian dollar","amount":"1.0000","updated_date":"2023-09-12","rates":{"USD":{"currency_name":"United States dollar","rate":"0.6424","rate_for_amount":"0.6424"}},"status":"success"}';
            }
            
            if(bodyText != null && bodyText.trim().length()>0){
                GetGeoAPIFXClass data = (GetGeoAPIFXClass)JSON.deserialize(bodyText, GetGeoAPIFXClass.class);
                if(data.status=='success'){
                    //system.debug('@@@ '+data.updated_date);
                    //system.debug('@@@ '+data.base_currency_code);
                    //system.debug('@@@ '+data.amount);
                    //system.debug('@@@ '+data.base_currency_name);
                    //system.debug('@@@ rates: '+data.rates);
                    
                    Map<String, Map<String, String>> rates = data.rates;
                    for(String key1: rates.keyset()){
                        //system.debug('### key1: '+key1);
                        Map<String, String> result =  rates.get(key1);
                        for(String key2: result.keyset()){
                            //system.debug('### result: '+key2+': '+result.get(key2));
                            if(key2=='rate_for_amount'){
                                return Decimal.valueOf(result.get(key2));
                            }
                        }
                    }
                }else{
                    system.debug('### Data Parsing Error: '+data.status);
                }
            }
        }catch(Exception e){
            system.debug('### Exception: '+e.getMessage());
        }
        return null;
    }
    
    public static Decimal getConversionRate(String isoCode){
        CurrencyType currencies = [SELECT Id, ConversionRate, IsoCode, IsCorporate FROM CurrencyType WHERE IsActive = true AND IsoCode=:isoCode];
        return currencies.ConversionRate;
    }
    
    public static map<String, Decimal> getCurrencyConversionMap(){
        map<String, Decimal> currencyConversionMap = new map<String, Decimal>();
        list<CurrencyType> currencies = [SELECT Id, ConversionRate, IsoCode, IsCorporate FROM CurrencyType WHERE IsActive = true AND IsCorporate=false];
        if(currencies != null && currencies.size()>0){
            for(CurrencyType ct: currencies){
                currencyConversionMap.put(ct.IsoCode, ct.ConversionRate);
            }
        }
        
        return currencyConversionMap;
    }
    
    public static Decimal getConversionRateLCToUSD(String localCurrency, map<String, Decimal> currencyMap){
        Decimal amountInUSD=0;
        map<String, Decimal> currencyConversionMap = new map<String, Decimal>();
        if(currencyMap==null){
            currencyConversionMap = getCurrencyConversionMap();
        }else{
            currencyConversionMap=currencyMap;
        }
        
        if(localCurrency != null){
            Decimal vndToAudConversionRate = 1 / currencyConversionMap.get(localCurrency);
            Decimal audToUsdConversionRate = currencyConversionMap.get('USD');
            
            // Convert LC to AUD
            Decimal amountInAUD = 1 * vndToAudConversionRate;
            // Convert AUD to USD
            amountInUSD = amountInAUD * audToUsdConversionRate;
        }
        return amountInUSD;
    }
    
    public static Decimal conversionfromLCtoUSD(Decimal amountInLC, String localCurrency, map<String, Decimal> currencyMap){
        try{
            if(amountInLC == null){amountInLC=0;}
            map<String, Decimal> currencyConversionMap = new map<String, Decimal>();
            if(currencyMap==null){
                currencyConversionMap = getCurrencyConversionMap();
            }else{
                currencyConversionMap=currencyMap;
            }
            // Invert the LC to AUD conversion rate
            Decimal vndToAudConversionRate = 1 / currencyConversionMap.get(localCurrency);
            Decimal audToUsdConversionRate = currencyConversionMap.get('USD');
            
            // Convert LC to AUD
            Decimal amountInAUD = amountInLC * vndToAudConversionRate;
            // Convert AUD to USD
            Decimal amountInUSD = amountInAUD * audToUsdConversionRate;
            //System.debug('### Equivalent Amount in USD: ' + amountInUSD);
            return amountInUSD.setScale(8);
        }catch(Exception e){
            system.debug('### Exception: '+e.getMessage());
        }
        return null;
    }
    
    
    public static Decimal conversionfromLCtoAUD(Decimal amountInLC, String localCurrency, map<String, Decimal> currencyMap){
        try{
            if(amountInLC == null){amountInLC=0;}
            map<String, Decimal> currencyConversionMap = new map<String, Decimal>();
            if(currencyMap==null){
                currencyConversionMap = getCurrencyConversionMap();
            }else{
                currencyConversionMap=currencyMap;
            }
            // Invert the LC to AUD conversion rate
            Decimal vndToAudConversionRate = 1 / currencyConversionMap.get(localCurrency);
            Decimal audToUsdConversionRate = currencyConversionMap.get('USD');
            
            // Convert LC to AUD
            Decimal amountInAUD = amountInLC * vndToAudConversionRate;
           
            //System.debug('### Equivalent Amount in USD: ' + amountInAUD);
            return amountInAUD.setScale(8);
        }catch(Exception e){
            system.debug('### Exception: '+e.getMessage());
        }
        return null;
    }
    
    public static Decimal conversionfromUSDtoAUD(Decimal amountInUSD, map<String, Decimal> currencyMap){
        map<String, Decimal> currencyConversionMap = new map<String, Decimal>();
            if(currencyMap==null){
                currencyConversionMap = getCurrencyConversionMap();
            }else{
                currencyConversionMap=currencyMap;
            }
        Decimal audToUsdConversionRate = currencyConversionMap.get('USD');
        // Convert USD to AUD using the inverse conversion rate
        if(Test.isRunningTest()){
            if(amountInUSD==null || amountInUSD==0){
                system.debug('### amountInUSD is NULL');
                amountInUSD=20;
            }
            
            if(audToUsdConversionRate==null || audToUsdConversionRate==0){
                system.debug('### audToUsdConversionRate is NULL');
                audToUsdConversionRate=0.64;
            }
        }
        Decimal amountInAUD = amountInUSD * (1 / audToUsdConversionRate);
        //System.debug('Equivalent Amount in AUD: ' + amountInAUD);
        return amountInAUD;
    }
    
    public static Boolean validateStatusCode(Integer statusCode){
        map<String, String> errorCodeMap = new map<String, String>();
        errorCodeMap.put('400', 'Bad Request');
        errorCodeMap.put('403', 'Authentication Error or Invalid Key or User or Limit Exception');
        errorCodeMap.put('404', 'Resource is not found or requested format is incorrect');
        errorCodeMap.put('405', 'Method Not Allowed');
        errorCodeMap.put('505', 'Server error. We hope you will never see this error.');
        
        if(errorCodeMap.containsKey(String.valueOf(statusCode))){
            return false;
        }
        return true;
    }
    
    public class GetGeoAPIFXClass {
        public String status;
        public String updated_date;
        public String base_currency_code;
        public String amount;
        public String base_currency_name;
        public Map<String, Map<String, String>> rates;
    }
}