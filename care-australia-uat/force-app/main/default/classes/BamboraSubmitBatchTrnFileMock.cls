global class BamboraSubmitBatchTrnFileMock implements HttpCalloutMock  {
    
    protected Integer StatusCode = 200;
    protected Integer ResponseCode = 0;
    public BamboraSubmitBatchTrnFileMock (Integer StatusCode,Integer ResponseCode) {
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
        }else if(ResponseCode == 1){
            //responseXML = responceXML_1();
            
        }else if(ResponseCode == 4){
            //responseXML = responceXML_4();
            
        }else{
            responseXML = '<?xml version="1.0" encoding="utf-8"?>';
            responseXML += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
            responseXML += '<soap:Body>';
            responseXML += '<SubmitBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
            responseXML += '<SubmitBatchTrnFileResult>';
            responseXML += '<resultSummary>8</resultSummary>';
            responseXML += '<resultMessage>Batch number already exists</resultMessage>';
            responseXML += '<uniqueBatchIdentifier />';
            responseXML += '</SubmitBatchTrnFileResult>';
            responseXML += '</SubmitBatchTrnFileResponse>';
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
            responseXML += '<SubmitBatchTrnFileResponse xmlns="http://www.ippayments.com.au/interface/api/batch">';
            responseXML += '<SubmitBatchTrnFileResult>';
            responseXML += '<resultSummary>0</resultSummary>';
            responseXML += '<resultMessage>File received and all checks passed</resultMessage>';
            responseXML += '<uniqueBatchIdentifier>00087654</uniqueBatchIdentifier>';
            responseXML += '</SubmitBatchTrnFileResult>';
            responseXML += '</SubmitBatchTrnFileResponse>';
            responseXML += '</soap:Body>';
            responseXML += '</soap:Envelope>';
        return responseXML;
        
    }
}