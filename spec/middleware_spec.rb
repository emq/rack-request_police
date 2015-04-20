require 'spec_helper'

describe "My Middleware", type: :request do
  before do
    Timecop.freeze

    Rack::RequestPolice.configure do |c|
      c.storage = DummyStorage.new
      c.regex = nil
      c.method = [:get, :post, :delete, :patch]
      c.headers = []
    end
  end

  after { Timecop.return }

  context "logging all requests" do
    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
        get '/' do
        end
      end
    }

    it "logs request without query params" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/'

      expect(last_response.status).to eq 200
    end

    it "logs request with query params" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/?what-the&hell=", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/?what-the&hell='

      expect(last_response.status).to eq 200
    end

    it "logs ip address from HTTP_X_FORWARDED_FOR header if avaiable" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/", 'ip' => "1.2.3.4", 'method' => "get", 'time' => Time.now.to_i)

      get '/', nil, { 'HTTP_X_FORWARDED_FOR' => '1.2.3.4' }

      expect(last_response.status).to eq 200
    end
  end

  context "logging only POST requests" do
    before do
      Rack::RequestPolice.configure do |c|
        c.regex = nil
        c.headers = []
        c.method = [:post]
      end
    end

    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
        get '/' do
        end
        post '/form' do
        end
      end
    }

    it "ignores get requests" do
      expect(Rack::RequestPolice.storage).not_to receive(:log_request)
      get '/'
      expect(last_response.status).to eq 200
    end

    it "logs post request with request data" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/form", 'ip' => "127.0.0.1", 'method' => "post", 'time' => Time.now.to_i, 'data' => 'user[name]=john&user[email]=john%40test.com')

      post '/form', { user: { name: 'john', email: 'john@test.com' } }

      expect(last_response.status).to eq 200
    end
  end

  context "logging PATCH requests" do
    before do
      Rack::RequestPolice.configure do |c|
        c.regex = nil
        c.headers = []
        c.method = [:patch]
      end
    end

    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
        patch '/update' do
        end
      end
    }

    it "logs patch request with request data" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/update", 'ip' => "127.0.0.1", 'method' => "patch", 'time' => Time.now.to_i, 'data' => 'user[name]=john')

      patch '/update', { user: { name: 'john' } }

      expect(last_response.status).to eq 200
    end
  end

  context "logging DELETE requests" do
    before do
      Rack::RequestPolice.configure do |c|
        c.regex = nil
        c.headers = []
        c.method = [:delete]
      end
    end

    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
        delete '/destroy' do
        end
      end
    }

    it "logs delete request with request data" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/destroy", 'ip' => "127.0.0.1", 'method' => "delete", 'time' => Time.now.to_i, 'data' => 'user[id]=1')

      delete '/destroy', { user: { id: 1 } }

      expect(last_response.status).to eq 200
    end
  end

  context "logging requests via regex expression" do
    before do
      Rack::RequestPolice.configure do |c|
        c.regex = /user/
        c.headers = []
      end
    end

    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
        get '/user' do
        end
        get '/account' do
        end
      end
    }

    it "ignores queries that does not match given regex" do
      expect(Rack::RequestPolice.storage).not_to receive(:log_request)
      get '/account'
      expect(last_response.status).to eq 200
    end

    it "logs matching queries" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/user", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/user'

      expect(last_response.status).to eq 200
    end
  end

  context "logging request via regex expression (with params)" do
    before do
      Rack::RequestPolice.configure do |c|
        c.regex = /user\?id=1/
        c.headers = []
      end
    end

    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
        get '/user' do
        end
      end
    }

    it "ignores queries that does not match given regex" do
      expect(Rack::RequestPolice.storage).not_to receive(:log_request)
      get '/user?id=2'
      expect(last_response.status).to eq 200
    end

    it "logs matching queries" do
      expect(Rack::RequestPolice.storage).to receive(:log_request)
        .with('url' => "http://example.org/user?id=1", 'ip' => "127.0.0.1", 'method' => "get", 'time' => Time.now.to_i)

      get '/user?id=1'

      expect(last_response.status).to eq 200
    end
  end

  context "logging without storage" do
    before do
      Rack::RequestPolice.configure do |c|
        c.storage = nil
      end
    end

    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
      end
    }

    it 'raises an error' do
      expect { get '/' }.to raise_error(Rack::RequestPolice::NoStorageFound)
    end
  end

  context "logging request with custom headers" do
    let(:app){
      Sinatra.new do
        set :show_exceptions, false
        use(Rack::RequestPolice::Middleware)
        get '/user' do
        end
      end
    }

    context 'request contains requested headers' do
      before do
        Rack::RequestPolice.configure do |c|
          c.storage = DummyStorage.new
          c.regex = nil

          c.headers = [
            "HTTP_MY_HEADER"
          ]
        end
      end

      it "logs header as it is" do
        expect(Rack::RequestPolice.storage).to receive(:log_request)
          .with({
          "url" => "http://example.org/user",
          "ip" => "127.0.0.1",
          "method" => "get",
          "time" => Time.now.to_i,
          "headers" => { "HTTP_MY_HEADER" => "MY%HEADER%VALUE" }
        })

        get '/user', {}, { 'HTTP_MY_HEADER' => 'MY%HEADER%VALUE' }

        expect(last_response.status).to eq 200
      end
    end

    context 'request contains requested headers + custom storage name + transformation' do
      before do
        Rack::RequestPolice.configure do |c|
          c.storage = DummyStorage.new
          c.regex = nil

          c.headers = [
            c.header("HTTP_MY_HEADER", storage_name: 'my_header') { |h| h.downcase.gsub('%', '_')}
          ]
        end
      end

      it "logs header as custom name and transforms it" do
        expect(Rack::RequestPolice.storage).to receive(:log_request)
          .with({
          "url" => "http://example.org/user",
          "ip" => "127.0.0.1",
          "method" => "get",
          "time" => Time.now.to_i,
          "headers" => { "my_header" => "my_header_value" }
        })

        get '/user', {}, { 'HTTP_MY_HEADER' => 'MY%HEADER%VALUE' }

        expect(last_response.status).to eq 200
      end
    end

    context "headers do not exists in request but fallback value is provided" do
      before do
        Rack::RequestPolice.configure do |c|
          c.storage = DummyStorage.new
          c.regex = nil

          c.headers = [
            c.header("HTTP_MY_HEADER",
                     storage_name: 'my_header',
                     fallback_value: 'HEADER_MISSING')  \
            { |h| h.downcase.gsub('%', '_') }
          ]
        end
      end

      it "logs headers" do
        expect(Rack::RequestPolice.storage).to receive(:log_request)
          .with({
          "url" => "http://example.org/user",
          "ip" => "127.0.0.1",
          "method" => "get",
          "time" => Time.now.to_i,
          "headers" => { 'my_header' => 'HEADER_MISSING' }
        })

        get '/user', {}, {}

        expect(last_response.status).to eq 200
      end
    end

    context 'header do not exsits in request and transformation is provided' do
      before do
        Rack::RequestPolice.configure do |c|
          c.storage = DummyStorage.new
          c.regex = nil

          c.headers = [
            c.header("HTTP_MY_HEADER", storage_name: 'my_header') { |h| h.downcase.gsub('%', '_')}
          ]
        end
      end

      it "ignores not existing header" do
        expect(Rack::RequestPolice.storage).to receive(:log_request)
          .with({
          "url" => "http://example.org/user",
          "ip" => "127.0.0.1",
          "method" => "get",
          "time" => Time.now.to_i
        })

        get '/user', {}

        expect(last_response.status).to eq 200
      end
    end

    context 'header do not exists in request, transformation and fallback value are provided' do
      before do
        Rack::RequestPolice.configure do |c|
          c.storage = DummyStorage.new
          c.regex = nil

          c.headers = [
            c.header("HTTP_MY_HEADER", storage_name: 'my_header', fallback_value: 'not found') { |h| h.downcase.gsub('%', '_')}
          ]
        end
      end

      it "logs header as custom name and falls-back to default value" do
        expect(Rack::RequestPolice.storage).to receive(:log_request)
          .with({
          "url" => "http://example.org/user",
          "ip" => "127.0.0.1",
          "method" => "get",
          "time" => Time.now.to_i,
          "headers" => { "my_header" => 'not found' }
        })

        get '/user', {}

        expect(last_response.status).to eq 200
      end
    end

    context 'headers do not exists in request, no transformation is provided' do
      before do
        Rack::RequestPolice.configure do |c|
          c.storage = DummyStorage.new
          c.regex = nil

          c.headers = [
            c.header("HTTP_MY_HEADER")
          ]
        end
      end

      it "ignores not existing header" do
        expect(Rack::RequestPolice.storage).to receive(:log_request)
          .with({
          "url" => "http://example.org/user",
          "ip" => "127.0.0.1",
          "method" => "get",
          "time" => Time.now.to_i
        })

        get '/user', {}

        expect(last_response.status).to eq 200
      end
    end

    context 'logging multiple headers' do
      before do
        Rack::RequestPolice.configure do |c|
          c.storage = DummyStorage.new
          c.regex = nil

          c.headers = [
            'HTTP_HEADER_1',
            'HTTP_HEADER_2',
            'HTTP_HEADER_3'
          ]
        end
      end

      it 'logs all declared headers' do
        expect(Rack::RequestPolice.storage).to receive(:log_request)
          .with({
          "url" => "http://example.org/user",
          "ip" => "127.0.0.1",
          "method" => "get",
          "time" => Time.now.to_i,
          "headers" => { 'HTTP_HEADER_1' => "one", 'HTTP_HEADER_3' => 'two' }
        })

        get '/user', {}, { 'HTTP_HEADER_1' => 'one', 'HTTP_HEADER_3' => 'two' }

        expect(last_response.status).to eq 200
      end
    end
  end
end
