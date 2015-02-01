module Rack
  module RequestPolice
    module Storage
      class Base
        def log_request(request_params)
          raise NotImplementedError, "Please implement `log_request` method"
        end
      end
    end
  end
end
