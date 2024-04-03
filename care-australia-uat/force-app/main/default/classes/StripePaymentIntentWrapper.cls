public class StripePaymentIntentWrapper {

  public class Payment_method_details {
    public Card card {get;set;} 
    public String type {get;set;} 

    public Payment_method_details(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'card') {
              card = new Card(parser);
            } else if (text == 'type') {
              type = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'Payment_method_details consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public String id {get;set;} 
  public String object_Z {get;set;} // in json: object
  public String api_version {get;set;} 
  public Integer created {get;set;} 
  public Data data {get;set;} 
  public Boolean livemode {get;set;} 
  public Integer pending_webhooks {get;set;} 
  public Request request {get;set;} 
  public String type {get;set;} 

  public StripePaymentIntentWrapper(JSONParser parser) {
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
      public String failure_code {get;set;}
    public String object_Z {get;set;} // in json: object
    public Integer amount {get;set;} 
    public Integer amount_captured {get;set;} 
    public Integer amount_refunded {get;set;} 
    public String balance_transaction {get;set;} 
    public String calculated_statement_descriptor {get;set;} 
    public Boolean captured {get;set;} 
    public String created {get;set;} 
    public String currency_Z {get;set;} // in json: currency
    public String customer {get;set;} 
    public String description {get;set;} 
    public Boolean disputed {get;set;} 
    public Boolean livemode {get;set;} 
    public Metadata metadata {get;set;} 
    public Boolean paid {get;set;} 
    public String payment_intent {get;set;} 
    public String payment_method {get;set;} 
    public Payment_method_details payment_method_details {get;set;} 
    public String receipt_url {get;set;} 
    public Boolean refunded {get;set;} 
    public Source source {get;set;} 
    public String statement_descriptor {get;set;} 
    public String status {get;set;} 
  
    public Object_Z(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'id') {
              id = parser.getText();
            } else if(text == 'failure_code'){
                failure_code=parser.getText();
            }else if (text == 'object') {
              object_Z = parser.getText();
            } else if (text == 'amount') {
              amount = parser.getIntegerValue();
            } else if (text == 'amount_captured') {
              amount_captured = parser.getIntegerValue();
            } else if (text == 'amount_refunded') {
              amount_refunded = parser.getIntegerValue();
            } else if (text == 'balance_transaction') {
              balance_transaction = parser.getText();
            } else if (text == 'calculated_statement_descriptor') {
              calculated_statement_descriptor = parser.getText();
            } else if (text == 'captured') {
              captured = parser.getBooleanValue();
            } else if (text == 'created') {
              created = parser.getText();
            } else if (text == 'currency') {
              currency_Z = parser.getText();
            } else if (text == 'customer') {
              customer = parser.getText();
            } else if (text == 'description') {
              description = parser.getText();
            } else if (text == 'disputed') {
              disputed = parser.getBooleanValue();
            } else if (text == 'livemode') {
              livemode = parser.getBooleanValue();
            } else if (text == 'metadata') {
              metadata = new Metadata(parser);
            } else if (text == 'paid') {
              paid = parser.getBooleanValue();
            } else if (text == 'payment_intent') {
              payment_intent = parser.getText();
            } else if (text == 'payment_method') {
              payment_method = parser.getText();
            } else if (text == 'payment_method_details') {
              payment_method_details = new Payment_method_details(parser);
            } else if (text == 'receipt_url') {
              receipt_url = parser.getText();
            } else if (text == 'refunded') {
              refunded = parser.getBooleanValue();
            } else if (text == 'source') {
              source = new Source(parser);
            } else if (text == 'statement_descriptor') {
              statement_descriptor = parser.getText();
            } else if (text == 'status') {
              status = parser.getText();
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
        
        public String campaign_code {get;set;}
        public String IsRecurring {get; set;}
        public String donation_source {get; set;}

        public Metadata(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            if (text == 'Campaign-Id') {
                                campaign_code = parser.getText();
                            } 
                            else if (text == 'IsRecurring') {
                                IsRecurring = parser.getText();
                            }
                            else if (text == 'donation_source') {
                                donation_source = parser.getText();
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
  
  public class Fraud_details {

    public Fraud_details(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            {
              System.debug(LoggingLevel.WARN, 'Fraud_details consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class Source {
    public String id {get;set;} 
    public String object_Z {get;set;} // in json: object
    public String brand {get;set;} 
    public String country {get;set;} 
    public String customer {get;set;} 
    public String dynamic_last4 {get;set;} 
    public Integer exp_month {get;set;} 
    public Integer exp_year {get;set;} 
    public String fingerprint {get;set;} 
    public String funding {get;set;} 
    public String last4 {get;set;} 
    public Fraud_details metadata {get;set;} 
    
    public Source(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'id') {
              id = parser.getText();
            } else if (text == 'object') {
              object_Z = parser.getText();
            } else if (text == 'brand') {
              brand = parser.getText();
            } else if (text == 'country') {
              country = parser.getText();
            } else if (text == 'customer') {
              customer = parser.getText();
            } else if (text == 'dynamic_last4') {
              dynamic_last4 = parser.getText();
            } else if (text == 'exp_month') {
              exp_month = parser.getIntegerValue();
            } else if (text == 'exp_year') {
              exp_year = parser.getIntegerValue();
            } else if (text == 'fingerprint') {
              fingerprint = parser.getText();
            } else if (text == 'funding') {
              funding = parser.getText();
            } else if (text == 'last4') {
              last4 = parser.getText();
            } else if (text == 'metadata') {
              metadata = new Fraud_details(parser);
            } else {
              System.debug(LoggingLevel.WARN, 'Source consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class Card {
    public String brand {get;set;} 
    public String country {get;set;} 
    public Integer exp_month {get;set;} 
    public Integer exp_year {get;set;} 
    public String fingerprint {get;set;} 
    public String funding {get;set;} 
    public String last4 {get;set;} 
    public String network {get;set;} 
    
    public Card(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'brand') {
              brand = parser.getText();
            } else if (text == 'country') {
              country = parser.getText();
            } else if (text == 'exp_month') {
              exp_month = parser.getIntegerValue();
            } else if (text == 'exp_year') {
              exp_year = parser.getIntegerValue();
            } else if (text == 'fingerprint') {
              fingerprint = parser.getText();
            } else if (text == 'funding') {
              funding = parser.getText();
            } else if (text == 'last4') {
              last4 = parser.getText();
            } else if (text == 'network') {
              network = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'Card consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  
  public static StripePaymentIntentWrapper parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new StripePaymentIntentWrapper(parser);
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

    private static List<Fraud_details> arrayOfFraud_details(System.JSONParser p) {
        List<Fraud_details> res = new List<Fraud_details>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Fraud_details(p));
        }
        return res;
    }
}