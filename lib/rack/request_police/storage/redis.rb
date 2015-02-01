module Rack
  module RequestPolice
    module Storage
      class Redis < Base
        attr_reader :redis, :parser

        def initialize(hash_of_options, json_parser: JSON)
          @redis = ::Redis.new(hash_of_options)
          @parser = json_parser
        end

        def log_request(request_params)
          redis.lpush('rack:request:police', parser.dump(request_params))
        end
      end
    end
  end
end
