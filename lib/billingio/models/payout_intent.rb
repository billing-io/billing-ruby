# frozen_string_literal: true

module BillingIO
  # Represents a payout intent (withdrawal request).
  #
  # @attr_reader payout_id        [String]      unique identifier (prefixed +po_+)
  # @attr_reader amount_usd       [Float]       payout amount in USD
  # @attr_reader chain            [String]      blockchain network
  # @attr_reader token            [String]      stablecoin token
  # @attr_reader destination      [String]      destination wallet address
  # @attr_reader tx_hash          [String, nil] on-chain transaction hash
  # @attr_reader status           [String]      payout status
  # @attr_reader metadata         [Hash, nil]   arbitrary key-value pairs
  # @attr_reader executed_at      [String, nil] ISO-8601 execution timestamp
  # @attr_reader created_at       [String]      ISO-8601 creation timestamp
  # @attr_reader updated_at       [String]      ISO-8601 last-update timestamp
  class PayoutIntent
    ATTRS = %i[
      payout_id amount_usd chain token destination
      tx_hash status metadata
      executed_at created_at updated_at
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
    # @return [BillingIO::PayoutIntent]
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
      "#<BillingIO::PayoutIntent payout_id=#{@payout_id.inspect} amount_usd=#{@amount_usd.inspect} status=#{@status.inspect}>"
    end
  end
end
