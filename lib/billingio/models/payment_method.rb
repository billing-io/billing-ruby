# frozen_string_literal: true

module BillingIO
  # Represents a stored payment method (wallet address or card token).
  #
  # @attr_reader payment_method_id [String]      unique identifier (prefixed +pm_+)
  # @attr_reader customer_id       [String]      owning customer
  # @attr_reader type              [String]      payment method type
  # @attr_reader chain             [String, nil] blockchain network
  # @attr_reader token             [String, nil] stablecoin token
  # @attr_reader address           [String, nil] wallet address
  # @attr_reader is_default        [Boolean]     whether this is the default method
  # @attr_reader metadata          [Hash, nil]   arbitrary key-value pairs
  # @attr_reader status            [String]      method status
  # @attr_reader created_at        [String]      ISO-8601 creation timestamp
  # @attr_reader updated_at        [String]      ISO-8601 last-update timestamp
  class PaymentMethod
    ATTRS = %i[
      payment_method_id customer_id type chain token
      address is_default metadata status
      created_at updated_at
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
    # @return [BillingIO::PaymentMethod]
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
      "#<BillingIO::PaymentMethod payment_method_id=#{@payment_method_id.inspect} type=#{@type.inspect} is_default=#{@is_default.inspect}>"
    end
  end
end
