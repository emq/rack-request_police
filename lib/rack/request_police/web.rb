require 'rack/request_police/web_helpers'
require 'sinatra/base'
require 'erb'

module Rack
  module RequestPolice
    class Web < Sinatra::Base
      helpers WebHelpers

      set :root, ::File.expand_path(::File.dirname(__FILE__) + "/../../../web")

      get '/' do
        @count = (params[:count] || 25).to_i
        (@current_page, @total_size, @logs) = Rack::RequestPolice.storage.page(params[:page], @count)

        erb :index
      end
    end
  end
end
