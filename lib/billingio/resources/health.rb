# frozen_string_literal: true

module BillingIO
  # Provides access to the health check endpoint.
  #
  #   client.health.get
  class Health
    # @api private
    def initialize(http_client)
      @http = http_client
    end

    # Check API health.
    #
    # @return [BillingIO::HealthResponse]
    # @raise [BillingIO::Error]
    def get
      data = @http.get("/health")
      HealthResponse.from_hash(data)
    end
  end
end
