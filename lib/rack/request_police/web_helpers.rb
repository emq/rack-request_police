module Rack
  module RequestPolice
    module WebHelpers
      def method_class(method)
        case method
        when 'get'
          'primary'
        when 'post'
          'info'
        when 'patch'
          'warning'
        else
          'danger'
        end
      end
    end
  end
end
