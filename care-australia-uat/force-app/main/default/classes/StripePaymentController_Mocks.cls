global class StripePaymentController_Mocks {
    global class PostStripeChargeSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "ch_503as6asdas"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class PostStripePaymentIntentSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "pi_503as6asdas"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class PostStripeError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": { "message": "error" } }');
            res.setStatusCode(503);
            return res;
        }
    }
}