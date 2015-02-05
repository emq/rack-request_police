module Rack
  module RequestPolice
    module Storage
      class Base
        def log_request(request_params)
          raise NotImplementedError, "Please implement `log_request` method"
        end

        def page(pageidx = 1, page_size = 25)
          raise NotImplementedError, "Please implement `page` method that will return
            [current_page_number, total_amount_of_logged_requests, array_of_paginated <Unit> objects]"
        end
      end
    end
  end
end
