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

    def self.storage=(obj)
      @@storage = obj
    end

    def self.storage
      @@storage || fail(NoStorageFound)
    end
  end
end
