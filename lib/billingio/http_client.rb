# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module BillingIO
  # @api private
  #
  # Thin wrapper around Net::HTTP that handles authentication,
  # JSON serialization, and error mapping.  Every public resource
  # class delegates its HTTP work here.
  class HttpClient
    # @param api_key  [String] bearer token (sk_live_... / sk_test_...)
    # @param base_url [String] API root including version path
    def initialize(api_key:, base_url:)
      @api_key  = api_key
      @base_url = base_url.chomp("/")
    end

    # ---- HTTP verbs -------------------------------------------------------

    def get(path, params = {})
      uri = build_uri(path, params)
      request = Net::HTTP::Get.new(uri)
      execute(uri, request)
    end

    def post(path, body = nil, headers = {})
      uri = build_uri(path)
      request = Net::HTTP::Post.new(uri)
      if body
        request.body = JSON.generate(body)
        request["Content-Type"] = "application/json"
      end
      headers.each { |k, v| request[k] = v }
      execute(uri, request)
    end

    def patch(path, body = nil)
      uri = build_uri(path)
      request = Net::HTTP::Patch.new(uri)
      if body
        request.body = JSON.generate(body)
        request["Content-Type"] = "application/json"
      end
      execute(uri, request)
    end

    def delete(path)
      uri = build_uri(path)
      request = Net::HTTP::Delete.new(uri)
      execute(uri, request)
    end

    private

    def build_uri(path, params = {})
      uri = URI("#{@base_url}#{path}")
      unless params.empty?
        query = params.reject { |_, v| v.nil? }
                      .map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }
                      .join("&")
        uri.query = query unless query.empty?
      end
      uri
    end

    def execute(uri, request)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Accept"]        = "application/json"
      request["User-Agent"]    = "billingio-ruby/#{BillingIO::VERSION}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = 30
      http.read_timeout = 60

      response = http.request(request)
      handle_response(response)
    end

    def handle_response(response)
      status = response.code.to_i

      # 204 No Content -- nothing to parse
      return nil if status == 204

      body = parse_body(response)

      if status >= 200 && status < 300
        body
      else
        raise Error.from_response(body.is_a?(Hash) ? body : {}, status)
      end
    end

    def parse_body(response)
      return {} if response.body.nil? || response.body.empty?

      JSON.parse(response.body)
    rescue JSON::ParserError
      { "error" => { "message" => response.body } }
    end
  end
end
