# frozen_string_literal: true

module BillingIO
  # Provides access to subscription entitlement endpoints.
  #
  #   client.entitlements.list(subscription_id: "sub_abc123")
  #   client.entitlements.create(subscription_id: "sub_abc123", feature_key: "api_calls")
  #   client.entitlements.update("ent_abc123", value: 1000)
  #   client.entitlements.delete("ent_abc123")
  #   client.entitlements.check(customer_id: "cus_abc123", feature_key: "api_calls")
  class Entitlements
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # List entitlements with cursor-based pagination.
    #
    # @param cursor          [String, nil] opaque cursor for the next page
    # @param limit           [Integer]     items per page (1..100, default 25)
    # @param subscription_id [String, nil] filter by subscription
    # @return [BillingIO::PaginatedList<BillingIO::Entitlement>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, subscription_id: nil)
      params = { limit: limit }
      params[:cursor]          = cursor          if cursor
      params[:subscription_id] = subscription_id if subscription_id

      data = @http.get("/subscriptions/entitlements", params)
      PaginatedList.from_hash(data, Entitlement)
    end

    # Create a new entitlement.
    #
    # @param subscription_id [String]       parent subscription
    # @param feature_key     [String]       machine-readable feature identifier
    # @param value           [Object, nil]  entitlement value
    # @param metadata        [Hash, nil]    arbitrary key-value pairs
    # @return [BillingIO::Entitlement]
    # @raise [BillingIO::Error]
    def create(subscription_id:, feature_key:, value: nil, metadata: nil)
      body = {
        "subscription_id" => subscription_id,
        "feature_key"     => feature_key
      }
      body["value"]    = value    unless value.nil?
      body["metadata"] = metadata if metadata

      data = @http.post("/subscriptions/entitlements", body)
      Entitlement.from_hash(data)
    end

    # Update an existing entitlement.
    #
    # @param entitlement_id [String]       entitlement identifier (prefixed +ent_+)
    # @param value          [Object, nil]  new entitlement value
    # @param metadata       [Hash, nil]    new metadata (replaces existing)
    # @return [BillingIO::Entitlement]
    # @raise [BillingIO::Error]
    def update(entitlement_id, value: nil, metadata: nil)
      body = {}
      body["value"]    = value    unless value.nil?
      body["metadata"] = metadata if metadata

      data = @http.patch("/subscriptions/entitlements/#{entitlement_id}", body)
      Entitlement.from_hash(data)
    end

    # Delete an entitlement.
    #
    # @param entitlement_id [String] entitlement identifier (prefixed +ent_+)
    # @return [nil]
    # @raise [BillingIO::Error]
    def delete(entitlement_id)
      @http.delete("/subscriptions/entitlements/#{entitlement_id}")
      nil
    end

    # Check whether a customer has a specific entitlement.
    #
    # @param customer_id [String] customer identifier
    # @param feature_key [String] feature key to check
    # @return [BillingIO::EntitlementCheck]
    # @raise [BillingIO::Error]
    def check(customer_id:, feature_key:)
      params = {
        customer_id: customer_id,
        feature_key: feature_key
      }

      data = @http.get("/subscriptions/entitlements/check", params)
      EntitlementCheck.from_hash(data)
    end
  end
end
