# frozen_string_literal: true

module BillingIO
  # Provides access to webhook endpoint management.
  #
  #   client.webhooks.create(url: "https://example.com/hook", events: ["checkout.completed"])
  #   client.webhooks.list
  #   client.webhooks.get("we_abc123")
  #   client.webhooks.delete("we_abc123")
  class Webhooks
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Register a new webhook endpoint.
    #
    # @param url         [String]        HTTPS URL to receive events
    # @param events      [Array<String>] event types to subscribe to
    # @param description [String, nil]   human-readable label (max 256 chars)
    # @return [BillingIO::WebhookEndpoint]  includes the +secret+ field (store it securely)
    # @raise [BillingIO::Error]
    def create(url:, events:, description: nil)
      body = {
        "url"    => url,
        "events" => events
      }
      body["description"] = description if description

      data = @http.post("/webhooks", body)
      WebhookEndpoint.from_hash(data)
    end

    # List webhook endpoints with cursor-based pagination.
    #
    # @param cursor [String, nil] opaque cursor for the next page
    # @param limit  [Integer]     items per page (1..100, default 25)
    # @return [BillingIO::PaginatedList<BillingIO::WebhookEndpoint>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25)
      params = { limit: limit }
      params[:cursor] = cursor if cursor

      data = @http.get("/webhooks", params)
      PaginatedList.from_hash(data, WebhookEndpoint)
    end

    # Retrieve a single webhook endpoint by ID.
    #
    # @param webhook_id [String] webhook endpoint identifier (prefixed +we_+)
    # @return [BillingIO::WebhookEndpoint]
    # @raise [BillingIO::Error]
    def get(webhook_id)
      data = @http.get("/webhooks/#{webhook_id}")
      WebhookEndpoint.from_hash(data)
    end

    # Delete a webhook endpoint.
    #
    # @param webhook_id [String] webhook endpoint identifier (prefixed +we_+)
    # @return [nil]
    # @raise [BillingIO::Error]
    def delete(webhook_id)
      @http.delete("/webhooks/#{webhook_id}")
      nil
    end
  end
end
