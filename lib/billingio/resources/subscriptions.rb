# frozen_string_literal: true

module BillingIO
  # Provides access to subscription management endpoints.
  #
  #   client.subscriptions.create(customer_id: "cus_abc123", plan_id: "plan_abc123")
  #   client.subscriptions.list
  #   client.subscriptions.update("sub_abc123", metadata: { "tier" => "premium" })
  class Subscriptions
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Create a new subscription.
    #
    # @param customer_id [String]    customer identifier
    # @param plan_id     [String]    plan identifier
    # @param metadata    [Hash, nil] arbitrary key-value pairs
    # @return [BillingIO::Subscription]
    # @raise [BillingIO::Error]
    def create(customer_id:, plan_id:, metadata: nil)
      body = {
        "customer_id" => customer_id,
        "plan_id"     => plan_id
      }
      body["metadata"] = metadata if metadata

      data = @http.post("/subscriptions", body)
      Subscription.from_hash(data)
    end

    # List subscriptions with cursor-based pagination.
    #
    # @param cursor      [String, nil] opaque cursor for the next page
    # @param limit       [Integer]     items per page (1..100, default 25)
    # @param customer_id [String, nil] filter by customer
    # @param status      [String, nil] filter by subscription status
    # @return [BillingIO::PaginatedList<BillingIO::Subscription>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, customer_id: nil, status: nil)
      params = { limit: limit }
      params[:cursor]      = cursor      if cursor
      params[:customer_id] = customer_id if customer_id
      params[:status]      = status      if status

      data = @http.get("/subscriptions", params)
      PaginatedList.from_hash(data, Subscription)
    end

    # Update an existing subscription.
    #
    # @param subscription_id [String]      subscription identifier (prefixed +sub_+)
    # @param status          [String, nil] new status (e.g. "canceled")
    # @param metadata        [Hash, nil]   new metadata (replaces existing)
    # @return [BillingIO::Subscription]
    # @raise [BillingIO::Error]
    def update(subscription_id, status: nil, metadata: nil)
      body = {}
      body["status"]   = status   if status
      body["metadata"] = metadata if metadata

      data = @http.patch("/subscriptions/#{subscription_id}", body)
      Subscription.from_hash(data)
    end
  end
end
