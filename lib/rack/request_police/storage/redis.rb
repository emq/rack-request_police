module Rack
  module RequestPolice
    module Storage
      class Redis < Base
        REDIS_KEY = 'rack:request:police'.freeze

        attr_reader :redis, :parser

        def initialize(hash_of_options, json_parser: JSON)
          @redis = ::Redis.new(hash_of_options)
          @parser = json_parser
        end

        def log_request(request_params)
          redis.lpush(REDIS_KEY, parser.dump(request_params))
        end

        def page(pageidx = 1, page_size = 25)
          current_page = pageidx.to_i < 1 ? 1 : pageidx.to_i
          pageidx      = current_page - 1
          total_size   = 0
          items        = []
          starting     = pageidx * page_size
          ending       = starting + page_size - 1

          total_size = redis.llen(REDIS_KEY)
          items      = redis.lrange(REDIS_KEY, starting, ending).map do |json|
            hash = parser.load(json)
            Unit.new(hash['method'], hash['ip'], hash['url'], Time.at(hash['time']), hash['data'], hash['headers'])
          end

          [current_page, total_size, items]
        end

      end
    end
  end
end
