# frozen_string_literal: true

module BillingIO
  # Provides access to customer management endpoints.
  #
  #   client.customers.create(email: "user@example.com")
  #   client.customers.list
  #   client.customers.get("cus_abc123")
  #   client.customers.update("cus_abc123", name: "Jane Doe")
  class Customers
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Create a new customer.
    #
    # @param email    [String, nil]  customer email address
    # @param name     [String, nil]  customer display name
    # @param metadata [Hash, nil]    arbitrary key-value pairs
    # @return [BillingIO::Customer]
    # @raise [BillingIO::Error]
    def create(email: nil, name: nil, metadata: nil)
      body = {}
      body["email"]    = email    if email
      body["name"]     = name     if name
      body["metadata"] = metadata if metadata

      data = @http.post("/customers", body)
      Customer.from_hash(data)
    end

    # List customers with cursor-based pagination.
    #
    # @param cursor [String, nil] opaque cursor for the next page
    # @param limit  [Integer]     items per page (1..100, default 25)
    # @return [BillingIO::PaginatedList<BillingIO::Customer>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25)
      params = { limit: limit }
      params[:cursor] = cursor if cursor

      data = @http.get("/customers", params)
      PaginatedList.from_hash(data, Customer)
    end

    # Retrieve a single customer by ID.
    #
    # @param customer_id [String] customer identifier (prefixed +cus_+)
    # @return [BillingIO::Customer]
    # @raise [BillingIO::Error]
    def get(customer_id)
      data = @http.get("/customers/#{customer_id}")
      Customer.from_hash(data)
    end

    # Update an existing customer.
    #
    # @param customer_id [String]      customer identifier (prefixed +cus_+)
    # @param email       [String, nil] new email address
    # @param name        [String, nil] new display name
    # @param metadata    [Hash, nil]   new metadata (replaces existing)
    # @return [BillingIO::Customer]
    # @raise [BillingIO::Error]
    def update(customer_id, email: nil, name: nil, metadata: nil)
      body = {}
      body["email"]    = email    if email
      body["name"]     = name     if name
      body["metadata"] = metadata if metadata

      data = @http.patch("/customers/#{customer_id}", body)
      Customer.from_hash(data)
    end
  end
end
