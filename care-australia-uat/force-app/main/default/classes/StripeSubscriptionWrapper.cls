public class StripeSubscriptionWrapper {

	public class Recurring {
		public String interval {get;set;} 
		public Integer interval_count {get;set;} 
        
		public Recurring(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'interval') {
							interval = parser.getText();
						} else if (text == 'interval_count') {
							interval_count = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Recurring consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data_Z {
		public Object_Z object_Z {get;set;} // in json: object

		public Data_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'object') {
							object_Z = new Object_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Data_Z data {get;set;} 
	
	public StripeSubscriptionWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'data') {
						data = new Data_Z(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	/*
	public class Automatic_tax {
		public Boolean enabled {get;set;} 

		public Automatic_tax(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'enabled') {
							enabled = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Automatic_tax consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    
	
	public class Price {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public Boolean active {get;set;} 
		public String billing_scheme {get;set;} 
		public Integer created {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public Object custom_unit_amount {get;set;} 
		public Boolean livemode {get;set;} 
		public Object lookup_key {get;set;} 
		public Metadata metadata {get;set;} 
		public Object nickname {get;set;} 
		public String product {get;set;} 
		public Recurring recurring {get;set;} 
		public String tax_behavior {get;set;} 
		public Object tiers_mode {get;set;} 
		public Object transform_quantity {get;set;} 
		public String type {get;set;} 
		public Integer unit_amount {get;set;} 
		public String unit_amount_decimal {get;set;} 

		public Price(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'active') {
							active = parser.getBooleanValue();
						} else if (text == 'billing_scheme') {
							billing_scheme = parser.getText();
						} else if (text == 'created') {
							created = parser.getIntegerValue();
						} else if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'custom_unit_amount') {
							custom_unit_amount = parser.readValueAs(Object.class);
						} else if (text == 'livemode') {
							livemode = parser.getBooleanValue();
						} else if (text == 'lookup_key') {
							lookup_key = parser.readValueAs(Object.class);
						} else if (text == 'metadata') {
							metadata = new Metadata(parser);
						} else if (text == 'nickname') {
							nickname = parser.readValueAs(Object.class);
						} else if (text == 'product') {
							product = parser.getText();
						} else if (text == 'recurring') {
							recurring = new Recurring(parser);
						} else if (text == 'tax_behavior') {
							tax_behavior = parser.getText();
						} else if (text == 'tiers_mode') {
							tiers_mode = parser.readValueAs(Object.class);
						} else if (text == 'transform_quantity') {
							transform_quantity = parser.readValueAs(Object.class);
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'unit_amount') {
							unit_amount = parser.getIntegerValue();
						} else if (text == 'unit_amount_decimal') {
							unit_amount_decimal = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Price consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	*/
	public class Object_Z {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public Integer billing_cycle_anchor {get;set;} 
		public Integer cancel_at {get;set;} 
		public Boolean cancel_at_period_end {get;set;} 
		public Integer canceled_at {get;set;} 
		public String collection_method {get;set;} 
		public Integer created {get;set;} 
        public String default_source {get;set;} 
		public Integer current_period_end {get;set;} 
		public Integer current_period_start {get;set;} 
		public String customer {get;set;} 
		public String latest_invoice {get;set;} 
		public Metadata metadata {get;set;} 
		public String schedule {get;set;} 
		public Integer start_date {get;set;} 
		public String status {get;set;} 
	
		public Object_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'billing_cycle_anchor') {
							billing_cycle_anchor = parser.getIntegerValue();
						} else if (text == 'cancel_at') {
							cancel_at = parser.getIntegerValue();
						} else if (text == 'cancel_at_period_end') {
							cancel_at_period_end = parser.getBooleanValue();
						} else if (text == 'canceled_at') {
							canceled_at = parser.getIntegerValue();
						} else if (text == 'collection_method') {
							collection_method = parser.getText();
						} else if (text == 'created') {
							created = parser.getIntegerValue();
						} else if (text == 'default_source') {
							default_source = parser.getText();
						} else if (text == 'current_period_end') {
							current_period_end = parser.getIntegerValue();
						} else if (text == 'current_period_start') {
							current_period_start = parser.getIntegerValue();
						} else if (text == 'customer') {
							customer = parser.getText();
						} else if (text == 'latest_invoice') {
							latest_invoice = parser.getText();
						} else if (text == 'metadata') {
							metadata = new Metadata(parser);
						} else if (text == 'schedule') {
							schedule = parser.getText();
						} else if (text == 'start_date') {
							start_date = parser.getIntegerValue();
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
		public String salesforce_rd_id {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'salesforce_rd_id') {
							salesforce_rd_id = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    /*
	public class Default_tax_rates {

		public Default_tax_rates(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Default_tax_rates consuming unrecognized property: '+text);
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
	}*/
	/*
	public class Data {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public Object billing_thresholds {get;set;} 
		public Integer created {get;set;} 
		public Integer quantity {get;set;} 
		public String subscription {get;set;} 
	
		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'billing_thresholds') {
							billing_thresholds = parser.readValueAs(Object.class);
						} else if (text == 'created') {
							created = parser.getIntegerValue();
						} else if (text == 'quantity') {
							quantity = parser.getIntegerValue();
						} else if (text == 'subscription') {
							subscription = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Items {
		public String object_Z {get;set;} // in json: object
		public List<Data> data {get;set;} 
		public Boolean has_more {get;set;} 
		public Integer total_count {get;set;} 
		public String url {get;set;} 

		public Items(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'data') {
							data = arrayOfData(parser);
						} else if (text == 'has_more') {
							has_more = parser.getBooleanValue();
						} else if (text == 'total_count') {
							total_count = parser.getIntegerValue();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Items consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Plan {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public Boolean active {get;set;} 
		public Object aggregate_usage {get;set;} 
		public Integer amount {get;set;} 
		public String amount_decimal {get;set;} 
		public String billing_scheme {get;set;} 
		public Integer created {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public String interval {get;set;} 
		public Integer interval_count {get;set;} 
		public Boolean livemode {get;set;} 
		public Default_tax_rates metadata {get;set;} 
		public Object nickname {get;set;} 
		public String product {get;set;} 
		public Object tiers_mode {get;set;} 
		public Object transform_usage {get;set;} 
		public Object trial_period_days {get;set;} 
		public String usage_type {get;set;} 

		public Plan(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'active') {
							active = parser.getBooleanValue();
						} else if (text == 'aggregate_usage') {
							aggregate_usage = parser.readValueAs(Object.class);
						} else if (text == 'amount') {
							amount = parser.getIntegerValue();
						} else if (text == 'amount_decimal') {
							amount_decimal = parser.getText();
						} else if (text == 'billing_scheme') {
							billing_scheme = parser.getText();
						} else if (text == 'created') {
							created = parser.getIntegerValue();
						} else if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'interval') {
							interval = parser.getText();
						} else if (text == 'interval_count') {
							interval_count = parser.getIntegerValue();
						} else if (text == 'livemode') {
							livemode = parser.getBooleanValue();
						} else if (text == 'metadata') {
							metadata = new Default_tax_rates(parser);
						} else if (text == 'nickname') {
							nickname = parser.readValueAs(Object.class);
						} else if (text == 'product') {
							product = parser.getText();
						} else if (text == 'tiers_mode') {
							tiers_mode = parser.readValueAs(Object.class);
						} else if (text == 'transform_usage') {
							transform_usage = parser.readValueAs(Object.class);
						} else if (text == 'trial_period_days') {
							trial_period_days = parser.readValueAs(Object.class);
						} else if (text == 'usage_type') {
							usage_type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Plan consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Payment_settings {
		public Object payment_method_options {get;set;} 
		public Object payment_method_types {get;set;} 
		public Object save_default_payment_method {get;set;} 

		public Payment_settings(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'payment_method_options') {
							payment_method_options = parser.readValueAs(Object.class);
						} else if (text == 'payment_method_types') {
							payment_method_types = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Payment_settings consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}*/
	
	
	public static StripeSubscriptionWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new StripeSubscriptionWrapper(parser);
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
	




	/*
    private static List<Data> arrayOfData(System.JSONParser p) {
        List<Data> res = new List<Data>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data(p));
        }
        return res;
    }*/

}