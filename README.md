# billingio

Official Ruby SDK for the [billing.io](https://billing.io) crypto checkout API.

- Create payment checkouts settled in USDT / USDC on Tron or Arbitrum
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
