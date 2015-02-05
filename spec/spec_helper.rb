require 'coveralls'
Coveralls.wear!

require_relative '../lib/rack/request_police'
require_relative '../lib/rack/request_police/web'
require 'rack/test'
require 'timecop'
require 'redis'
require 'oj'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end

class DummyStorage < Rack::RequestPolice::Storage::Base
  def log_request(hash); end
end

REDIS_OPTIONS = { url: "redis://localhost/15", namespace: "rack-request-police" }
REDIS = Redis.new(REDIS_OPTIONS)
