//
//Generated by AdminBooster
//

public class StripeGetInvoiceWrapper{
	public cls_data[] data;
	public boolean has_more;
	public String next_page;	//WzE2NjUxMTA4ODQuMzgwNTgyOF0=
	public String url;	///v1/invoices/search
	public class cls_data {
		public String id;	//il_1Lrbj3GGWgtqSxG4DwNwrc1X
		public Integer amount;	//200
		public Integer amount_excluding_tax;	//200
		public String description;	//2 × Recurring Donation (at $1.00 / every 4 weeks)
		public cls_period period;
		public cls_plan plan;
		public cls_price price;
		public boolean proration;
		public Integer quantity;	//2
        public String created;
		public String type;	//subscription
		public String unit_amount_excluding_tax;	//100
		public boolean paid;
		public boolean paid_out_of_band;
		public String payment_intent;	//pi_3LXJ8tGGWgtqSxG400rXlUD9
		public Integer period_end;	//1665468841
		public Integer period_start;	//1663049641
		public String status;	//paid
		public String subscription;	//sub_1LXJ6bGGWgtqSxG4tKIl0Ml5
		public Integer total;
	}
	class cls_automatic_tax {
		public boolean enabled;
	}
	class cls_lines {
		public cls_data[] data;
		public boolean has_more;
		public Integer total_count;	//1
		public String url;	///v1/invoices/in_1LXJ8pGGWgtqSxG4aJbL6U2G/lines
	}
	class cls_period {
		public Integer start;	//1665468841
	}
	class cls_plan {
		public String id;	//price_1LJB0JGGWgtqSxG4qBM8ywVC
		public boolean active;
		public Integer amount;	//100
		public String amount_decimal;	//100
		public String billing_scheme;	//per_unit
		public Integer created;	//1657262971
		public String interval;	//week
		public Integer interval_count;	//4
		public boolean livemode;
		public String nickname;	//Donation Amount
		public String product;	//prod_M1C8j7YNLrXN9x
		public String usage_type;	//licensed
	}
	class cls_price {
		public String id;	//price_1LJB0JGGWgtqSxG4qBM8ywVC
		public boolean active;
		public String billing_scheme;	//per_unit
		public Integer created;	//1657262971
		public boolean livemode;
		public String nickname;	//Donation Amount
		public String product;	//prod_M1C8j7YNLrXN9x
		public String tax_behavior;	//inclusive
		public String type;	//recurring
		public Integer unit_amount;	//100
		public String unit_amount_decimal;	//100
	}
	class cls_recurring {
		public String interval;	//week
		public Integer interval_count;	//4
		public String usage_type;	//licensed
	}
	class cls_status_transitions {
		public Integer finalized_at;	//1665472441
		public Integer paid_at;	//1665472441
	}
	public static StripeGetInvoiceWrapper parse(String json){
		return (StripeGetInvoiceWrapper) System.JSON.deserialize(json, StripeGetInvoiceWrapper.class);
	}

}