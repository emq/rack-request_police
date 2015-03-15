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
              request_params.merge!('data' => utf8_input(env))
            end

            request_params.merge!(request_headers(env))

            ::Rack::RequestPolice.storage.log_request(request_params)
          end
        end

        @app.call(env)
      end

      private

      def request_headers(env)
        Rack::RequestPolice.headers.each_with_object({}) do |header_hash, result|
          header_name    = header_hash.fetch(:original_header_name)
          transformation = header_hash.fetch(:transformation)

          fallback_value = header_hash.fetch(:fallback_value)
          storage_name   = header_hash.fetch(:storage_name)

          header_value = env[header_name]
          header_value = transformation.call(header_value) if header_value
          header_value ||= fallback_value

          result[storage_name] = header_value
        end
      end

      def utf8_input(env)
        env['rack.input'].read
          .force_encoding('utf-8')
          .encode('utf-8', 'utf-8', invalid: :replace, replace: '')
      end

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
