require "json"
require "rack/request_police/version"
require "rack/request_police/storage/base"
require "rack/request_police/storage/redis"
require "rack/request_police/storage/unit"
require "rack/request_police/middleware"

module Rack
  module RequestPolice
    class NoStorageFound < StandardError; end

    @@storage = nil
    @@method  = [:get, :post, :delete, :patch]
    @@regex   = nil

    def self.configure
      yield self
    end

    def self.storage=(obj)
      @@storage = obj
    end

    def self.storage
      @@storage || fail(NoStorageFound)
    end

    def self.method
      @@method
    end

    def self.method=(array)
      @@method = array
    end

    def self.regex
      @@regex
    end

    def self.regex=(regular_expression)
      @@regex = regular_expression
    end
  end
end
