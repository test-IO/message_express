require 'message_express'
require 'message_express/bus/abstract_bus'
require 'message_express/message'

module MessageExpress
  module Bus
    class RedisPubSub < AbstractBus
      attr_reader :redis_client

      def initialize(redis_client, channel: 'messages')
        @redis_client = redis_client
        @channel = channel
      end

      def publish(message, channel: @channel)
        message = {
          message_name: message.name,
          message_payload: message.payload
        }

        redis_client.publish(channel, message.to_json)
      end

      def subscribe(channel: @channel)
        redis_client.subscribe(channel) do |on|
          on.message do |channel, message_data|
            message_as_hash = JSON.parse(message_data)
            message = Message.new(message_as_hash['message_name'], message_as_hash['message_payload'])
            yield(message)
          end
        end
      end
    end
  end
end

