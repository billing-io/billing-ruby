# frozen_string_literal: true

module BillingIO
  # Represents an accounting summary report.
  #
  # @attr_reader period_start    [String]  ISO-8601 period start
  # @attr_reader period_end      [String]  ISO-8601 period end
  # @attr_reader total_revenue   [Float]   total revenue in USD
  # @attr_reader total_fees      [Float]   total fees in USD
  # @attr_reader total_net       [Float]   total net revenue in USD
  # @attr_reader transaction_count [Integer] number of transactions
  # @attr_reader currency        [String]  report currency
  class AccountingReport
    ATTRS = %i[
      period_start period_end total_revenue
      total_fees total_net transaction_count currency
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
    # @return [BillingIO::AccountingReport]
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
      "#<BillingIO::AccountingReport period_start=#{@period_start.inspect} total_revenue=#{@total_revenue.inspect}>"
    end
  end
end
