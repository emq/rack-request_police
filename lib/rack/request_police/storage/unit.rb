module Rack
  module RequestPolice
    module Storage
      class Unit < Struct.new(:method, :ip, :url, :time, :data, :headers)
      end
    end
  end
end
