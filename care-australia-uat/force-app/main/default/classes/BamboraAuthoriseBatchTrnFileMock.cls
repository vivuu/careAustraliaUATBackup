global class BamboraAuthoriseBatchTrnFileMock implements HttpCalloutMock  {
    
    protected Integer StatusCode = 200;
    protected Integer ResponseCode = 0;
    public BamboraAuthoriseBatchTrnFileMock (Integer StatusCode,Integer ResponseCode) {
        this.StatusCode = StatusCode;
        this.ResponseCode = ResponseCode;
        
    }
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response.
        // Set response values, and 
        // return response.
        System.assertEquals('https://demo.ippayments.com.au/interface/api/batch.asmx', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        String responseXML ;
        if(ResponseCode == 0){         
            responseXML = responceXML_0();  
        }else if(ResponseCode ==1){  
            responseXML = responceXML_1(); 
        }else if(ResponseCode ==2){
            responseXML = responceXML_2(); 
        }else if(ResponseCode ==3){  
            responseXML = responceXML_3(); 
        }else if(ResponseCode ==4){
            responseXML = responceXML_4(); 
        }
        else if(ResponseCode ==5){  
            responseXML = responceXML_5(); 
        }else if(ResponseCode ==99){
            responseXML = responceXML_99(); 
        }
        else{
            responseXML = '<?xml version="1.0" encoding="utf-8"?>';
            responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
            responseXML += '<soap:Body>';
            responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
            responseXML += '<AuthoriseBatchTrnFileResult>50</AuthoriseBatchTrnFileResult>';
            responseXML += '</AuthoriseBatchTrnFileResponse>';
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
        responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
        responseXML += '<AuthoriseBatchTrnFileResult>0</AuthoriseBatchTrnFileResult>';
        responseXML += '</AuthoriseBatchTrnFileResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    public String responceXML_1(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
        responseXML += '<AuthoriseBatchTrnFileResult>1</AuthoriseBatchTrnFileResult>';
        responseXML += '</AuthoriseBatchTrnFileResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    public String responceXML_2(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
        responseXML += '<AuthoriseBatchTrnFileResult>2</AuthoriseBatchTrnFileResult>';
        responseXML += '</AuthoriseBatchTrnFileResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    public String responceXML_3(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
        responseXML += '<AuthoriseBatchTrnFileResult>3</AuthoriseBatchTrnFileResult>';
        responseXML += '</AuthoriseBatchTrnFileResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    public String responceXML_4(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
        responseXML += '<AuthoriseBatchTrnFileResult>4</AuthoriseBatchTrnFileResult>';
        responseXML += '</AuthoriseBatchTrnFileResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    public String responceXML_5(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
        responseXML += '<AuthoriseBatchTrnFileResult>5</AuthoriseBatchTrnFileResult>';
        responseXML += '</AuthoriseBatchTrnFileResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
    public String responceXML_99(){
        String  responseXML = '<?xml version="1.0" encoding="utf-8"?>';
        responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        responseXML += '<soap:Body>';
        responseXML += '<AuthoriseBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
        responseXML += '<AuthoriseBatchTrnFileResult>99</AuthoriseBatchTrnFileResult>';
        responseXML += '</AuthoriseBatchTrnFileResponse>';
        responseXML += '</soap:Body>';
        responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
}