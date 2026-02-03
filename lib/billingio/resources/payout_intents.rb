# frozen_string_literal: true

module BillingIO
  # Provides access to payout intent endpoints.
  #
  #   client.payout_intents.create(amount_usd: 500.00, chain: "tron", token: "USDT", destination: "T...")
  #   client.payout_intents.list
  #   client.payout_intents.update("po_abc123", metadata: { "ref" => "inv_001" })
  #   client.payout_intents.execute("po_abc123")
  class PayoutIntents
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Create a new payout intent.
    #
    # @param amount_usd  [Float]       payout amount in USD
    # @param chain       [String]      blockchain network
    # @param token       [String]      stablecoin token
    # @param destination [String]      destination wallet address
    # @param metadata    [Hash, nil]   arbitrary key-value pairs
    # @return [BillingIO::PayoutIntent]
    # @raise [BillingIO::Error]
    def create(amount_usd:, chain:, token:, destination:, metadata: nil)
      body = {
        "amount_usd"  => amount_usd,
        "chain"       => chain,
        "token"       => token,
        "destination" => destination
      }
      body["metadata"] = metadata if metadata

      data = @http.post("/payouts", body)
      PayoutIntent.from_hash(data)
    end

    # List payout intents with cursor-based pagination.
    #
    # @param cursor [String, nil] opaque cursor for the next page
    # @param limit  [Integer]     items per page (1..100, default 25)
    # @param status [String, nil] filter by payout status
    # @return [BillingIO::PaginatedList<BillingIO::PayoutIntent>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, status: nil)
      params = { limit: limit }
      params[:cursor] = cursor if cursor
      params[:status] = status if status

      data = @http.get("/payouts", params)
      PaginatedList.from_hash(data, PayoutIntent)
    end

    # Update an existing payout intent.
    #
    # @param payout_id [String]    payout identifier (prefixed +po_+)
    # @param metadata  [Hash, nil] new metadata (replaces existing)
    # @return [BillingIO::PayoutIntent]
    # @raise [BillingIO::Error]
    def update(payout_id, metadata: nil)
      body = {}
      body["metadata"] = metadata if metadata

      data = @http.patch("/payouts/#{payout_id}", body)
      PayoutIntent.from_hash(data)
    end

    # Execute a payout intent (trigger the on-chain transfer).
    #
    # @param payout_id [String] payout identifier (prefixed +po_+)
    # @return [BillingIO::PayoutIntent]
    # @raise [BillingIO::Error]
    def execute(payout_id)
      data = @http.post("/payouts/#{payout_id}/execute")
      PayoutIntent.from_hash(data)
    end
  end
end
