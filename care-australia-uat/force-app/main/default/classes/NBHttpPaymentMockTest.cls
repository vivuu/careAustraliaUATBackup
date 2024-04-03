@isTest
public class NBHttpPaymentMockTest implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req) {  
        HttpResponse res = new HttpResponse();
        return res;
    }
}