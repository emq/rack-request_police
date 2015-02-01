require 'benchmark'
require 'oj'

describe "Simple benchmark", type: :request do
  let(:repeat) { 10_000 }

  context "with middleware (defaults)" do
    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware, storage: DummyStorage.new)
        get '/' do
        end
        post '/' do
        end
        delete '/' do
        end
        patch '/' do
        end
      end
    }

    it "benchmarks it" do
      puts "with middleware (defaults)"
      Benchmark.bm(7) do |x|
        x.report("get") { repeat.times { get '/' } }
        x.report("post") { repeat.times { post '/' } }
        x.report("delete") { repeat.times { delete '/' } }
        x.report("patch") { repeat.times { patch '/' } }
      end
    end
  end

  context "with middleware (customized)" do
    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware, storage: DummyStorage.new, method: [:get, :post, :delete], matching: /.*/)
        get '/' do
        end
        post '/' do
        end
        delete '/' do
        end
        patch '/' do
        end
      end
    }

    it "benchmarks it" do
      puts "with middleware (customized)"
      Benchmark.bm(7) do |x|
        x.report("get") { repeat.times { get '/' } }
        x.report("post") { repeat.times { post '/' } }
        x.report("delete") { repeat.times { delete '/' } }
        x.report("patch") { repeat.times { patch '/' } }
      end
    end
  end

  context "with middleware (customized, redis storage)" do
    after  { REDIS.flushdb }
    before { REDIS.flushdb }

    let!(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware, storage: Rack::RequestPolice::Storage::Redis.new(REDIS_OPTIONS), method: [:get, :post, :delete], matching: /.*/)
        get '/' do
        end
        post '/' do
        end
        delete '/' do
        end
        patch '/' do
        end
      end
    }

    it "benchmarks it" do
      puts "with middleware (customized, redis storage)"
      Benchmark.bm(7) do |x|
        x.report("get") { repeat.times { get '/' } }
        x.report("post") { repeat.times { post '/' } }
        x.report("delete") { repeat.times { delete '/' } }
        x.report("patch") { repeat.times { patch '/' } }
      end
    end
  end

  context "with middleware (customized, redis storage, OJ json parser)" do
    after  { REDIS.flushdb }
    before { REDIS.flushdb }

    let(:app){
      Sinatra.new do
        use(Rack::RequestPolice::Middleware, storage: Rack::RequestPolice::Storage::Redis.new(REDIS_OPTIONS, json_parser: Oj), method: [:get, :post, :delete], matching: /.*/)
        get '/' do
        end
        post '/' do
        end
        delete '/' do
        end
        patch '/' do
        end
      end
    }

    it "benchmarks it" do
      puts "with middleware (customized, redis storage, OJ parser)"
      Benchmark.bm(7) do |x|
        x.report("get") { repeat.times { get '/' } }
        x.report("post") { repeat.times { post '/' } }
        x.report("delete") { repeat.times { delete '/' } }
        x.report("patch") { repeat.times { patch '/' } }
      end
    end
  end

  context "without middleware" do
    let(:app){
      Sinatra.new do
        get '/' do
        end
        post '/' do
        end
        delete '/' do
        end
        patch '/' do
        end
      end
    }

    it "benchmarks it" do
      puts "without middleware"
      Benchmark.bm(7) do |x|
        x.report("get") { repeat.times { get '/' } }
        x.report("post") { repeat.times { post '/' } }
        x.report("delete") { repeat.times { delete '/' } }
        x.report("patch") { repeat.times { patch '/' } }
      end
    end
  end
end
