# frozen_string_literal: true

module BillingIO
  # Provides access to subscription renewal endpoints.
  #
  #   client.subscription_renewals.list(subscription_id: "sub_abc123")
  #   client.subscription_renewals.retry("ren_abc123")
  class SubscriptionRenewals
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # List subscription renewals with cursor-based pagination.
    #
    # @param cursor          [String, nil] opaque cursor for the next page
    # @param limit           [Integer]     items per page (1..100, default 25)
    # @param subscription_id [String, nil] filter by subscription
    # @param status          [String, nil] filter by renewal status
    # @return [BillingIO::PaginatedList<BillingIO::SubscriptionRenewal>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, subscription_id: nil, status: nil)
      params = { limit: limit }
      params[:cursor]          = cursor          if cursor
      params[:subscription_id] = subscription_id if subscription_id
      params[:status]          = status          if status

      data = @http.get("/subscriptions/renewals", params)
      PaginatedList.from_hash(data, SubscriptionRenewal)
    end

    # Retry a failed renewal.
    #
    # @param renewal_id [String] renewal identifier (prefixed +ren_+)
    # @return [BillingIO::SubscriptionRenewal]
    # @raise [BillingIO::Error]
    def retry(renewal_id)
      data = @http.post("/subscriptions/renewals/#{renewal_id}/retry")
      SubscriptionRenewal.from_hash(data)
    end
  end
end
