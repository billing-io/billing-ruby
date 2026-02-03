# frozen_string_literal: true

module BillingIO
  # Represents an active subscription.
  #
  # @attr_reader subscription_id        [String]      unique identifier (prefixed +sub_+)
  # @attr_reader customer_id            [String]      owning customer
  # @attr_reader plan_id                [String]      associated plan
  # @attr_reader status                 [String]      subscription status
  # @attr_reader current_period_start   [String, nil] ISO-8601 current period start
  # @attr_reader current_period_end     [String, nil] ISO-8601 current period end
  # @attr_reader canceled_at            [String, nil] ISO-8601 cancellation timestamp
  # @attr_reader metadata               [Hash, nil]   arbitrary key-value pairs
  # @attr_reader created_at             [String]      ISO-8601 creation timestamp
  # @attr_reader updated_at             [String]      ISO-8601 last-update timestamp
  class Subscription
    ATTRS = %i[
      subscription_id customer_id plan_id status
      current_period_start current_period_end
      canceled_at metadata created_at updated_at
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
    # @return [BillingIO::Subscription]
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
      "#<BillingIO::Subscription subscription_id=#{@subscription_id.inspect} plan_id=#{@plan_id.inspect} status=#{@status.inspect}>"
    end
  end
end
