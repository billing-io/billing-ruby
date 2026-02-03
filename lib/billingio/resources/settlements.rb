# frozen_string_literal: true

module BillingIO
  # Provides access to payout settlement endpoints.
  #
  #   client.settlements.list
  #   client.settlements.list(payout_id: "po_abc123")
  class Settlements
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # List settlements with cursor-based pagination.
    #
    # @param cursor    [String, nil] opaque cursor for the next page
    # @param limit     [Integer]     items per page (1..100, default 25)
    # @param payout_id [String, nil] filter by payout intent
    # @return [BillingIO::PaginatedList<BillingIO::Settlement>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, payout_id: nil)
      params = { limit: limit }
      params[:cursor]    = cursor    if cursor
      params[:payout_id] = payout_id if payout_id

      data = @http.get("/payouts/settlements", params)
      PaginatedList.from_hash(data, Settlement)
    end
  end
end
