# billingio

Official Ruby SDK for the [billing.io](https://billing.io) payments platform.

- Manage customers, payment methods, and payment links
- Create payment checkouts settled in USDT / USDC on Tron or Arbitrum
- Recurring billing with subscription plans, renewals, and entitlements
- Payouts and settlement tracking
- Revenue events, accounting reports, and adjustments
- Manage webhook endpoints and verify signatures
- Query event history with cursor-based pagination
- Zero runtime dependencies (stdlib only)

## Requirements

- Ruby >= 3.0

## Installation

Add to your Gemfile:

```ruby
gem "billingio"
```

Then run:

```
bundle install
```

Or install directly:

```
gem install billingio
```

## Quickstart

```ruby
require "billingio"

client = BillingIO::Client.new(api_key: "sk_live_...")

# Create a checkout
checkout = client.checkouts.create(
  amount_usd: 49.99,
  chain:      "tron",
  token:      "USDT",
  metadata:   { "order_id" => "ord_12345" }
)

puts checkout.checkout_id     # => "co_..."
puts checkout.deposit_address # => "T..."
puts checkout.status          # => "pending"

# Poll for status updates
status = client.checkouts.get_status(checkout.checkout_id)
puts status.confirmations            # => 0
puts status.required_confirmations   # => 19
puts status.polling_interval_ms      # => 2000
```

## Customers

```ruby
# Create a customer
customer = client.customers.create(
  email: "user@example.com",
  name:  "Jane Doe",
  metadata: { "org" => "acme" }
)
puts customer.customer_id  # => "cus_..."

# List customers
customers = client.customers.list(limit: 10)
customers.each { |c| puts c.email }

# Retrieve a customer
customer = client.customers.get("cus_abc123")

# Update a customer
customer = client.customers.update("cus_abc123", name: "Jane Smith")
```

## Payment Methods

```ruby
# Register a payment method
pm = client.payment_methods.create(
  customer_id: "cus_abc123",
  type:        "wallet",
  chain:       "tron",
  token:       "USDT",
  address:     "T..."
)
puts pm.payment_method_id  # => "pm_..."

# List payment methods
methods = client.payment_methods.list(customer_id: "cus_abc123")
methods.each { |m| puts "#{m.payment_method_id}: #{m.type}" }

# Update a payment method
client.payment_methods.update("pm_abc123", metadata: { "label" => "primary" })

# Set as default
client.payment_methods.set_default("pm_abc123")

# Delete a payment method
client.payment_methods.delete("pm_abc123")
```

## Payment Links

```ruby
# Create a payment link
link = client.payment_links.create(
  amount_usd: 25.00,
  chain:      "tron",
  token:      "USDT"
)
puts link.url  # => "https://pay.billing.io/..."

# List payment links
links = client.payment_links.list
links.each { |l| puts "#{l.payment_link_id}: #{l.url}" }
```

## Checkouts

```ruby
# Create with idempotency key
checkout = client.checkouts.create(
  amount_usd:      100.00,
  chain:           "arbitrum",
  token:           "USDC",
  idempotency_key: SecureRandom.uuid
)

# Retrieve a checkout
checkout = client.checkouts.get("co_abc123")

# Get lightweight status for polling
status = client.checkouts.get_status("co_abc123")

# List checkouts with optional status filter
list = client.checkouts.list(status: "confirmed", limit: 10)
list.each { |c| puts c.checkout_id }
```

## Subscription Plans

```ruby
# Create a plan
plan = client.subscription_plans.create(
  name:       "Pro Monthly",
  amount_usd: 29.99,
  interval:   "monthly"
)
puts plan.plan_id  # => "plan_..."

# List plans
plans = client.subscription_plans.list
plans.each { |p| puts "#{p.plan_id}: #{p.name} ($#{p.amount_usd})" }

# Update a plan
client.subscription_plans.update("plan_abc123", name: "Pro Plus Monthly")
```

## Subscriptions

```ruby
# Create a subscription
sub = client.subscriptions.create(
  customer_id: "cus_abc123",
  plan_id:     "plan_abc123"
)
puts sub.subscription_id  # => "sub_..."
puts sub.status           # => "active"

# List subscriptions
subs = client.subscriptions.list(customer_id: "cus_abc123", status: "active")
subs.each { |s| puts "#{s.subscription_id}: #{s.status}" }

# Cancel a subscription
client.subscriptions.update("sub_abc123", status: "canceled")
```

## Subscription Renewals

```ruby
# List renewals
renewals = client.subscription_renewals.list(subscription_id: "sub_abc123")
renewals.each { |r| puts "#{r.renewal_id}: #{r.status}" }

# Retry a failed renewal
renewal = client.subscription_renewals.retry("ren_abc123")
puts renewal.status  # => "pending"
```

## Entitlements

```ruby
# Create an entitlement
ent = client.entitlements.create(
  subscription_id: "sub_abc123",
  feature_key:     "api_calls",
  value:           10_000
)
puts ent.entitlement_id  # => "ent_..."

# List entitlements
ents = client.entitlements.list(subscription_id: "sub_abc123")
ents.each { |e| puts "#{e.feature_key}: #{e.value}" }

# Update an entitlement
client.entitlements.update("ent_abc123", value: 50_000)

# Check entitlement access
check = client.entitlements.check(
  customer_id: "cus_abc123",
  feature_key: "api_calls"
)
puts check.entitled    # => true
puts check.value       # => 50000

# Delete an entitlement
client.entitlements.delete("ent_abc123")
```

## Payout Intents

```ruby
# Create a payout
payout = client.payout_intents.create(
  amount_usd:  500.00,
  chain:       "tron",
  token:       "USDT",
  destination: "T..."
)
puts payout.payout_id  # => "po_..."
puts payout.status     # => "pending"

# List payouts
payouts = client.payout_intents.list(status: "pending")
payouts.each { |p| puts "#{p.payout_id}: $#{p.amount_usd}" }

# Update a payout
client.payout_intents.update("po_abc123", metadata: { "ref" => "inv_001" })

# Execute a payout (trigger on-chain transfer)
payout = client.payout_intents.execute("po_abc123")
puts payout.status   # => "executing"
puts payout.tx_hash  # => "0x..."
```

## Settlements

```ruby
# List settlements
settlements = client.settlements.list
settlements.each do |s|
  puts "#{s.settlement_id}: $#{s.net_usd} (fee: $#{s.fee_usd})"
end

# Filter by payout
settlements = client.settlements.list(payout_id: "po_abc123")
```

## Revenue Events

```ruby
# List revenue events
events = client.revenue_events.list(type: "payment", customer_id: "cus_abc123")
events.each do |e|
  puts "#{e.revenue_event_id}: #{e.type} $#{e.amount_usd}"
end

# Get accounting summary
report = client.revenue_events.accounting(
  period_start: "2025-01-01",
  period_end:   "2025-01-31"
)
puts report.total_revenue       # => 12500.00
puts report.total_fees          # => 125.00
puts report.total_net           # => 12375.00
puts report.transaction_count   # => 340
```

## Adjustments

```ruby
# Create a revenue adjustment
adj = client.adjustments.create(
  type:        "credit",
  amount_usd:  10.00,
  reason:      "Goodwill credit",
  customer_id: "cus_abc123"
)
puts adj.adjustment_id  # => "adj_..."

# List adjustments
adjustments = client.adjustments.list(customer_id: "cus_abc123")
adjustments.each { |a| puts "#{a.adjustment_id}: #{a.type} $#{a.amount_usd}" }
```

## Webhook Endpoints

```ruby
# Create a webhook endpoint
endpoint = client.webhooks.create(
  url:         "https://example.com/webhooks/billing",
  events:      ["checkout.completed", "checkout.expired"],
  description: "Production webhook"
)

# IMPORTANT: Store the secret securely -- it is only returned on creation.
puts endpoint.secret  # => "whsec_..."

# List all endpoints
endpoints = client.webhooks.list
endpoints.each { |ep| puts "#{ep.webhook_id}: #{ep.url}" }

# Retrieve a single endpoint
endpoint = client.webhooks.get("we_abc123")

# Delete an endpoint
client.webhooks.delete("we_abc123")
```

## Webhook Signature Verification

When receiving webhook events, always verify the signature before processing.

### Rails

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    header  = request.headers["X-Billing-Signature"]
    secret  = ENV.fetch("BILLING_WEBHOOK_SECRET")

    begin
      event = BillingIO::WebhookSignature.verify(
        payload:   payload,
        header:    header,
        secret:    secret,
        tolerance: 300
      )
    rescue BillingIO::WebhookVerificationError => e
      return head :bad_request
    end

    case event["type"]
    when "checkout.completed"
      # Fulfill the order
      order = Order.find_by!(billing_checkout_id: event["checkout_id"])
      order.fulfill!
    when "checkout.expired"
      # Handle expiration
    end

    head :ok
  end
end
```

### Sinatra

```ruby
require "sinatra"
require "billingio"

post "/webhooks/billing" do
  payload = request.body.read
  header  = request.env["HTTP_X_BILLING_SIGNATURE"]
  secret  = ENV.fetch("BILLING_WEBHOOK_SECRET")

  begin
    event = BillingIO::WebhookSignature.verify(
      payload: payload,
      header:  header,
      secret:  secret
    )
  rescue BillingIO::WebhookVerificationError
    halt 400, "Invalid signature"
  end

  case event["type"]
  when "checkout.completed"
    # Handle successful payment
  end

  status 200
  body "ok"
end
```

## Events

```ruby
# List events with filters
events = client.events.list(
  type:        "checkout.completed",
  checkout_id: "co_abc123",
  limit:       50
)

events.each do |event|
  puts "#{event.event_id}: #{event.type} at #{event.created_at}"
  puts "  checkout: #{event.data.checkout_id}" # nested Checkout model
end

# Retrieve a single event
event = client.events.get("evt_abc123")
```

## Pagination

All list endpoints return a `BillingIO::PaginatedList` with cursor-based
pagination. Use `has_more?` and `next_cursor` to page through results.

```ruby
# Manual pagination
cursor = nil

loop do
  page = client.checkouts.list(cursor: cursor, limit: 100)

  page.each do |checkout|
    puts checkout.checkout_id
  end

  break unless page.has_more?
  cursor = page.next_cursor
end
```

`PaginatedList` includes `Enumerable`, so you can use `map`, `select`,
`first`, and other enumeration methods on each page.

## Health Check

```ruby
health = client.health.get
puts health.status   # => "healthy"
puts health.version  # => "1.0.0"
```

## Error Handling

All API errors raise `BillingIO::Error` with structured details.

```ruby
begin
  client.checkouts.get("co_nonexistent")
rescue BillingIO::Error => e
  puts e.message      # => "No checkout found with ID co_nonexistent."
  puts e.type         # => "not_found"
  puts e.code         # => "checkout_not_found"
  puts e.status_code  # => 404
  puts e.param        # => "checkout_id"
end
```

Error types (from the API):

| Type                    | Description                            |
|-------------------------|----------------------------------------|
| `invalid_request`       | Missing or invalid parameters          |
| `authentication_error`  | Invalid or missing API key             |
| `not_found`             | Resource does not exist                |
| `idempotency_conflict`  | Idempotency key reused with diff params|
| `rate_limited`          | Too many requests                      |
| `internal_error`        | Server-side error                      |

## Configuration

```ruby
# Override the base URL (e.g. for local development)
client = BillingIO::Client.new(
  api_key:  "sk_test_...",
  base_url: "http://localhost:8080/v1"
)
```

## License

MIT
