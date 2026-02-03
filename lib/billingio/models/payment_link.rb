# frozen_string_literal: true

module BillingIO
  # Represents a reusable payment link.
  #
  # @attr_reader payment_link_id [String]      unique identifier (prefixed +pl_+)
  # @attr_reader url             [String]      hosted payment URL
  # @attr_reader amount_usd      [Float, nil]  fixed amount in USD (nil for open-amount)
  # @attr_reader chain           [String, nil] blockchain network
  # @attr_reader token           [String, nil] stablecoin token
  # @attr_reader metadata        [Hash, nil]   arbitrary key-value pairs
  # @attr_reader status          [String]      link status
  # @attr_reader created_at      [String]      ISO-8601 creation timestamp
  class PaymentLink
    ATTRS = %i[
      payment_link_id url amount_usd chain token
      metadata status created_at
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
    # @return [BillingIO::PaymentLink]
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
      "#<BillingIO::PaymentLink payment_link_id=#{@payment_link_id.inspect} url=#{@url.inspect} status=#{@status.inspect}>"
    end
  end
end
