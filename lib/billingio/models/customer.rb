# frozen_string_literal: true

module BillingIO
  # Represents a customer record.
  #
  # @attr_reader customer_id [String]      unique identifier (prefixed +cus_+)
  # @attr_reader email       [String, nil] customer email address
  # @attr_reader name        [String, nil] customer display name
  # @attr_reader metadata    [Hash, nil]   arbitrary key-value pairs
  # @attr_reader status      [String]      customer status
  # @attr_reader created_at  [String]      ISO-8601 creation timestamp
  # @attr_reader updated_at  [String]      ISO-8601 last-update timestamp
  class Customer
    ATTRS = %i[
      customer_id email name metadata
      status created_at updated_at
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
    # @return [BillingIO::Customer]
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
      "#<BillingIO::Customer customer_id=#{@customer_id.inspect} email=#{@email.inspect} status=#{@status.inspect}>"
    end
  end
end
