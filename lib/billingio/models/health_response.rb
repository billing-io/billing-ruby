# frozen_string_literal: true

module BillingIO
  # Represents the API health check response.
  #
  # @attr_reader status  [String] service health ("healthy")
  # @attr_reader version [String] API version (e.g. "1.0.0")
  class HealthResponse
    ATTRS = %i[status version].freeze

    attr_reader(*ATTRS)

    # @param attrs [Hash{String,Symbol => Object}]
    def initialize(attrs = {})
      ATTRS.each do |attr|
        value = attrs[attr.to_s] || attrs[attr]
        instance_variable_set(:"@#{attr}", value)
      end
    end

    # @param hash [Hash]
    # @return [BillingIO::HealthResponse]
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
      "#<BillingIO::HealthResponse status=#{@status.inspect} version=#{@version.inspect}>"
    end
  end
end
