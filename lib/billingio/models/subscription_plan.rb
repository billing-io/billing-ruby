# frozen_string_literal: true

module BillingIO
  # Represents a subscription plan template.
  #
  # @attr_reader plan_id        [String]      unique identifier (prefixed +plan_+)
  # @attr_reader name           [String]      human-readable plan name
  # @attr_reader amount_usd     [Float]       recurring amount in USD
  # @attr_reader interval       [String]      billing interval (e.g. "monthly", "yearly")
  # @attr_reader interval_count [Integer]     number of intervals between billings
  # @attr_reader chain          [String, nil] blockchain network
  # @attr_reader token          [String, nil] stablecoin token
  # @attr_reader metadata       [Hash, nil]   arbitrary key-value pairs
  # @attr_reader status         [String]      plan status
  # @attr_reader created_at     [String]      ISO-8601 creation timestamp
  # @attr_reader updated_at     [String]      ISO-8601 last-update timestamp
  class SubscriptionPlan
    ATTRS = %i[
      plan_id name amount_usd interval interval_count
      chain token metadata status
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
    # @return [BillingIO::SubscriptionPlan]
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
      "#<BillingIO::SubscriptionPlan plan_id=#{@plan_id.inspect} name=#{@name.inspect} amount_usd=#{@amount_usd.inspect}>"
    end
  end
end
