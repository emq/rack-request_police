module Rack
  module RequestPolice
    class Middleware
      class NoStorageFound < StandardError; end

      def initialize(app)
        @app = app
      end

      def call(env)
        if ::Rack::RequestPolice.method.include?(env['REQUEST_METHOD'].downcase.to_sym)
          full_url = ''
          full_url << (env['HTTPS'] == 'on' ? 'https://' : 'http://')
          full_url << env['HTTP_HOST'] << env['PATH_INFO']
          full_url << '?' << env['QUERY_STRING'] unless env['QUERY_STRING'].empty?

          if !::Rack::RequestPolice.regex || full_url =~ ::Rack::RequestPolice.regex
            request_params = {
              'url'    => full_url,
              'ip'     => env['REMOTE_ADDR'],
              'method' => env['REQUEST_METHOD'].downcase,
              'time'   => Time.now.to_i
            }

            if %w(POST PATCH DELETE).include?(env['REQUEST_METHOD'])
              request_params.merge!('data' => env['rack.input'].gets)
            end
            ::Rack::RequestPolice.storage.log_request(request_params)
          end
        end

        @app.call(env)
      end
    end
  end
end
