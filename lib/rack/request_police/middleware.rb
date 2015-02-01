module Rack
  module RequestPolice
    class Middleware
      class NoStorageFound < StandardError; end

      def initialize(app, options = {})
        @app = app
        @storage = options[:storage] || fail(NoStorageFound)
        @method = options[:method] || [:get, :post, :delete, :patch]
        @regex = options[:match]
      end

      def call(env)
        # puts "ENV"
        # puts env
        # puts  # POST DATA
# QUERY_STRING"=>"", "PATH_INFO = "/url"
 # "REQUEST_METHOD"=>"POST" / "GET"
 # "REMOTE_ADDR"=>"127.0.0.1", "HTTP_HOST"=>"example.org"


        if @method.include?(env['REQUEST_METHOD'].downcase.to_sym)

          full_url = (env['HTTPS'] == 'on' ? 'https://' : 'http://') + env['HTTP_HOST'] + env['PATH_INFO'] + (env['QUERY_STRING'].empty? ? '' : '?' +env['QUERY_STRING'])

          if !@regex || full_url =~ @regex
            request_params = {url: full_url,
              ip: env['REMOTE_ADDR'],
              method: env['REQUEST_METHOD'].downcase,
              time: Time.now.to_i}

            request_params.merge!(data: env['rack.input'].gets) if %w(POST PATCH DELETE).include?(env['REQUEST_METHOD'])
              # puts request_params

            @storage.log_request(request_params)
          end
        end

        @app.call(env)
      end
    end
  end
end
