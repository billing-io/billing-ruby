# frozen_string_literal: true

require_relative "lib/billingio/version"

Gem::Specification.new do |spec|
  spec.name          = "billingio"
  spec.version       = BillingIO::VERSION
  spec.authors       = ["billing.io"]
  spec.email         = ["support@billing.io"]

  spec.summary       = "Ruby SDK for the billing.io crypto checkout API"
  spec.description   = "Official Ruby client for billing.io -- non-custodial crypto " \
                        "payment checkouts with stablecoin settlement. Create checkouts, " \
                        "manage webhooks, verify signatures, and query event history."
  spec.homepage      = "https://github.com/billingio/billingio-ruby"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "homepage_uri"      => spec.homepage,
    "source_code_uri"   => "https://github.com/billingio/billingio-ruby",
    "changelog_uri"     => "https://github.com/billingio/billingio-ruby/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://docs.billing.io",
    "bug_tracker_uri"   => "https://github.com/billingio/billingio-ruby/issues"
  }

  spec.files = Dir["lib/**/*.rb"] + ["billingio.gemspec", "Gemfile", "README.md"]
  spec.require_paths = ["lib"]

  # Zero runtime dependencies -- stdlib only (net/http, openssl, json, cgi).
end
