# frozen_string_literal: true

module BillingIO
  # Lightweight status response returned by the polling endpoint.
  #
  # @attr_reader checkout_id            [String]      checkout identifier
  # @attr_reader status                 [String]      current status
  # @attr_reader tx_hash                [String, nil] on-chain transaction hash
  # @attr_reader confirmations          [Integer]     current confirmation count
  # @attr_reader required_confirmations [Integer]     confirmations needed
  # @attr_reader detected_at            [String, nil] ISO-8601 detection timestamp
  # @attr_reader confirmed_at           [String, nil] ISO-8601 confirmation timestamp
  # @attr_reader polling_interval_ms    [Integer]     suggested polling interval
  class CheckoutStatus
    ATTRS = %i[
      checkout_id status tx_hash
      confirmations required_confirmations
      detected_at confirmed_at polling_interval_ms
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
    # @return [BillingIO::CheckoutStatus]
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
      "#<BillingIO::CheckoutStatus checkout_id=#{@checkout_id.inspect} status=#{@status.inspect} confirmations=#{@confirmations.inspect}/#{@required_confirmations.inspect}>"
    end
  end
end
