# frozen_string_literal: true

module BillingIO
  # Convenience module matching the public API contract:
  #
  #   BillingIO::Webhook.verify_signature(payload:, header:, secret:)
  #
  # Delegates to {BillingIO::WebhookSignature.verify}.
  module Webhook
    module_function

    # Verify a webhook payload and return the parsed event Hash.
    #
    # @param payload   [String]  raw request body (unparsed JSON)
    # @param header    [String]  value of the X-Billing-Signature header
    # @param secret    [String]  webhook endpoint secret (whsec_...)
    # @param tolerance [Integer] max age of the event in seconds (default 300)
    # @return [Hash] the parsed webhook event
    # @raise [BillingIO::WebhookVerificationError] on any verification failure
    def verify_signature(payload:, header:, secret:, tolerance: WebhookSignature::DEFAULT_TOLERANCE)
      WebhookSignature.verify(
        payload:   payload,
        header:    header,
        secret:    secret,
        tolerance: tolerance
      )
    end
  end
end
