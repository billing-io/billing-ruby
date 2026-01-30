# frozen_string_literal: true

module BillingIO
  # Provides access to checkout-related API endpoints.
  #
  #   client.checkouts.create(amount_usd: 49.99, chain: "tron", token: "USDT")
  #   client.checkouts.list(status: "pending")
  #   client.checkouts.get("co_abc123")
  #   client.checkouts.get_status("co_abc123")
  class Checkouts
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Create a new payment checkout.
    #
    # @param amount_usd          [Numeric]      amount in USD (>= 0.01)
    # @param chain               [String]       blockchain network ("tron" | "arbitrum")
    # @param token               [String]       stablecoin token ("USDT" | "USDC")
    # @param expires_in_seconds  [Integer]      checkout TTL in seconds (300..86400, default 1800)
    # @param metadata            [Hash, nil]    arbitrary key-value pairs (max 20 keys)
    # @param idempotency_key     [String, nil]  UUID for idempotent requests
    # @return [BillingIO::Checkout]
    # @raise [BillingIO::Error]
    def create(amount_usd:, chain:, token:, expires_in_seconds: 1800, metadata: nil, idempotency_key: nil)
      body = {
        "amount_usd"         => amount_usd,
        "chain"              => chain,
        "token"              => token,
        "expires_in_seconds" => expires_in_seconds
      }
      body["metadata"] = metadata if metadata

      headers = {}
      headers["Idempotency-Key"] = idempotency_key if idempotency_key

      data = @http.post("/checkouts", body, headers)
      Checkout.from_hash(data)
    end

    # List checkouts with cursor-based pagination.
    #
    # @param cursor [String, nil]  opaque cursor for the next page
    # @param limit  [Integer]      items per page (1..100, default 25)
    # @param status [String, nil]  filter by checkout status
    # @return [BillingIO::PaginatedList<BillingIO::Checkout>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, status: nil)
      params = { limit: limit }
      params[:cursor] = cursor if cursor
      params[:status] = status if status

      data = @http.get("/checkouts", params)
      PaginatedList.from_hash(data, Checkout)
    end

    # Retrieve a single checkout by ID.
    #
    # @param checkout_id [String] checkout identifier (prefixed +co_+)
    # @return [BillingIO::Checkout]
    # @raise [BillingIO::Error]
    def get(checkout_id)
      data = @http.get("/checkouts/#{checkout_id}")
      Checkout.from_hash(data)
    end

    # Retrieve lightweight status for polling.
    #
    # @param checkout_id [String] checkout identifier (prefixed +co_+)
    # @return [BillingIO::CheckoutStatus]
    # @raise [BillingIO::Error]
    def get_status(checkout_id)
      data = @http.get("/checkouts/#{checkout_id}/status")
      CheckoutStatus.from_hash(data)
    end
  end
end
