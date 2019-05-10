require 'test_helper'

require 'faker'
require 'kafka'
require 'message_express/bus/kafka'
require 'message_express/message'

describe MessageExpress::Bus::Kafka do
  class InventoryItemCreated < MessageExpress::Message
    define do
      {
        'id' => _String,
        'name' => _String
      }
    end
  end

  describe '#publish' do
    # We should find a way to test it without mocking the whole library.
    # You can still use this test if needed but it will be blocking on `kafka_client.each_message`
    # it 'publish the message to kafka' do
    #   kafka_client = Kafka.new([ENV['KAFKA_SEED_BROKER']])
    #   bus = MessageExpress::Bus::Kafka.new(kafka_client)
    #   message = InventoryItemCreated.coerce!('id' => SecureRandom.uuid,
    #                                        'name' => Faker::RickAndMorty.character)

    #   bus.publish message

    #   kafka_client.each_message(topic: 'messages') do |message|
    #     puts message.offset, message.key, message.value
    #   end
    # end
  end
end
