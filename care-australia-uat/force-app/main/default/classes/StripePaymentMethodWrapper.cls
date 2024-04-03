public class StripePaymentMethodWrapper {
	
	public class Address {
		public Object city {get;set;} 
		public Object country {get;set;} 
		public Object line1 {get;set;} 
		public Object line2 {get;set;} 
		public String postal_code {get;set;} 
		public Object state {get;set;} 

		public Address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'city') {
							city = parser.readValueAs(Object.class);
						} else if (text == 'country') {
							country = parser.readValueAs(Object.class);
						} else if (text == 'line1') {
							line1 = parser.readValueAs(Object.class);
						} else if (text == 'line2') {
							line2 = parser.readValueAs(Object.class);
						} else if (text == 'postal_code') {
							postal_code = parser.getText();
						} else if (text == 'state') {
							state = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Address consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Object_Z {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public Billing_details billing_details {get;set;} 
		public Card card {get;set;} 
		public Integer created {get;set;} 
		public String customer {get;set;} 
		public Boolean livemode {get;set;} 
		public Metadata metadata {get;set;} 
		public String type {get;set;} 

		public Object_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'billing_details') {
							billing_details = new Billing_details(parser);
						} else if (text == 'card') {
							card = new Card(parser);
						} else if (text == 'created') {
							created = parser.getIntegerValue();
						} else if (text == 'customer') {
							customer = parser.getText();
						} else if (text == 'livemode') {
							livemode = parser.getBooleanValue();
						} else if (text == 'metadata') {
							metadata = new Metadata(parser);
						} else if (text == 'type') {
							type = parser.getText();
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

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Request {
		public String id {get;set;} 
		public String idempotency_key {get;set;} 

		public Request(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'idempotency_key') {
							idempotency_key = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Request consuming unrecognized property: '+text);
							consumeObject(parser);
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
	
	public class Card_Z {
		public Integer exp_month {get;set;} 

		public Card_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'exp_month') {
							exp_month = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Card_Z consuming unrecognized property: '+text);
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
		public Checks checks {get;set;} 
		public String country {get;set;} 
		public Integer exp_month {get;set;} 
		public Integer exp_year {get;set;} 
		public String fingerprint {get;set;} 
		public String funding {get;set;} 
		public Object generated_from {get;set;} 
		public String last4 {get;set;} 
		public Three_d_secure_usage three_d_secure_usage {get;set;} 
		public Object wallet {get;set;} 

		public Card(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'brand') {
							brand = parser.getText();
						} else if (text == 'checks') {
							checks = new Checks(parser);
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
						} else if (text == 'generated_from') {
							generated_from = parser.readValueAs(Object.class);
						} else if (text == 'last4') {
							last4 = parser.getText();
						} else if (text == 'three_d_secure_usage') {
							three_d_secure_usage = new Three_d_secure_usage(parser);
						} else if (text == 'wallet') {
							wallet = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Card consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Billing_details {
		public Address address {get;set;} 
		public Object email {get;set;} 
		public Object name {get;set;} 
		public Object phone {get;set;} 

		public Billing_details(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'address') {
							address = new Address(parser);
						} else if (text == 'email') {
							email = parser.readValueAs(Object.class);
						} else if (text == 'name') {
							name = parser.readValueAs(Object.class);
						} else if (text == 'phone') {
							phone = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Billing_details consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Checks {
		public Object address_line1_check {get;set;} 
		public String address_postal_code_check {get;set;} 
		public String cvc_check {get;set;} 

		public Checks(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'address_line1_check') {
							address_line1_check = parser.readValueAs(Object.class);
						} else if (text == 'address_postal_code_check') {
							address_postal_code_check = parser.getText();
						} else if (text == 'cvc_check') {
							cvc_check = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Checks consuming unrecognized property: '+text);
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

	public StripePaymentMethodWrapper(JSONParser parser) {
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
					} else if (text == 'request') {
						request = new Request(parser);
					} else if (text == 'type') {
						type = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'StripePaymentMethodWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static StripePaymentMethodWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new StripePaymentMethodWrapper(parser);
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