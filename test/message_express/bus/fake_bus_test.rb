require 'test_helper'

require 'faker'
require 'message_express/bus/fake_bus'
require 'message_express/message'

describe MessageExpress::Bus::FakeBus do
  class InventoryItemCreated < MessageExpress::Message
    define do
      {
        'id' => _String,
        'name' => _String
      }
    end
  end

  it 'allow to fake a simple bus system' do
    bus = MessageExpress::Bus::FakeBus.new
    message_sent = InventoryItemCreated.coerce!('id' => SecureRandom.uuid,
                                                'name' => Faker::TvShows::RickAndMorty.character)

    bus.subscribe do |message|
      @message_received = message
    end

    bus.publish message_sent

    @message_received.must_equal message_sent
  end
end
