# frozen_string_literal: true

module BillingIO
  # Provides access to revenue adjustment endpoints.
  #
  #   client.adjustments.list
  #   client.adjustments.create(type: "credit", amount_usd: 10.00, reason: "Goodwill credit")
  class Adjustments
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # List adjustments with cursor-based pagination.
    #
    # @param cursor      [String, nil] opaque cursor for the next page
    # @param limit       [Integer]     items per page (1..100, default 25)
    # @param customer_id [String, nil] filter by customer
    # @return [BillingIO::PaginatedList<BillingIO::Adjustment>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, customer_id: nil)
      params = { limit: limit }
      params[:cursor]      = cursor      if cursor
      params[:customer_id] = customer_id if customer_id

      data = @http.get("/revenue/adjustments", params)
      PaginatedList.from_hash(data, Adjustment)
    end

    # Create a new revenue adjustment.
    #
    # @param type        [String]      adjustment type ("credit", "debit", "correction")
    # @param amount_usd  [Float]       adjustment amount in USD
    # @param reason      [String, nil] human-readable reason
    # @param customer_id [String, nil] related customer
    # @param metadata    [Hash, nil]   arbitrary key-value pairs
    # @return [BillingIO::Adjustment]
    # @raise [BillingIO::Error]
    def create(type:, amount_usd:, reason: nil, customer_id: nil, metadata: nil)
      body = {
        "type"       => type,
        "amount_usd" => amount_usd
      }
      body["reason"]      = reason      if reason
      body["customer_id"] = customer_id if customer_id
      body["metadata"]    = metadata    if metadata

      data = @http.post("/revenue/adjustments", body)
      Adjustment.from_hash(data)
    end
  end
end
