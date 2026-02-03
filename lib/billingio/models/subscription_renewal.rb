# frozen_string_literal: true

module BillingIO
  # Represents a subscription renewal attempt.
  #
  # @attr_reader renewal_id      [String]      unique identifier (prefixed +ren_+)
  # @attr_reader subscription_id [String]      parent subscription
  # @attr_reader status          [String]      renewal status
  # @attr_reader amount_usd      [Float]       renewal amount in USD
  # @attr_reader attempt_count   [Integer]     number of attempts made
  # @attr_reader next_retry_at   [String, nil] ISO-8601 next retry timestamp
  # @attr_reader checkout_id     [String, nil] checkout created for this renewal
  # @attr_reader created_at      [String]      ISO-8601 creation timestamp
  # @attr_reader updated_at      [String]      ISO-8601 last-update timestamp
  class SubscriptionRenewal
    ATTRS = %i[
      renewal_id subscription_id status amount_usd
      attempt_count next_retry_at checkout_id
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
    # @return [BillingIO::SubscriptionRenewal]
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
      "#<BillingIO::SubscriptionRenewal renewal_id=#{@renewal_id.inspect} subscription_id=#{@subscription_id.inspect} status=#{@status.inspect}>"
    end
  end
end
