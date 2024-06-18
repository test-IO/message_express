require 'test_helper'

require 'message_express/bus/fake_bus'
require 'message_express/configuration'
require 'message_express/message_store/memento'

describe MessageExpress::Configuration do
  let(:configuration) { MessageExpress::Configuration.new }

  describe '#bus' do
    it 'raise an exception when bus is not set' do
      exception = assert_raises do
        configuration.bus
      end
      value(exception.message).must_equal 'bus must be defined'
    end

    it 'allow to set a bus' do
      configuration.bus MessageExpress::Bus::FakeBus.new
      value(configuration.bus.class).must_equal MessageExpress::Bus::FakeBus
    end
  end

  describe '#message_store' do
    it 'raise an exception when message store is not set' do
      exception = assert_raises do
        configuration.message_store
      end
      value(exception.message).must_equal 'message_store must be defined'
    end

    it 'allow to set a message store' do
      configuration.message_store MessageExpress::MessageStore::Memento.new
      value(configuration.message_store.class).must_equal MessageExpress::MessageStore::Memento
    end
  end

  describe '#sidekiq_queue' do
    it 'returns default queue' do
      value(configuration.sidekiq_queue).must_equal 'default'
    end

    it 'allow to set a message store' do
      configuration.sidekiq_queue 'awesome-queue'
      value(configuration.sidekiq_queue).must_equal 'awesome-queue'
    end
  end
end
