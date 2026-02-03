# frozen_string_literal: true

module BillingIO
  # Provides access to payment method management endpoints.
  #
  #   client.payment_methods.create(customer_id: "cus_abc123", type: "wallet")
  #   client.payment_methods.list
  #   client.payment_methods.update("pm_abc123", metadata: { "label" => "main" })
  #   client.payment_methods.delete("pm_abc123")
  #   client.payment_methods.set_default("pm_abc123")
  class PaymentMethods
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Register a new payment method.
    #
    # @param customer_id [String]      owning customer
    # @param type        [String]      method type (e.g. "wallet")
    # @param chain       [String, nil] blockchain network
    # @param token       [String, nil] stablecoin token
    # @param address     [String, nil] wallet address
    # @param metadata    [Hash, nil]   arbitrary key-value pairs
    # @return [BillingIO::PaymentMethod]
    # @raise [BillingIO::Error]
    def create(customer_id:, type:, chain: nil, token: nil, address: nil, metadata: nil)
      body = {
        "customer_id" => customer_id,
        "type"        => type
      }
      body["chain"]    = chain    if chain
      body["token"]    = token    if token
      body["address"]  = address  if address
      body["metadata"] = metadata if metadata

      data = @http.post("/payment-methods", body)
      PaymentMethod.from_hash(data)
    end

    # List payment methods with cursor-based pagination.
    #
    # @param cursor      [String, nil] opaque cursor for the next page
    # @param limit       [Integer]     items per page (1..100, default 25)
    # @param customer_id [String, nil] filter by customer
    # @return [BillingIO::PaginatedList<BillingIO::PaymentMethod>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, customer_id: nil)
      params = { limit: limit }
      params[:cursor]      = cursor      if cursor
      params[:customer_id] = customer_id if customer_id

      data = @http.get("/payment-methods", params)
      PaginatedList.from_hash(data, PaymentMethod)
    end

    # Update an existing payment method.
    #
    # @param payment_method_id [String]    payment method identifier (prefixed +pm_+)
    # @param metadata          [Hash, nil] new metadata (replaces existing)
    # @return [BillingIO::PaymentMethod]
    # @raise [BillingIO::Error]
    def update(payment_method_id, metadata: nil)
      body = {}
      body["metadata"] = metadata if metadata

      data = @http.patch("/payment-methods/#{payment_method_id}", body)
      PaymentMethod.from_hash(data)
    end

    # Delete a payment method.
    #
    # @param payment_method_id [String] payment method identifier (prefixed +pm_+)
    # @return [nil]
    # @raise [BillingIO::Error]
    def delete(payment_method_id)
      @http.delete("/payment-methods/#{payment_method_id}")
      nil
    end

    # Set a payment method as the customer's default.
    #
    # @param payment_method_id [String] payment method identifier (prefixed +pm_+)
    # @return [BillingIO::PaymentMethod]
    # @raise [BillingIO::Error]
    def set_default(payment_method_id)
      data = @http.post("/payment-methods/#{payment_method_id}/default")
      PaymentMethod.from_hash(data)
    end
  end
end
