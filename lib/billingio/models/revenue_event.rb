# frozen_string_literal: true

module BillingIO
  # Represents a revenue event for reporting.
  #
  # @attr_reader revenue_event_id [String]      unique identifier (prefixed +rev_+)
  # @attr_reader type             [String]      event type (e.g. "payment", "refund")
  # @attr_reader amount_usd       [Float]       revenue amount in USD
  # @attr_reader customer_id      [String, nil] related customer
  # @attr_reader checkout_id      [String, nil] related checkout
  # @attr_reader subscription_id  [String, nil] related subscription
  # @attr_reader metadata         [Hash, nil]   arbitrary key-value pairs
  # @attr_reader occurred_at      [String]      ISO-8601 event timestamp
  # @attr_reader created_at       [String]      ISO-8601 creation timestamp
  class RevenueEvent
    ATTRS = %i[
      revenue_event_id type amount_usd
      customer_id checkout_id subscription_id
      metadata occurred_at created_at
    ].freeze

    attr_reader(*ATTRS)

    # @param attrs [Hash{String,Symbol => Object}]
    def initialize(attrs = {})
      ATTRS.each do |attr|
        value = attrs[attr.to_s] || attrs[attr]
        instance_variable_set(:"@#{attr}", value)
      end
    end

    # @param hash [Hash]
    # @return [BillingIO::RevenueEvent]
    def self.from_hash(hash)
      new(hash)
    end

    # @return [Hash{String => Object}]
    def to_h
      ATTRS.each_with_object({}) do |attr, h|
        h[attr.to_s] = instance_variable_get(:"@#{attr}")
      end
    end

    def inspect
      "#<BillingIO::RevenueEvent revenue_event_id=#{@revenue_event_id.inspect} type=#{@type.inspect} amount_usd=#{@amount_usd.inspect}>"
    end
  end
end
