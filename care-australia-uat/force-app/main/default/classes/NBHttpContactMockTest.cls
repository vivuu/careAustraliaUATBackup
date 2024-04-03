@isTest
public class NBHttpContactMockTest implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req) {  
        HttpResponse res = new HttpResponse();
        return res;
    }
    
    public HTTPRequest request() {  
        HttpRequest req = new HttpRequest();
        return req;
    }
}