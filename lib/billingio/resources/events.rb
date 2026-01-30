# frozen_string_literal: true

module BillingIO
  # Provides access to the event history API.
  #
  #   client.events.list(type: "checkout.completed")
  #   client.events.get("evt_abc123")
  class Events
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # List events with cursor-based pagination.
    #
    # @param cursor      [String, nil] opaque cursor for the next page
    # @param limit       [Integer]     items per page (1..100, default 25)
    # @param type        [String, nil] filter by event type (e.g. "checkout.completed")
    # @param checkout_id [String, nil] filter by related checkout
    # @return [BillingIO::PaginatedList<BillingIO::Event>]
    # @raise [BillingIO::Error]
    def list(cursor: nil, limit: 25, type: nil, checkout_id: nil)
      params = { limit: limit }
      params[:cursor]      = cursor      if cursor
      params[:type]        = type        if type
      params[:checkout_id] = checkout_id if checkout_id

      data = @http.get("/events", params)
      PaginatedList.from_hash(data, Event)
    end

    # Retrieve a single event by ID.
    #
    # @param event_id [String] event identifier (prefixed +evt_+)
    # @return [BillingIO::Event]
    # @raise [BillingIO::Error]
    def get(event_id)
      data = @http.get("/events/#{event_id}")
      Event.from_hash(data)
    end
  end
end
