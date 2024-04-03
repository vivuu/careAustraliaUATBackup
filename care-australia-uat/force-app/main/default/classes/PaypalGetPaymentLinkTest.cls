@isTest
public class PaypalGetPaymentLinkTest {
    @isTest
    public static void testGetContactForGuest() {
        Contact testContact = new Contact(lastName = 'LWC Guest Lender');
        insert testContact;
        
        Test.startTest();
        Contact result = PaypalGetPaymentLink.getContactForGuest();
        Test.stopTest();
        
        System.assertEquals(testContact.Id, result.Id);
    }
        public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "MockAccessToken"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void testGetAccessToken() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String accessToken = PaypalGetPaymentLink.getAccessToken();
      
        System.assertEquals('MockAccessToken', accessToken);
    }
       public class MockHttpResponseGenerators implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "78R76055XP188513E", "status": "PAYER_ACTION_REQUIRED", "payment_source": {"paypal": {}}, "links": [{"href": "https://api.sandbox.paypal.com/v2/checkout/orders/78R76055XP188513E", "rel": "self", "method": "GET"}, {"href": "https://www.sandbox.paypal.com/checkoutnow?token=78R76055XP188513E", "rel": "payer-action", "method": "GET"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
        @isTest
    public static void testGetPaypalPaymentLinks() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PaypalGetPaymentLink.MyJsonWrapper payment = new PaypalGetPaymentLink.MyJsonWrapper();
        payment.successPageUrl = 'YourSuccessPageUrlHere';
        payment.returnPageUrl = 'YourReturnPageUrlHere';
        payment.accesstoken = 'YourAccessTokenHere';
        payment.refid = 'YourRefIdHere';
        payment.amount = 'YourAmountHere';
        String payerActionHref = PaypalGetPaymentLink.getPaypalPaymentLink(payment);
        System.assertEquals(null, payerActionHref);
    }

        public class MockHttpResponseCapturePayPalOrder implements HttpCalloutMock 
        {
        public HTTPResponse respond(HTTPRequest req) 
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); // Start the root object
            gen.writeStringField('id', '4PD75263NL851822J');
            gen.writeStringField('status', 'COMPLETED');
            gen.writeFieldName('payment_source');
            gen.writeStartObject();
            gen.writeFieldName('paypal');
            gen.writeStartObject();
            gen.writeStringField('email_address', 'sb-8ydrr25894864@personal.example.com');
            gen.writeStringField('account_id', 'ZGTX35P25KMK6');
            gen.writeStringField('account_status', 'VERIFIED');
            gen.writeFieldName('name');
            gen.writeStartObject();
            gen.writeStringField('given_name', 'John');
            gen.writeStringField('surname', 'Doe');
            gen.writeEndObject(); 
            gen.writeFieldName('address');
            gen.writeStartObject();
            gen.writeStringField('country_code', 'AU');
            gen.writeEndObject(); 
            gen.writeEndObject();
            gen.writeEndObject(); 
            gen.writeFieldName('purchase_units');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('reference_id', '0039D00000WOKVUQA5');
            gen.writeFieldName('shipping');
            gen.writeStartObject();
            gen.writeFieldName('name');
            gen.writeStartObject();
            gen.writeStringField('full_name', 'John Doe');
            gen.writeEndObject(); 
            gen.writeFieldName('address');
            gen.writeStartObject();
            gen.writeStringField('address_line_1', '1 Cheeseman Ave Brighton East');
            gen.writeStringField('admin_area_2', 'Melbourne');
            gen.writeStringField('admin_area_1', 'Victoria');
            gen.writeStringField('postal_code', '3001');
            gen.writeStringField('country_code', 'AU');
            gen.writeEndObject();
            gen.writeEndObject(); 
            gen.writeFieldName('payments');
            gen.writeStartObject();
            gen.writeFieldName('captures');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('id', '78P99882N71579912');
            gen.writeStringField('status', 'COMPLETED');
            gen.writeFieldName('amount');
            gen.writeStartObject();
            gen.writeStringField('currency_code', 'AUD');
            gen.writeStringField('value', '28.75');
            gen.writeEndObject(); 
            gen.writeEndObject();
            gen.writeEndArray(); 
            gen.writeEndObject(); 
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(gen.getAsString());
            res.setStatusCode(201);

            return res;
        }
    }
    @isTest
    public static void testCapturePayPalOrder() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCapturePayPalOrder());
        String accessToken = 'YourAccessTokenHere'; 
        String orderId = 'YourOrderIdHere'; 
        PaypalGetPaymentLink.PaymentCapture capture = PaypalGetPaymentLink.capturePayPalOrder(accessToken, orderId);
        System.assertEquals('COMPLETED', capture.status);
    }
}