# frozen_string_literal: true

module BillingIO
  # Raised when the billing.io API returns a non-2xx response.
  #
  # Attributes correspond to the error envelope documented in the API spec:
  #   { "error": { "type", "code", "message", "param" } }
  class Error < StandardError
    attr_reader :type, :code, :status_code, :param

    # @param message      [String]       human-readable error description
    # @param type         [String, nil]  error category (e.g. "invalid_request")
    # @param code         [String, nil]  machine-readable code (e.g. "missing_required_field")
    # @param status_code  [Integer, nil] HTTP status code
    # @param param        [String, nil]  request parameter that triggered the error
    def initialize(message = nil, type: nil, code: nil, status_code: nil, param: nil)
      @type        = type
      @code        = code
      @status_code = status_code
      @param       = param
      super(message)
    end

    # Build an Error from the parsed JSON error envelope and HTTP status.
    #
    # @param body        [Hash]    parsed response body
    # @param status_code [Integer] HTTP status code
    # @return [BillingIO::Error]
    def self.from_response(body, status_code)
      err = body["error"] || {}
      new(
        err["message"] || "Unknown error (HTTP #{status_code})",
        type:        err["type"],
        code:        err["code"],
        status_code: status_code,
        param:       err["param"]
      )
    end
  end

  # Raised when webhook signature verification fails.
  class WebhookVerificationError < StandardError; end
end
