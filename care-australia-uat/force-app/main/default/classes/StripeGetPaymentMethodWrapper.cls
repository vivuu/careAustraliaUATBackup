public class StripeGetPaymentMethodWrapper {

	
	
	public class Networks {
		public List<String> available {get;set;} 
		public Object preferred {get;set;} 

		public Networks(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'available') {
							available = arrayOfString(parser);
						} else if (text == 'preferred') {
							preferred = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Networks consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public PaymentMethod paymentMethod {get;set;} 

	public StripeGetPaymentMethodWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'paymentMethod') {
						paymentMethod = new PaymentMethod(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'StripeGetPaymentMethodWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	
	
	public class PaymentMethod {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public Card card {get;set;} 
		public Integer created {get;set;} 
		public Object customer {get;set;} 
		public Boolean livemode {get;set;} 
		public String type {get;set;} 

		public PaymentMethod(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'card') {
							card = new Card(parser);
						} else if (text == 'created') {
							created = parser.getIntegerValue();
						} else if (text == 'customer') {
							customer = parser.readValueAs(Object.class);
						} else if (text == 'livemode') {
							livemode = parser.getBooleanValue();
						} else if (text == 'type') {
							type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PaymentMethod consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Three_d_secure_usage {
		public Boolean supported {get;set;} 

		public Three_d_secure_usage(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'supported') {
							supported = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Three_d_secure_usage consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Card {
		public String brand {get;set;} 
        public String fingerprint {get;set;}
		public String country {get;set;} 
		public Integer exp_month {get;set;} 
		public Integer exp_year {get;set;} 
		public String funding {get;set;} 
		public Object generated_from {get;set;} 
		public String last4 {get;set;} 
		public Networks networks {get;set;} 
		public Three_d_secure_usage three_d_secure_usage {get;set;} 
		public Object wallet {get;set;} 

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
						} else if (text == 'funding') {
							funding = parser.getText();
						} else if (text == 'generated_from') {
							generated_from = parser.readValueAs(Object.class);
						} else if (text == 'last4') {
							last4 = parser.getText();
						} else if (text == 'networks') {
							networks = new Networks(parser);
						} else if (text == 'three_d_secure_usage') {
							three_d_secure_usage = new Three_d_secure_usage(parser);
						} else if (text == 'wallet') {
							wallet = parser.readValueAs(Object.class);
						} else if (text == 'fingerprint') {
							fingerprint = parser.getText();
						} else  {
							System.debug(LoggingLevel.WARN, 'Card consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static StripeGetPaymentMethodWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new StripeGetPaymentMethodWrapper(parser);
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