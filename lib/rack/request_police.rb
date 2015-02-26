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
    @@headers = []

    def self.configure
      yield self
    end

    def self.storage=(obj)
      @@storage = obj
    end

    def self.storage
      @@storage || fail(NoStorageFound)
    end

    def self.headers
      @@headers
    end

    def self.headers=(array)
      @@headers = array.map do |h|
        # because headers might be simple strings
        # or a hash we need to normalize them
        # and store all as hashes
        if h.is_a?(String)
          header(h)
        else
          h
        end
      end
    end

    def self.header(original_header_name, options = {}, &transformation)
      {
        original_header_name: original_header_name,
        storage_name: options.fetch(:storage_name) { original_header_name },
        fallback_value: options.fetch(:fallback_value) { nil },
        # if user provided no transformation,
        # simply return original header value
        transformation: transformation || ->(h){ h }
      }
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
