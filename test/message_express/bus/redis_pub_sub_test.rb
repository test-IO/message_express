require 'test_helper'
require 'message_express/bus/redis_pub_sub'

class DummyPubSubRedisClient
  def initialize
    @channels = {}
  end

  def publish(channel, message)
    puts "Publishing to channel #{channel}"
    @channels[channel].each do |block|
      block.call(channel, message)
    end
  end

  def subscribe(channel, &block)
    puts "Subscribing to channel #{channel}"
    @channels[channel] ||= []
    @channels[channel] << Proc.new do |chan, msg|
      yield ::OpenStruct.new(message: lambda { |c, m| yield(c, m) })
    end
  end
end

describe MessageExpress::Bus::RedisPubSub do
  class InventoryItemCreated < MessageExpress::Message
    define do
      {
        'id' => _String,
        'name' => _String
      }
    end
  end

  it 'allow to fake a simple bus system' do
    bus = MessageExpress::Bus::RedisPubSub.new(DummyPubSubRedisClient.new)
    message_sent = InventoryItemCreated.coerce!('id' => SecureRandom.uuid,
                                                'name' => Faker::TvShows::RickAndMorty.character)

    bus.subscribe() do |message|
      value(message.name).must_equal message_sent.name
      value(message.payload).must_equal message_sent.payload
      puts "Message received: #{message.name} - #{message.payload}"
    end

    bus.publish message_sent
  end
end


