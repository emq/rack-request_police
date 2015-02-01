module Rack
  module RequestPolice
    module Storage
      class Redis < Base
        def log_request(request_params)
          true
        end
      end
    end
  end
end
