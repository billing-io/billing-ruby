# frozen_string_literal: true

module BillingIO
  # Represents a payout settlement record.
  #
  # @attr_reader settlement_id [String]      unique identifier (prefixed +stl_+)
  # @attr_reader payout_id     [String]      parent payout intent
  # @attr_reader amount_usd    [Float]       settled amount in USD
  # @attr_reader fee_usd       [Float]       fee amount in USD
  # @attr_reader net_usd       [Float]       net amount in USD
  # @attr_reader chain         [String]      blockchain network
  # @attr_reader token         [String]      stablecoin token
  # @attr_reader tx_hash       [String, nil] on-chain transaction hash
  # @attr_reader status        [String]      settlement status
  # @attr_reader settled_at    [String, nil] ISO-8601 settlement timestamp
  # @attr_reader created_at    [String]      ISO-8601 creation timestamp
  class Settlement
    ATTRS = %i[
      settlement_id payout_id amount_usd fee_usd net_usd
      chain token tx_hash status
      settled_at created_at
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
    # @return [BillingIO::Settlement]
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
      "#<BillingIO::Settlement settlement_id=#{@settlement_id.inspect} amount_usd=#{@amount_usd.inspect} status=#{@status.inspect}>"
    end
  end
end
