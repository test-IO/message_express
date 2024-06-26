require 'test_helper'
require 'message_express/bus/redis_stream'

class DummyRedisClient
  def initialize
    @streams = {}
  end

  def xadd(stream, data, approximate: nil, maxlen: nil, nomkstream: nil, id: '*')
    @streams[stream] ||= []
    @streams[stream] << data
  end

  def xreadgroup(group, consumer, streams, condition, count: 1, block: 5000)
    @streams[streams] ||= []
    @streams[streams].map.with_index do |data, index|
      [streams, { index => data }]
    end
  end

  def xgroup(*args);end

  def xack(stream, group, message_id)
  end
end

describe MessageExpress::Bus::RedisStream do
  class InventoryItemCreated < MessageExpress::Message
    define do
      {
        'id' => _String,
        'name' => _String
      }
    end
  end

  it 'allow to fake a simple bus system' do
    bus = MessageExpress::Bus::RedisStream.new(DummyRedisClient.new)
    message_sent = InventoryItemCreated.coerce!('id' => SecureRandom.uuid,
    'name' => Faker::TvShows::RickAndMorty.character)

    bus.publish message_sent

    bus.subscribe() do |message|
      @message_received = message
    end


    value(@message_received.name).must_equal message_sent.name
    value(@message_received.payload).must_equal message_sent.payload
  end
end
