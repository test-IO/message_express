require 'test_helper'

require 'faker'
require 'message_express/bus/fake_bus'
require 'message_express/message'
require 'message_express/message_store/memory'
require 'message_express/publisher'

describe MessageExpress::Publisher do
  class DummyPublisher
    include MessageExpress::Publisher
  end

  class InventoryItemCreated < MessageExpress::Message
    define do
      { 'id' => _String, 'name' => _String }
    end
  end

  before(:each) do
    MessageExpress.configure do |c|
      c.bus MessageExpress::Bus::FakeBus.new
      c.message_store MessageExpress::MessageStore::Memory.new
    end
  end

  describe '#publish' do
    it 'send messages to the bus' do
      publisher = DummyPublisher.new
      item_id = SecureRandom.uuid
      item_name = Faker::TvShows::RickAndMorty.character
      message = nil

      MessageExpress.config.bus.subscribe do |e|
        message = e
      end

      publisher.publish 'inventory_item_created', 'id' => item_id, 'name' => item_name

      message['id'].must_equal item_id
      message['name'].must_equal item_name
    end

    it 'allow to skip payload validation' do
      publisher = DummyPublisher.new
      item_id = SecureRandom.uuid

      publisher.publish('inventory_item_created', { 'id' => item_id }, validate: false)
      assert_raises(MessageExpress::InvalidSchema) do
        publisher.publish('inventory_item_created', 'id' => item_id)
      end
    end
  end
end
