require 'spec_helper'

describe 'Redis storage' do
  after  { REDIS.flushdb }
  before { REDIS.flushdb }

  describe '#log_request' do
    it 'pushes serialized requests params to redis list' do
      storage = Rack::RequestPolice::Storage::Redis.new(REDIS_OPTIONS)

      expect { storage.log_request({'test' => 'me'}) }
        .to change{ REDIS.llen('rack:request:police')}.by(1)
    end

    it 'can serialize using different JSON library' do
      storage = Rack::RequestPolice::Storage::Redis.new(REDIS_OPTIONS, json_parser: Oj)

      expect(Oj).to receive(:dump).with({'test' => 'me'})
      storage.log_request({'test' => 'me'})
    end
  end

end
