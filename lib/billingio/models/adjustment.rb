# frozen_string_literal: true

module BillingIO
  # Represents a revenue adjustment (credit, debit, or correction).
  #
  # @attr_reader adjustment_id [String]      unique identifier (prefixed +adj_+)
  # @attr_reader type          [String]      adjustment type (e.g. "credit", "debit", "correction")
  # @attr_reader amount_usd    [Float]       adjustment amount in USD
  # @attr_reader reason        [String, nil] human-readable reason
  # @attr_reader customer_id   [String, nil] related customer
  # @attr_reader metadata      [Hash, nil]   arbitrary key-value pairs
  # @attr_reader created_at    [String]      ISO-8601 creation timestamp
  class Adjustment
    ATTRS = %i[
      adjustment_id type amount_usd reason
      customer_id metadata created_at
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
    # @return [BillingIO::Adjustment]
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
      "#<BillingIO::Adjustment adjustment_id=#{@adjustment_id.inspect} type=#{@type.inspect} amount_usd=#{@amount_usd.inspect}>"
    end
  end
end
