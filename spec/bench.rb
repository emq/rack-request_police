require 'benchmark'

describe "Simple benchmark", type: :request do
  let(:repeat) { 10_000 }
  let(:app){
    Sinatra.new do
      use(Rack::RequestPolice::Middleware)
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

  before do
    Rack::RequestPolice.configure do |c|
      c.storage = DummyStorage.new
      c.regex = nil
      c.method = [:get, :post, :delete, :patch]
    end
  end

  context "with middleware (defaults)" do
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
    Rack::RequestPolice.configure do |c|
      c.storage = DummyStorage.new
      c.regex = /.*/
      c.method = [:get, :post, :delete]
    end

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
    before do
      REDIS.flushdb
      Rack::RequestPolice.configure do |c|
        c.storage = Rack::RequestPolice::Storage::Redis.new(REDIS_OPTIONS)
        c.regex = /.*/
        c.method = [:get, :post, :delete]
      end
    end

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
    before do
      REDIS.flushdb
      Rack::RequestPolice.configure do |c|
        c.storage = Rack::RequestPolice::Storage::Redis.new(REDIS_OPTIONS, json_parser: Oj)
        c.regex = /.*/
        c.method = [:get, :post, :delete]
      end
    end

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
