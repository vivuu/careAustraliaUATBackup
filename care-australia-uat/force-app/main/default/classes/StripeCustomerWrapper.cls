public class StripeCustomerWrapper {

    public String id {get;set;} 
    public String object_Z {get;set;} // in json: object
    public String api_version {get;set;} 
    public Integer created {get;set;} 
    public Data data {get;set;} 
    public Boolean livemode {get;set;} 
    public Integer pending_webhooks {get;set;} 
    public Request request {get;set;} 
    public String type {get;set;} 

    public StripeCustomerWrapper(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'id') {
                        id = parser.getText();
                    } else if (text == 'object') {
                        object_Z = parser.getText();
                    } else if (text == 'api_version') {
                        api_version = parser.getText();
                    } else if (text == 'created') {
                        created = parser.getIntegerValue();
                    } else if (text == 'data') {
                        data = new Data(parser);
                    } else if (text == 'livemode') {
                        livemode = parser.getBooleanValue();
                    } else if (text == 'pending_webhooks') {
                        pending_webhooks = parser.getIntegerValue();
                    } else if (text == 'type') {
                        type = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Object_Z {
        public String id {get;set;} 
        public String object_Z {get;set;} // in json: object 
        public Integer balance {get;set;} 
        public Integer created {get;set;} 
        public String currency_Z {get;set;} // in json: currency        public Boolean delinquent {get;set;} 
        public String description {get;set;} 
        public String email {get;set;} 
        public String invoice_prefix {get;set;} 
        public Boolean livemode {get;set;} 
        public Metadata metadata {get;set;} 
        public String name {get;set;} 
        public Integer next_invoice_sequence {get;set;} 
        public String phone {get;set;} 
        public List<String> preferred_locales {get;set;} 
        public String tax_exempt {get;set;}

        public Object_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'object') {
                            object_Z = parser.getText();
                        } else if (text == 'balance') {
                            balance = parser.getIntegerValue();
                        } else if (text == 'created') {
                            created = parser.getIntegerValue();
                        } else if (text == 'currency') {
                            currency_Z = parser.getText();
                        } else if (text == 'description') {
                            description = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'invoice_prefix') {
                            invoice_prefix = parser.getText();
                        } else if (text == 'livemode') {
                            livemode = parser.getBooleanValue();
                        } else if (text == 'metadata') {
                            metadata = new Metadata(parser);
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'next_invoice_sequence') {
                            next_invoice_sequence = parser.getIntegerValue();
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else if (text == 'preferred_locales') {
                            preferred_locales = arrayOfString(parser);
                        } else if (text == 'tax_exempt') {
                            tax_exempt = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Object_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Metadata {
        
        public String sf_contact_id {get;set;}
        public String first_name {get;set;}
        public String last_name {get;set;}
        

        public Metadata(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            if (text == 'sf_contact_id') {
                                sf_contact_id = parser.getText();
                            }
                            else if (text == 'firstName') {
                                first_name = parser.getText();
                            }
                            else if (text == 'lastName') {
                                last_name = parser.getText();
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public class Data {
        public Object_Z object_Z {get;set;} // in json: object

        public Data(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'object') {
                            object_Z = new Object_Z(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static StripeCustomerWrapper parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new StripeCustomerWrapper(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    




    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
}