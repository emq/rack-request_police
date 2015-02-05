require 'spec_helper'

describe "Web interface", type: :request do
  before { Rack::RequestPolice.storage = Rack::RequestPolice::Storage::Redis.new(REDIS_OPTIONS) }
  let!(:app){ Rack::RequestPolice::Web }

  context "when there are logged requests" do
    before do
      Rack::RequestPolice.storage.log_request(method: 'get', ip: '127.0.0.1', url: 'example.com', time: Time.now.to_i)
      get '/'
    end

    after  { REDIS.flushdb }

    it "is successful" do
      expect(last_response.status).to eq 200
    end

    it "displays logged request" do
      expect(last_response.body).to match(/127\.0\.0\.1.*example\.com/m)
    end
  end

  context "when there is none logged requests" do
    before { get '/' }

    it "is successful" do
      expect(last_response.status).to eq 200
    end

    it "displays proper information" do
      expect(last_response.body).to match(/No requests logged/)
    end
  end
end
