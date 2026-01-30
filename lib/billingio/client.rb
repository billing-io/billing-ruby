# frozen_string_literal: true

module BillingIO
  # Main entry point for the billing.io API.
  #
  # @example
  #   client = BillingIO::Client.new(api_key: "sk_live_...")
  #   checkout = client.checkouts.create(
  #     amount_usd: 49.99,
  #     chain:      "tron",
  #     token:      "USDT"
  #   )
  class Client
    DEFAULT_BASE_URL = "https://api.billing.io/v1"

    # @param api_key  [String] your secret API key (sk_live_... or sk_test_...)
    # @param base_url [String] API root URL (override for testing or local dev)
    def initialize(api_key:, base_url: DEFAULT_BASE_URL)
      raise ArgumentError, "api_key is required" if api_key.nil? || api_key.empty?

      @http = HttpClient.new(api_key: api_key, base_url: base_url)
    end

    # @return [BillingIO::Checkouts]
    def checkouts
      @checkouts ||= Checkouts.new(@http)
    end

    # @return [BillingIO::Webhooks]
    def webhooks
      @webhooks ||= Webhooks.new(@http)
    end

    # @return [BillingIO::Events]
    def events
      @events ||= Events.new(@http)
    end

    # @return [BillingIO::Health]
    def health
      @health ||= Health.new(@http)
    end
  end
end
