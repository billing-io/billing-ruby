# frozen_string_literal: true

module BillingIO
  # Represents the result of an entitlement check.
  #
  # @attr_reader entitled   [Boolean]     whether the customer has the entitlement
  # @attr_reader feature_key [String]     the feature key that was checked
  # @attr_reader value       [Object, nil] entitlement value if entitled
  class EntitlementCheck
    ATTRS = %i[entitled feature_key value].freeze

    attr_reader(*ATTRS)

    # @param attrs [Hash{String,Symbol => Object}]
    def initialize(attrs = {})
      ATTRS.each do |attr|
        value = attrs[attr.to_s] || attrs[attr]
        instance_variable_set(:"@#{attr}", value)
      end
    end

    # @param hash [Hash]
    # @return [BillingIO::EntitlementCheck]
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
      "#<BillingIO::EntitlementCheck feature_key=#{@feature_key.inspect} entitled=#{@entitled.inspect}>"
    end
  end
end
