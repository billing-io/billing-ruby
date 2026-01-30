# frozen_string_literal: true

module BillingIO
  # Represents a registered webhook endpoint.
  #
  # @attr_reader webhook_id  [String]            unique identifier (prefixed +we_+)
  # @attr_reader url         [String]            HTTPS endpoint receiving events
  # @attr_reader events      [Array<String>]     subscribed event types
  # @attr_reader secret      [String, nil]       HMAC signing secret (only on creation)
  # @attr_reader description [String, nil]       human-readable label
  # @attr_reader status      [String]            "active" or "disabled"
  # @attr_reader created_at  [String]            ISO-8601 creation timestamp
  class WebhookEndpoint
    ATTRS = %i[
      webhook_id url events secret
      description status created_at
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
    # @return [BillingIO::WebhookEndpoint]
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
      "#<BillingIO::WebhookEndpoint webhook_id=#{@webhook_id.inspect} url=#{@url.inspect} status=#{@status.inspect}>"
    end
  end
end
