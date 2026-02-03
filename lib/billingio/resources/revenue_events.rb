# frozen_string_literal: true

module BillingIO
  # Provides access to revenue event and accounting endpoints.
  #
  #   client.revenue_events.list(type: "payment")
  #   client.revenue_events.accounting(period_start: "2025-01-01", period_end: "2025-01-31")
  class RevenueEvents
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # List revenue events with cursor-based pagination.
    #
    # @param cursor      [String, nil] opaque cursor for the next page
    # @param limit       [Integer]     items per page (1..100, default 25)
    # @param type        [String, nil] filter by event type
    # @param customer_id [String, nil] filter by customer
    # @return [BillingIO::PaginatedList<BillingIO::RevenueEvent>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, type: nil, customer_id: nil)
      params = { limit: limit }
      params[:cursor]      = cursor      if cursor
      params[:type]        = type        if type
      params[:customer_id] = customer_id if customer_id

      data = @http.get("/revenue/events", params)
      PaginatedList.from_hash(data, RevenueEvent)
    end

    # Retrieve an accounting summary report.
    #
    # @param period_start [String, nil] ISO-8601 period start date
    # @param period_end   [String, nil] ISO-8601 period end date
    # @return [BillingIO::AccountingReport]
    # @raise [BillingIO::Error]
    def accounting(period_start: nil, period_end: nil)
      params = {}
      params[:period_start] = period_start if period_start
      params[:period_end]   = period_end   if period_end

      data = @http.get("/revenue/accounting", params)
      AccountingReport.from_hash(data)
    end
  end
end
