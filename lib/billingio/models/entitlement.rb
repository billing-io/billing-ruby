# frozen_string_literal: true

module BillingIO
  # Represents a subscription entitlement (feature or access grant).
  #
  # @attr_reader entitlement_id  [String]      unique identifier (prefixed +ent_+)
  # @attr_reader subscription_id [String]      parent subscription
  # @attr_reader feature_key     [String]      machine-readable feature identifier
  # @attr_reader value           [Object, nil] entitlement value (boolean, numeric, or string)
  # @attr_reader metadata        [Hash, nil]   arbitrary key-value pairs
  # @attr_reader created_at      [String]      ISO-8601 creation timestamp
  # @attr_reader updated_at      [String]      ISO-8601 last-update timestamp
  class Entitlement
    ATTRS = %i[
      entitlement_id subscription_id feature_key
      value metadata created_at updated_at
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
    # @return [BillingIO::Entitlement]
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
      "#<BillingIO::Entitlement entitlement_id=#{@entitlement_id.inspect} feature_key=#{@feature_key.inspect}>"
    end
  end
end
