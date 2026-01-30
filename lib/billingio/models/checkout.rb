# frozen_string_literal: true

module BillingIO
  # Represents a payment checkout.
  #
  # @attr_reader checkout_id            [String]      unique identifier (prefixed +co_+)
  # @attr_reader deposit_address        [String]      blockchain address to send funds to
  # @attr_reader chain                  [String]      blockchain network ("tron" | "arbitrum")
  # @attr_reader token                  [String]      stablecoin token ("USDT" | "USDC")
  # @attr_reader amount_usd             [Float]       original USD amount
  # @attr_reader amount_atomic          [String]      token amount in smallest unit
  # @attr_reader status                 [String]      current checkout status
  # @attr_reader tx_hash                [String, nil] on-chain transaction hash
  # @attr_reader confirmations          [Integer]     current confirmation count
  # @attr_reader required_confirmations [Integer]     confirmations needed
  # @attr_reader expires_at             [String]      ISO-8601 expiry timestamp
  # @attr_reader detected_at            [String, nil] ISO-8601 detection timestamp
  # @attr_reader confirmed_at           [String, nil] ISO-8601 confirmation timestamp
  # @attr_reader created_at             [String]      ISO-8601 creation timestamp
  # @attr_reader metadata               [Hash, nil]   arbitrary key-value pairs
  class Checkout
    ATTRS = %i[
      checkout_id deposit_address chain token
      amount_usd amount_atomic status tx_hash
      confirmations required_confirmations
      expires_at detected_at confirmed_at created_at
      metadata
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
    # @return [BillingIO::Checkout]
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
      "#<BillingIO::Checkout checkout_id=#{@checkout_id.inspect} status=#{@status.inspect} amount_usd=#{@amount_usd.inspect}>"
    end
  end
end
