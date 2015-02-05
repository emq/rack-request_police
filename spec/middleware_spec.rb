require 'spec_helper'

describe "My Middleware", type: :request do
  before do
    Timecop.freeze

    Rack::RequestPolice.configure do |c|
      c.storage = DummyStorage.new
      c.regex = nil
      c.method = [:get, :post, :delete, :patch]
    end
  end
  after  { Timecop.return }

  context "logging all requests" do
    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware)
        get '/' do
        end
      end
    }

    it "logs request without query params" do
      expect_any_instance_of(DummyStorage).to receive(:log_request)
        .with('url' => "http://example.org/", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/'

      expect(last_response.status).to eq 200
    end

    it "logs request with query params" do
      expect_any_instance_of(DummyStorage).to receive(:log_request)
        .with('url' => "http://example.org/?what-the&hell=", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/?what-the&hell='

      expect(last_response.status).to eq 200
    end
  end

  context "logging only POST requests" do
    before do
      Rack::RequestPolice.configure do |c|
        c.method = [:post]
      end
    end

    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware)
        get '/' do
        end
        post '/form' do
        end
      end
    }

    it "ignores get requests" do
      expect_any_instance_of(DummyStorage).not_to receive(:log_request)
      get '/'
      expect(last_response.status).to eq 200
    end

    it "logs post request with request data" do
      expect_any_instance_of(DummyStorage).to receive(:log_request)
        .with('url' => "http://example.org/form", 'ip' => "127.0.0.1", 'method' => "post", 'time' => Time.now.to_i, 'data' => 'user[name]=john&user[email]=john%40test.com')

      post '/form', { user: { name: 'john', email: 'john@test.com' } }

      expect(last_response.status).to eq 200
    end
  end

  context "logging PATCH requests" do
    before do
      Rack::RequestPolice.configure do |c|
        c.method = [:patch]
      end
    end

    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware)
        patch '/update' do
        end
      end
    }

    it "logs patch request with request data" do
      expect_any_instance_of(DummyStorage).to receive(:log_request)
        .with('url' => "http://example.org/update", 'ip' => "127.0.0.1", 'method' => "patch", 'time' => Time.now.to_i, 'data' => 'user[name]=john')

      patch '/update', { user: { name: 'john' } }

      expect(last_response.status).to eq 200
    end
  end

  context "logging DELETE requests" do
    before do
      Rack::RequestPolice.configure do |c|
        c.method = [:delete]
      end
    end

    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware)
        delete '/destroy' do
        end
      end
    }

    it "logs delete request with request data" do
      expect_any_instance_of(DummyStorage).to receive(:log_request)
        .with('url' => "http://example.org/destroy", 'ip' => "127.0.0.1", 'method' => "delete", 'time' => Time.now.to_i, 'data' => 'user[id]=1')

      delete '/destroy', { user: { id: 1 } }

      expect(last_response.status).to eq 200
    end
  end

  context "logging requests via regex expression" do
    before do
      Rack::RequestPolice.configure do |c|
        c.regex = /user/
      end
    end

    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware)
        get '/user' do
        end
        get '/account' do
        end
      end
    }

    it "ignores queries that does not match given regex" do
      expect_any_instance_of(DummyStorage).not_to receive(:log_request)
      get '/account'
      expect(last_response.status).to eq 200
    end

    it "logs matching queries" do
      expect_any_instance_of(DummyStorage).to receive(:log_request)
        .with('url' => "http://example.org/user", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/user'

      expect(last_response.status).to eq 200
    end
  end

  context "logging request via regex expression (with params)" do
    before do
      Rack::RequestPolice.configure do |c|
        c.regex = /user\?id=1/
      end
    end

    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware)
        get '/user' do
        end
      end
    }

    it "ignores queries that does not match given regex" do
      expect_any_instance_of(DummyStorage).not_to receive(:log_request)
      get '/user?id=2'
      expect(last_response.status).to eq 200
    end

    it "logs matching queries" do
      expect_any_instance_of(DummyStorage).to receive(:log_request)
        .with('url' => "http://example.org/user?id=1", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/user?id=1'

      expect(last_response.status).to eq 200
    end
  end

  context "logging without storage" do
    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware)
      end
    }

    it 'raises an error' do
      Rack::RequestPolice.storage = nil
      get '/'
      expect(last_response.status).to eq 500
    end
  end
end
