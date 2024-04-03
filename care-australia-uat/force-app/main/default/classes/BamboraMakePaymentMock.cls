global class BamboraMakePaymentMock implements HttpCalloutMock  {
    
    protected Integer StatusCode = 200;
    protected Integer ResponseCode = 0;
    public BamboraMakePaymentMock (Integer StatusCode,Integer ResponseCode) {
        this.StatusCode = StatusCode;
        this.ResponseCode = ResponseCode;
        
    }
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        System.assertEquals('https://demo.ippayments.com.au/interface/api/dts.asmx', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        String responseXML ;
        if(ResponseCode == 0){         
            responseXML = responceXML_0();
        }else if(ResponseCode == 500){
            responseXML = responceXML_500();
            
        }else if(ResponseCode == 4){
            //responseXML = responceXML_4();
            
        }else{
            responseXML = '<?xml version="1.0" encoding="utf-8"?>';
            responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
            responseXML += '<soap:Body>';
            responseXML += '<SubmitSinglePaymentResponse xmlns="http://www.ippayments.com.au/interface/api/dts">';
            responseXML += '<SubmitSinglePaymentResult>&lt;Response&gt;';
            responseXML += '&lt;ResponseCode&gt;1&lt;/ResponseCode&gt;';
            responseXML += '&lt;Timestamp&gt;20-Sep-2021 01:35:54&lt;/Timestamp&gt;';
            responseXML += '&lt;Receipt&gt;&lt;/Receipt&gt;';
            responseXML += '&lt;SettlementDate&gt;&lt;/SettlementDate&gt;';
            responseXML += '&lt;DeclinedCode&gt;12&lt;/DeclinedCode&gt;';
            responseXML += '&lt;DeclinedMessage&gt;Invalid Transaction&lt;/DeclinedMessage&gt;';
            responseXML += '&lt;/Response&gt;';
            responseXML += '</SubmitSinglePaymentResult>';
            responseXML += '</SubmitSinglePaymentResponse>';
            responseXML += '</soap:Body>';
            responseXML += '</soap:Envelope>';
        }
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setBody(responseXML);
        res.setStatusCode(StatusCode);
        return res;
    }
    
    public String responceXML_0(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<SubmitSinglePaymentResponse xmlns="http://www.ippayments.com.au/interface/api/dts">';
        responseXML += '<SubmitSinglePaymentResult>&lt;Response&gt;';
        responseXML += '&lt;ResponseCode&gt;0&lt;/ResponseCode&gt;';
        responseXML += '&lt;Timestamp&gt;20-Sep-2021 01:38:31&lt;/Timestamp&gt;';
        responseXML += '&lt;Receipt&gt;21280614&lt;/Receipt&gt;';
        responseXML += '&lt;SettlementDate&gt;20-Sep-2021&lt;/SettlementDate&gt;';
        responseXML += '&lt;DeclinedCode&gt;&lt;/DeclinedCode&gt;';
        responseXML += '&lt;DeclinedMessage&gt;&lt;/DeclinedMessage&gt;';
        responseXML += '&lt;/Response&gt;';
        responseXML += '</SubmitSinglePaymentResult>';
        responseXML += '</SubmitSinglePaymentResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    public String responceXML_500(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
            responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
            responseXML += '<soap:Body>';
            responseXML += '<SubmitSinglePaymentResponse xmlns="http://www.ippayments.com.au/interface/api/dts">';
            responseXML += '<SubmitSinglePaymentResult>&lt;Response&gt;';
            responseXML += '&lt;ResponseCode&gt;1&lt;/ResponseCode&gt;';
            responseXML += '&lt;Timestamp&gt;20-Sep-2021 01:35:54&lt;/Timestamp&gt;';
            responseXML += '&lt;Receipt&gt;&lt;/Receipt&gt;';
            responseXML += '&lt;SettlementDate&gt;&lt;/SettlementDate&gt;';
            responseXML += '&lt;DeclinedCode&gt;500&lt;/DeclinedCode&gt;';
            responseXML += '&lt;DeclinedMessage&gt;Batch Record Exception&lt;/DeclinedMessage&gt;';
            responseXML += '&lt;/Response&gt;';
            responseXML += '</SubmitSinglePaymentResult>';
            responseXML += '</SubmitSinglePaymentResponse>';
            responseXML += '</soap:Body>';
            responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    /*public String responceXML_4(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<TokeniseCreditCardResponse xmlns="http://www.ippayments.com.au/interface/api/sipp">';
        responseXML += '<TokeniseCreditCardResult>&lt;TokeniseCreditCardResponse&gt;';
        responseXML += '&lt;ReturnValue&gt;4&lt;/ReturnValue&gt;';
        responseXML += '&lt;Token&gt;&lt;/Token&gt;';
        responseXML += '&lt;/TokeniseCreditCardResponse&gt;</TokeniseCreditCardResult>';
        responseXML += '</TokeniseCreditCardResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
    }
    public String responceXML_1(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<TokeniseCreditCardResponse xmlns="http://www.ippayments.com.au/interface/api/sipp">';
        responseXML += '<TokeniseCreditCardResult>&lt;TokeniseCreditCardResponse&gt;';
        responseXML += '&lt;ReturnValue&gt;1&lt;/ReturnValue&gt;';
        responseXML += '&lt;Token&gt;&lt;/Token&gt;';
        responseXML += '&lt;/TokeniseCreditCardResponse&gt;</TokeniseCreditCardResult>';
        responseXML += '</TokeniseCreditCardResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
    }*/
}