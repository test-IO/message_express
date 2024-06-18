require 'message_express'
require 'message_express/bus/abstract_bus'
require 'message_express/message'

module MessageExpress
  module Bus
    class RedisStream < AbstractBus
      attr_reader :redis_client

      def initialize(redis_client, stream: 'messages')
        @redis_client = redis_client
        @stream = stream
      end

      def xgroup(*args);end

      def publish(message, options = {})
        stream = options.fetch(:stream, @stream)
        message.payload
        data = { "json" => { message_name: message.name, message_payload: message.payload }.to_json }
        redis_client.xadd(stream, data)
      end

      def subscribe(options = {})
        consumer_group_id = options.fetch(:consumer_group_id, 'message_express')
        consumer_name = options.fetch(:consumer_name, 'consumer')
        stream = options.fetch(:stream, @stream)

        create_group(stream, consumer_group_id)

        messages = redis_client.xreadgroup(consumer_group_id, consumer_name, stream, '>', count: 1, block: 5000)
        messages.each do |stream, entries|
          entries.each do |message_id, message_hash|
            message_data = JSON.parse(message_hash["json"])
            message_class = ::MessageExpress.message_name_to_class(message_data['message_name'])
            message = message_class.new(message_data['message_name'], message_data['message_payload'])
            yield(message)
            redis_client.xack(stream, consumer_group_id, message_id)
          end
        end
      end

      private

      def create_group(stream_key, group_name)
        begin
          redis_client.xgroup(:create, stream_key, group_name, '$', mkstream: true)
        rescue Redis::CommandError => e
          raise unless e.message.include?('BUSYGROUP')
        end
      end
    end
  end
end
