# frozen_string_literal: true

module BillingIO
  # Provides access to subscription plan management endpoints.
  #
  #   client.subscription_plans.create(name: "Pro", amount_usd: 29.99, interval: "monthly")
  #   client.subscription_plans.list
  #   client.subscription_plans.update("plan_abc123", name: "Pro Plus")
  class SubscriptionPlans
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Create a new subscription plan.
    #
    # @param name           [String]      human-readable plan name
    # @param amount_usd     [Float]       recurring amount in USD
    # @param interval       [String]      billing interval (e.g. "monthly", "yearly")
    # @param interval_count [Integer]     number of intervals between billings (default 1)
    # @param chain          [String, nil] blockchain network
    # @param token          [String, nil] stablecoin token
    # @param metadata       [Hash, nil]   arbitrary key-value pairs
    # @return [BillingIO::SubscriptionPlan]
    # @raise [BillingIO::Error]
    def create(name:, amount_usd:, interval:, interval_count: 1, chain: nil, token: nil, metadata: nil)
      body = {
        "name"           => name,
        "amount_usd"     => amount_usd,
        "interval"       => interval,
        "interval_count" => interval_count
      }
      body["chain"]    = chain    if chain
      body["token"]    = token    if token
      body["metadata"] = metadata if metadata

      data = @http.post("/subscriptions/plans", body)
      SubscriptionPlan.from_hash(data)
    end

    # List subscription plans with cursor-based pagination.
    #
    # @param cursor [String, nil] opaque cursor for the next page
    # @param limit  [Integer]     items per page (1..100, default 25)
    # @return [BillingIO::PaginatedList<BillingIO::SubscriptionPlan>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25)
      params = { limit: limit }
      params[:cursor] = cursor if cursor

      data = @http.get("/subscriptions/plans", params)
      PaginatedList.from_hash(data, SubscriptionPlan)
    end

    # Update an existing subscription plan.
    #
    # @param plan_id  [String]      plan identifier (prefixed +plan_+)
    # @param name     [String, nil] new plan name
    # @param metadata [Hash, nil]   new metadata (replaces existing)
    # @return [BillingIO::SubscriptionPlan]
    # @raise [BillingIO::Error]
    def update(plan_id, name: nil, metadata: nil)
      body = {}
      body["name"]     = name     if name
      body["metadata"] = metadata if metadata

      data = @http.patch("/subscriptions/plans/#{plan_id}", body)
      SubscriptionPlan.from_hash(data)
    end
  end
end
