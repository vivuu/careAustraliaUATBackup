/**
 * Class Name: StripeInvoiceWrapper
 * Auhtor: Gerent Team
 * Description: response data for invoice from Stripe
 * Modification Details: Deepesh Bansal - 08/09/2022 - Initial version created
 * */

public class StripeInvoiceWrapper {

	public class Object_Z {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public String account_country {get;set;} 
		public String account_name {get;set;} 
		public Object account_tax_ids {get;set;} 
		public Integer amount_due {get;set;} 
		public Integer amount_paid {get;set;} 
		public Integer amount_remaining {get;set;} 
		public Object application {get;set;} 
		public Object application_fee_amount {get;set;} 
		public Integer attempt_count {get;set;} 
		public Boolean attempted {get;set;} 
		public Boolean auto_advance {get;set;} 
		public Automatic_tax automatic_tax {get;set;} 
		public String billing_reason {get;set;} 
		public String charge {get;set;} 
		public String collection_method {get;set;} 
		public Integer created {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public Object custom_fields {get;set;} 
		public String customer {get;set;} 
		public Object customer_address {get;set;} 
		public String customer_email {get;set;} 
		public String customer_name {get;set;} 
		public String customer_phone {get;set;} 
		public Object customer_shipping {get;set;} 
		public String customer_tax_exempt {get;set;} 
		public List<Customer_tax_ids> customer_tax_ids {get;set;} 
		public Object default_payment_method {get;set;} 
		public Object default_source {get;set;} 
		public List<Customer_tax_ids> default_tax_rates {get;set;} 
		public Object description {get;set;} 
		public Object discount {get;set;} 
		public List<Customer_tax_ids> discounts {get;set;} 
		public Object due_date {get;set;} 
		public Integer ending_balance {get;set;} 
		public Object footer {get;set;} 
		public Object from_invoice {get;set;} 
		public String hosted_invoice_url {get;set;} 
		public String invoice_pdf {get;set;} 
		public Object last_finalization_error {get;set;} 
		public Object latest_revision {get;set;} 
		public Lines lines {get;set;} 
		public Boolean livemode {get;set;} 
		public Customer_tax_ids metadata {get;set;} 
		public Object next_payment_attempt {get;set;} 
		public String number_Z {get;set;} // in json: number
		public Object on_behalf_of {get;set;} 
		public Boolean paid {get;set;} 
		public Boolean paid_out_of_band {get;set;} 
		public String payment_intent {get;set;} 
		public Payment_settings payment_settings {get;set;} 
		public Integer period_end {get;set;} 
		public Integer period_start {get;set;} 
		public Integer post_payment_credit_notes_amount {get;set;} 
		public Integer pre_payment_credit_notes_amount {get;set;} 
		public Object quote {get;set;} 
		public Object receipt_number {get;set;} 
		public Object rendering_options {get;set;} 
		public Integer starting_balance {get;set;} 
		public Object statement_descriptor {get;set;} 
		public String status {get;set;} 
		public Status_transitions status_transitions {get;set;} 
		public String subscription {get;set;} 
		public Integer subtotal {get;set;} 
		public Integer subtotal_excluding_tax {get;set;} 
		public Object tax {get;set;} 
		public Object test_clock {get;set;} 
		public Integer total {get;set;} 
		public List<Customer_tax_ids> total_discount_amounts {get;set;} 
		public Integer total_excluding_tax {get;set;} 
		public List<Customer_tax_ids> total_tax_amounts {get;set;} 
		public Object transfer_data {get;set;} 
		public Object webhooks_delivered_at {get;set;} 

		public Object_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'account_country') {
							account_country = parser.getText();
						} else if (text == 'account_name') {
							account_name = parser.getText();
						} else if (text == 'account_tax_ids') {
							account_tax_ids = parser.readValueAs(Object.class);
						} else if (text == 'amount_due') {
							amount_due = parser.getIntegerValue();
						} else if (text == 'amount_paid') {
							amount_paid = parser.getIntegerValue();
						} else if (text == 'amount_remaining') {
							amount_remaining = parser.getIntegerValue();
						} else if (text == 'application') {
							application = parser.readValueAs(Object.class);
						} else if (text == 'application_fee_amount') {
							application_fee_amount = parser.readValueAs(Object.class);
						} else if (text == 'attempt_count') {
							attempt_count = parser.getIntegerValue();
						} else if (text == 'attempted') {
							attempted = parser.getBooleanValue();
						} else if (text == 'auto_advance') {
							auto_advance = parser.getBooleanValue();
						} else if (text == 'automatic_tax') {
							automatic_tax = new Automatic_tax(parser);
						} else if (text == 'billing_reason') {
							billing_reason = parser.getText();
						} else if (text == 'charge') {
							charge = parser.getText();
						} else if (text == 'collection_method') {
							collection_method = parser.getText();
						} else if (text == 'created') {
							created = parser.getIntegerValue();
						} else if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'custom_fields') {
							custom_fields = parser.readValueAs(Object.class);
						} else if (text == 'customer') {
							customer = parser.getText();
						} else if (text == 'customer_address') {
							customer_address = parser.readValueAs(Object.class);
						} else if (text == 'customer_email') {
							customer_email = parser.getText();
						} else if (text == 'customer_name') {
							customer_name = parser.getText();
						} else if (text == 'customer_phone') {
							customer_phone = parser.getText();
						} else if (text == 'customer_shipping') {
							customer_shipping = parser.readValueAs(Object.class);
						} else if (text == 'customer_tax_exempt') {
							customer_tax_exempt = parser.getText();
						} else if (text == 'customer_tax_ids') {
							customer_tax_ids = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'default_payment_method') {
							default_payment_method = parser.readValueAs(Object.class);
						} else if (text == 'default_source') {
							default_source = parser.readValueAs(Object.class);
						} else if (text == 'default_tax_rates') {
							default_tax_rates = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'description') {
							description = parser.readValueAs(Object.class);
						} else if (text == 'discount') {
							discount = parser.readValueAs(Object.class);
						} else if (text == 'discounts') {
							discounts = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'due_date') {
							due_date = parser.readValueAs(Object.class);
						} else if (text == 'ending_balance') {
							ending_balance = parser.getIntegerValue();
						} else if (text == 'footer') {
							footer = parser.readValueAs(Object.class);
						} else if (text == 'from_invoice') {
							from_invoice = parser.readValueAs(Object.class);
						} else if (text == 'hosted_invoice_url') {
							hosted_invoice_url = parser.getText();
						} else if (text == 'invoice_pdf') {
							invoice_pdf = parser.getText();
						} else if (text == 'last_finalization_error') {
							last_finalization_error = parser.readValueAs(Object.class);
						} else if (text == 'latest_revision') {
							latest_revision = parser.readValueAs(Object.class);
						} else if (text == 'lines') {
							lines = new Lines(parser);
						} else if (text == 'livemode') {
							livemode = parser.getBooleanValue();
						} else if (text == 'metadata') {
							metadata = new Customer_tax_ids(parser);
						} else if (text == 'next_payment_attempt') {
							next_payment_attempt = parser.readValueAs(Object.class);
						} else if (text == 'number') {
							number_Z = parser.getText();
						} else if (text == 'on_behalf_of') {
							on_behalf_of = parser.readValueAs(Object.class);
						} else if (text == 'paid') {
							paid = parser.getBooleanValue();
						} else if (text == 'paid_out_of_band') {
							paid_out_of_band = parser.getBooleanValue();
						} else if (text == 'payment_intent') {
							payment_intent = parser.getText();
						} else if (text == 'payment_settings') {
							payment_settings = new Payment_settings(parser);
						} else if (text == 'period_end') {
							period_end = parser.getIntegerValue();
						} else if (text == 'period_start') {
							period_start = parser.getIntegerValue();
						} else if (text == 'post_payment_credit_notes_amount') {
							post_payment_credit_notes_amount = parser.getIntegerValue();
						} else if (text == 'pre_payment_credit_notes_amount') {
							pre_payment_credit_notes_amount = parser.getIntegerValue();
						} else if (text == 'quote') {
							quote = parser.readValueAs(Object.class);
						} else if (text == 'receipt_number') {
							receipt_number = parser.readValueAs(Object.class);
						} else if (text == 'rendering_options') {
							rendering_options = parser.readValueAs(Object.class);
						} else if (text == 'starting_balance') {
							starting_balance = parser.getIntegerValue();
						} else if (text == 'statement_descriptor') {
							statement_descriptor = parser.readValueAs(Object.class);
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'status_transitions') {
							status_transitions = new Status_transitions(parser);
						} else if (text == 'subscription') {
							subscription = parser.getText();
						} else if (text == 'subtotal') {
							subtotal = parser.getIntegerValue();
						} else if (text == 'subtotal_excluding_tax') {
							subtotal_excluding_tax = parser.getIntegerValue();
						} else if (text == 'tax') {
							tax = parser.readValueAs(Object.class);
						} else if (text == 'test_clock') {
							test_clock = parser.readValueAs(Object.class);
						} else if (text == 'total') {
							total = parser.getIntegerValue();
						} else if (text == 'total_discount_amounts') {
							total_discount_amounts = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'total_excluding_tax') {
							total_excluding_tax = parser.getIntegerValue();
						} else if (text == 'total_tax_amounts') {
							total_tax_amounts = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'transfer_data') {
							transfer_data = parser.readValueAs(Object.class);
						} else if (text == 'webhooks_delivered_at') {
							webhooks_delivered_at = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Object_Z consuming unrecognized property: '+text);
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
	
	public class Period {
		public Integer end_Z {get;set;} // in json: end
		public Integer start {get;set;} 

		public Period(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'end') {
							end_Z = parser.getIntegerValue();
						} else if (text == 'start') {
							start = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Period consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public Integer amount {get;set;} 
		public Integer amount_excluding_tax {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public String description {get;set;} 
		public List<Customer_tax_ids> discount_amounts {get;set;} 
		public Boolean discountable {get;set;} 
		public List<Customer_tax_ids> discounts {get;set;} 
		public Boolean livemode {get;set;} 
		public Customer_tax_ids metadata {get;set;} 
		public Period period {get;set;} 
		public Plan plan {get;set;} 
		public Price price {get;set;} 
		public Boolean proration {get;set;} 
		public Proration_details proration_details {get;set;} 
		public Integer quantity {get;set;} 
		public String subscription {get;set;} 
		public String subscription_item {get;set;} 
		public List<Customer_tax_ids> tax_amounts {get;set;} 
		public List<Customer_tax_ids> tax_rates {get;set;} 
		public String type {get;set;} 
		public String unit_amount_excluding_tax {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'amount') {
							amount = parser.getIntegerValue();
						} else if (text == 'amount_excluding_tax') {
							amount_excluding_tax = parser.getIntegerValue();
						} else if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'discount_amounts') {
							discount_amounts = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'discountable') {
							discountable = parser.getBooleanValue();
						} else if (text == 'discounts') {
							discounts = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'livemode') {
							livemode = parser.getBooleanValue();
						} else if (text == 'metadata') {
							metadata = new Customer_tax_ids(parser);
						} else if (text == 'period') {
							period = new Period(parser);
						} else if (text == 'plan') {
							plan = new Plan(parser);
						} else if (text == 'price') {
							price = new Price(parser);
						} else if (text == 'proration') {
							proration = parser.getBooleanValue();
						} else if (text == 'proration_details') {
							proration_details = new Proration_details(parser);
						} else if (text == 'quantity') {
							quantity = parser.getIntegerValue();
						} else if (text == 'subscription') {
							subscription = parser.getText();
						} else if (text == 'subscription_item') {
							subscription_item = parser.getText();
						} else if (text == 'tax_amounts') {
							tax_amounts = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'tax_rates') {
							tax_rates = arrayOfCustomer_tax_ids(parser);
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'unit_amount_excluding_tax') {
							unit_amount_excluding_tax = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
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
		public Customer_tax_ids metadata {get;set;} 
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
							metadata = new Customer_tax_ids(parser);
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
	
	public class Recurring {
		public Object aggregate_usage {get;set;} 
		public String interval {get;set;} 
		public Integer interval_count {get;set;} 
		public Object trial_period_days {get;set;} 
		public String usage_type {get;set;} 

		public Recurring(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'aggregate_usage') {
							aggregate_usage = parser.readValueAs(Object.class);
						} else if (text == 'interval') {
							interval = parser.getText();
						} else if (text == 'interval_count') {
							interval_count = parser.getIntegerValue();
						} else if (text == 'trial_period_days') {
							trial_period_days = parser.readValueAs(Object.class);
						} else if (text == 'usage_type') {
							usage_type = parser.getText();
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
	
	public class Automatic_tax {
		public Boolean enabled {get;set;} 
		public Object status {get;set;} 

		public Automatic_tax(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'enabled') {
							enabled = parser.getBooleanValue();
						} else if (text == 'status') {
							status = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Automatic_tax consuming unrecognized property: '+text);
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
	public Data_Z data {get;set;} 
	public Boolean livemode {get;set;} 
	public Integer pending_webhooks {get;set;} 
	public Request request {get;set;} 
	public String type {get;set;} 

	public StripeInvoiceWrapper(JSONParser parser) {
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
						data = new Data_Z(parser);
					} else if (text == 'livemode') {
						livemode = parser.getBooleanValue();
					} else if (text == 'pending_webhooks') {
						pending_webhooks = parser.getIntegerValue();
					} else if (text == 'request') {
						request = new Request(parser);
					} else if (text == 'type') {
						type = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'StripeInvoiceWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
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
		public Customer_tax_ids metadata {get;set;} 
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
							metadata = new Customer_tax_ids(parser);
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
	
	public class Proration_details {
		public Object credited_items {get;set;} 

		public Proration_details(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'credited_items') {
							credited_items = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Proration_details consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Customer_tax_ids {

		public Customer_tax_ids(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Customer_tax_ids consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Payment_settings {
		public Object default_mandate {get;set;} 
		public Object payment_method_options {get;set;} 
		public Object payment_method_types {get;set;} 

		public Payment_settings(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'default_mandate') {
							default_mandate = parser.readValueAs(Object.class);
						} else if (text == 'payment_method_options') {
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
	}
	
	public class Status_transitions {
		public Integer finalized_at {get;set;} 
		public Object marked_uncollectible_at {get;set;} 
		public Integer paid_at {get;set;} 
		public Object voided_at {get;set;} 

		public Status_transitions(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'finalized_at') {
							finalized_at = parser.getIntegerValue();
						} else if (text == 'marked_uncollectible_at') {
							marked_uncollectible_at = parser.readValueAs(Object.class);
						} else if (text == 'paid_at') {
							paid_at = parser.getIntegerValue();
						} else if (text == 'voided_at') {
							voided_at = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Status_transitions consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Lines {
		public String object_Z {get;set;} // in json: object
		public List<Data> data {get;set;} 
		public Boolean has_more {get;set;} 
		public Integer total_count {get;set;} 
		public String url {get;set;} 

		public Lines(JSONParser parser) {
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
							System.debug(LoggingLevel.WARN, 'Lines consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	
	
	public static StripeInvoiceWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new StripeInvoiceWrapper(parser);
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
	
    private static List<Data> arrayOfData(System.JSONParser p) {
        List<Data> res = new List<Data>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data(p));
        }
        return res;
    }

    private static List<Customer_tax_ids> arrayOfCustomer_tax_ids(System.JSONParser p) {
        List<Customer_tax_ids> res = new List<Customer_tax_ids>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Customer_tax_ids(p));
        }
        return res;
    }
}