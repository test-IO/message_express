require 'message_express'
require 'message_express/bus/abstract_bus'
require 'message_express/message'

module MessageExpress
  module Bus
    class RedisStreamBus < AbstractBus
      attr_reader :redis_client

      def initialize(redis_client, stream: 'messages')
        @redis_client = redis_client
        @stream = stream
      end

      def publish(message)
        message = {
          message_name: message.name,
          message_payload: message.payload
        }
        redis_client.xadd(@stream, message.to_json)
      end

      def subscribe(consumer_group_id: 'default', stream: @stream, consumer_name: 'consumer')
        messages = redis_client.xreadgroup(consumer_group_id, consumer_name, stream, '>', count: 1, block: 5000)
        messages.each do |stream, entries|
          entries.each do |message_id, message_data|
            message_as_hash = JSON.parse(message_data)

            message_class = ::MessageExpress.message_name_to_class(message_as_hash['message_name'])
            message = message_class.new(message_as_hash['message_name'], message_as_hash['message_payload'])
            yield(message)
            redis_client.xack(stream, consumer_group_id, message_id)
          end
        end
      end
    end
  end
end
