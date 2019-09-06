require 'test_helper'

require 'faker'
require 'message_express/bus/fake_bus'
require 'message_express/message'
require 'message_express/message_store/memory'
require 'message_express/subscriber'
require 'rr'

describe MessageExpress::Subscriber do
  class InventoryItemCreated < MessageExpress::Message
    define do
      { 'id' => _String, 'name' => _String }
    end
  end

  class InventoryItemDeactivated < MessageExpress::Message
    define do
      { 'id' => _String }
    end
  end

  before(:each) do
    MessageExpress.configure do |c|
      c.bus MessageExpress::Bus::FakeBus.new
      c.message_store MessageExpress::MessageStore::Memory.new
    end
  end

  it 'receive message that match the given message name' do
    class DummySubscriber
      include MessageExpress::Subscriber

      on 'inventory_item_created' do |message|
        @inventory_item_created_message = message
      end

      on 'inventory_item_deactivated' do |message|
        @inventory_item_deactivated_message = message
      end
    end

    DummySubscriber.subscribe!

    item_created_id = SecureRandom.uuid
    item_deactivated_id = SecureRandom.uuid

    MessageExpress.config.bus.publish InventoryItemCreated.coerce!('id' => item_created_id,
                                                                   'name' => 'foobar')

    MessageExpress.config.bus.publish InventoryItemDeactivated.coerce!('id' => item_deactivated_id)

    DummySubscriber.instance_variable_get(:@inventory_item_created_message)['id']
                   .must_equal item_created_id
    DummySubscriber.instance_variable_get(:@inventory_item_deactivated_message)['id']
                   .must_equal item_deactivated_id
  end

  it 'allow the use of symbols' do
    class DummySubscriber
      include MessageExpress::Subscriber

      on :inventory_item_created do |message|
        @inventory_item_created_message = message
      end
    end

    DummySubscriber.subscribe!

    item_created_id = SecureRandom.uuid

    MessageExpress.config.bus.publish InventoryItemCreated.coerce!('id' => item_created_id,
                                                                   'name' => 'foobar')

    DummySubscriber.instance_variable_get(:@inventory_item_created_message)['id']
                   .must_equal item_created_id
  end

  it 'allow multiple subscribtions' do
    class DummySubscriber
      include MessageExpress::Subscriber

      on 'inventory_item_created' do |message|
        @first_catch = message
      end

      on 'inventory_item_created' do |message|
        @second_catch = message
      end
    end

    DummySubscriber.subscribe!

    item_created_id = SecureRandom.uuid

    MessageExpress.config.bus.publish InventoryItemCreated.coerce!('id' => item_created_id,
                                                                   'name' => 'foobar')

    DummySubscriber.instance_variable_get(:@first_catch)['id']
                   .must_equal item_created_id
    DummySubscriber.instance_variable_get(:@second_catch)['id']
                   .must_equal item_created_id
  end

  it 'allow to pass options to the bus' do
    class DummySubscriber
      include MessageExpress::Subscriber

      subscriber_options foo: 'bar', bar: 'baz'
      subscriber_options baz: 'foo'
    end

    mock(MessageExpress.config.bus).subscribe(foo: 'bar', bar: 'baz', baz: 'foo')

    DummySubscriber.subscribe!
  end

  it 'allows wildcard subscribtions' do
    class DummySubscriber
      include MessageExpress::Subscriber

      on '*' do |message|
        @catch = message
      end
    end

    DummySubscriber.subscribe!

    item_created_id = SecureRandom.uuid
    MessageExpress.config.bus.publish InventoryItemCreated.coerce!('id' => item_created_id,
                                                                   'name' => 'foobar')

    DummySubscriber.instance_variable_get(:@catch)['id'].must_equal item_created_id

    item_deactivated_id = SecureRandom.uuid
    MessageExpress.config.bus.publish InventoryItemDeactivated.coerce!('id' => item_deactivated_id)

    DummySubscriber.instance_variable_get(:@catch)['id'].must_equal item_deactivated_id
  end
end
