# frozen_string_literal: true

require "openssl"
require "json"

module BillingIO
  # Verifies webhook signatures sent by billing.io.
  #
  # The +X-Billing-Signature+ header has the format:
  #   t={unix_timestamp},v1={hex_hmac_sha256}
  #
  # The signed payload is: "{timestamp}.{raw_body}"
  module WebhookSignature
    # Default tolerance window in seconds (5 minutes).
    DEFAULT_TOLERANCE = 300

    # Header name used by billing.io for the signature.
    SIGNATURE_HEADER = "X-Billing-Signature"

    module_function

    # Verify a webhook payload and return the parsed event Hash.
    #
    # @param payload   [String]  raw request body (unparsed JSON)
    # @param header    [String]  value of the X-Billing-Signature header
    # @param secret    [String]  webhook endpoint secret (whsec_...)
    # @param tolerance [Integer] max age of the event in seconds (default 300)
    # @return [Hash] the parsed webhook event
    # @raise [BillingIO::WebhookVerificationError] on any verification failure
    def verify(payload:, header:, secret:, tolerance: DEFAULT_TOLERANCE)
      raise WebhookVerificationError, "Missing signature header" if header.nil? || header.empty?
      raise WebhookVerificationError, "Missing webhook secret"   if secret.nil? || secret.empty?

      timestamp, signature = parse_header(header)

      # Timestamp tolerance check
      now = Time.now.to_i
      if (now - timestamp).abs > tolerance
        raise WebhookVerificationError,
              "Timestamp outside tolerance. Event: #{timestamp}, now: #{now}, tolerance: #{tolerance}s"
      end

      # Compute expected HMAC-SHA256
      signed_payload = "#{timestamp}.#{payload}"
      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, signed_payload)

      unless secure_compare(expected, signature)
        raise WebhookVerificationError, "Signature mismatch"
      end

      # Parse and return the event
      begin
        JSON.parse(payload)
      rescue JSON::ParserError
        raise WebhookVerificationError, "Invalid JSON in webhook body"
      end
    end

    # Parse the "t=...,v1=..." header into [timestamp, signature].
    #
    # @param header [String]
    # @return [Array(Integer, String)]
    # @raise [BillingIO::WebhookVerificationError]
    def parse_header(header)
      parts = {}
      header.split(",").each do |segment|
        key, *rest = segment.split("=")
        parts[key.strip] = rest.join("=").strip
      end

      timestamp = Integer(parts["t"], 10) rescue nil
      signature = parts["v1"]

      if timestamp.nil? || signature.nil? || signature.empty?
        raise WebhookVerificationError,
              "Invalid signature header format. Expected: t={timestamp},v1={signature}"
      end

      [timestamp, signature]
    end

    # Constant-time string comparison to prevent timing attacks.
    # Uses OpenSSL.fixed_length_secure_compare (available Ruby 2.7+)
    # with a fallback to a manual XOR-based comparison.
    #
    # @param a [String]
    # @param b [String]
    # @return [Boolean]
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      if OpenSSL.respond_to?(:fixed_length_secure_compare)
        OpenSSL.fixed_length_secure_compare(a, b)
      else
        a_bytes = a.unpack("C*")
        b_bytes = b.unpack("C*")

        result = 0
        a_bytes.each_with_index do |byte, i|
          result |= byte ^ b_bytes[i]
        end

        result.zero?
      end
    end

    private_class_method :parse_header, :secure_compare
  end
end
