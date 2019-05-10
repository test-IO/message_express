require 'test_helper'

require 'message_express/message'

describe MessageExpress::Message do
  describe '#name' do
    class FooBarClass < MessageExpress::Message
    end

    it 'return the class name as snake_case by default' do
      message = MessageExpress::Message.new('foo' => 'bar')
      message.name.must_equal 'message_express/message'

      message = FooBarClass.new('foo' => 'bar')
      message.name.must_equal 'foo_bar_class'
    end

    it 'allow to specify a name and initializing the object' do
      message = MessageExpress::Message.new('foo_bar_baz', 'foo' => 'bar')
      message.name.must_equal 'foo_bar_baz'

      message = FooBarClass.new('foo_bar_foo', 'foo' => 'bar')
      message.name.must_equal 'foo_bar_foo'
    end
  end

  describe 'Payload access' do
    it 'can access the payload using #payload' do
      message = MessageExpress::Message.new('foo' => 'bar')
      message.payload['foo'].must_equal 'bar'
    end

    it 'can access the payload using []' do
      message = MessageExpress::Message.new('foo' => 'bar')
      message['foo'].must_equal 'bar'
    end

    it 'can access the payload using dig' do
      message = MessageExpress::Message.new('foo' => { 'bar' => 'baz' })
      message.dig('foo', 'bar').must_equal 'baz'
    end
  end

  describe 'Payload validation' do
    class MessageWithSchema < MessageExpress::Message
      define do
        { 'foo' => _String }
      end
    end

    describe '::valid?' do
      it 'return a boolean depending if the payload is valid' do
        MessageWithSchema.valid?('foo' => 'bar').must_equal true
        MessageWithSchema.valid?('bar' => 'foo').must_equal false
      end
    end

    describe '::coerce!' do
      it 'return a message instance based on the payload' do
        message = MessageWithSchema.coerce!('foo' => 'baz')
        message.payload['foo'].must_equal 'baz'
      end

      it 'raise an exception if the payload is invalid' do
        assert_raises(MessageExpress::InvalidSchema) do
          MessageWithSchema.coerce!('bar' => 'foo')
        end
      end
    end
  end
end
