# frozen_string_literal: true

require "cgi"

require_relative "billingio/version"
require_relative "billingio/errors"
require_relative "billingio/http_client"
require_relative "billingio/webhook_signature"
require_relative "billingio/webhook"

# Models
require_relative "billingio/models/checkout"
require_relative "billingio/models/checkout_status"
require_relative "billingio/models/webhook_endpoint"
require_relative "billingio/models/event"
require_relative "billingio/models/health_response"
require_relative "billingio/models/paginated_list"

# Resources
require_relative "billingio/resources/checkouts"
require_relative "billingio/resources/webhooks"
require_relative "billingio/resources/events"
require_relative "billingio/resources/health"

require_relative "billingio/client"
