# frozen_string_literal: true

module BillingIO
  # Represents a webhook event.
  #
  # @attr_reader event_id    [String]           unique identifier (prefixed +evt_+)
  # @attr_reader type        [String]           event type (e.g. "checkout.completed")
  # @attr_reader checkout_id [String]           related checkout identifier
  # @attr_reader data        [BillingIO::Checkout] checkout snapshot at time of event
  # @attr_reader created_at  [String]           ISO-8601 creation timestamp
  class Event
    ATTRS = %i[event_id type checkout_id data created_at].freeze

    attr_reader(*ATTRS)

    # @param attrs [Hash{String,Symbol => Object}]
    def initialize(attrs = {})
      ATTRS.each do |attr|
        value = attrs[attr.to_s] || attrs[attr]

        # Wrap the nested checkout data in a Checkout model
        if attr == :data && value.is_a?(Hash)
          value = Checkout.from_hash(value)
        end

        instance_variable_set(:"@#{attr}", value)
      end
    end

    # @param hash [Hash]
    # @return [BillingIO::Event]
    def self.from_hash(hash)
      new(hash)
    end

    # @return [Hash{String => Object}]
    def to_h
      ATTRS.each_with_object({}) do |attr, h|
        val = instance_variable_get(:"@#{attr}")
        h[attr.to_s] = val.respond_to?(:to_h) && val.is_a?(Checkout) ? val.to_h : val
      end
    end

    def inspect
      "#<BillingIO::Event event_id=#{@event_id.inspect} type=#{@type.inspect} checkout_id=#{@checkout_id.inspect}>"
    end
  end
end
