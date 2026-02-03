# frozen_string_literal: true

module BillingIO
  # Provides access to payment link endpoints.
  #
  #   client.payment_links.create(amount_usd: 25.00, chain: "tron", token: "USDT")
  #   client.payment_links.list
  class PaymentLinks
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Create a new payment link.
    #
    # @param amount_usd [Float, nil]   fixed amount in USD (nil for open-amount)
    # @param chain      [String, nil]  blockchain network
    # @param token      [String, nil]  stablecoin token
    # @param metadata   [Hash, nil]    arbitrary key-value pairs
    # @return [BillingIO::PaymentLink]
    # @raise [BillingIO::Error]
    def create(amount_usd: nil, chain: nil, token: nil, metadata: nil)
      body = {}
      body["amount_usd"] = amount_usd if amount_usd
      body["chain"]      = chain      if chain
      body["token"]      = token      if token
      body["metadata"]   = metadata   if metadata

      data = @http.post("/payment-links", body)
      PaymentLink.from_hash(data)
    end

    # List payment links with cursor-based pagination.
    #
    # @param cursor [String, nil] opaque cursor for the next page
    # @param limit  [Integer]     items per page (1..100, default 25)
    # @return [BillingIO::PaginatedList<BillingIO::PaymentLink>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25)
      params = { limit: limit }
      params[:cursor] = cursor if cursor

      data = @http.get("/payment-links", params)
      PaginatedList.from_hash(data, PaymentLink)
    end
  end
end
