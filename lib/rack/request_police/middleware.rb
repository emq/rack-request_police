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
              'ip'     => ip_address(env),
              'method' => env['REQUEST_METHOD'].downcase,
              'time'   => Time.now.to_i
            }

            if %w(POST PATCH DELETE).include?(env['REQUEST_METHOD'])
              request_params.merge!('data' => env['rack.input'].read)
            end
            ::Rack::RequestPolice.storage.log_request(request_params)
          end
        end

        @app.call(env)
      end

      private

      def ip_address(env)
        if !env['HTTP_X_FORWARDED_FOR'] || env['HTTP_X_FORWARDED_FOR'].empty?
          env['REMOTE_ADDR']
        else
          env['HTTP_X_FORWARDED_FOR']
        end
      end
    end
  end
end
