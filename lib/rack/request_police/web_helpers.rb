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

      def environment_name
        environment = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
        "[#{environment.upcase}]"
      end

      def qparams(options)
        options = options.stringify_keys
        params.merge(options).map do |key, value|
          "#{key}=#{value}"
        end.join("&")
      end

      def root_path
        "#{env['SCRIPT_NAME']}/"
      end

      def escape(text)
         ::Rack::Utils.escape_html(text)
      end

      def pretty_parse(post_data)
        JSON.pretty_generate(JSON.parse(post_data))
      rescue JSON::ParserError
        post_data
      end
    end
  end
end
