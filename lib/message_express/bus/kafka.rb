require 'message_express/bus/abstract_bus'
require 'message_express/message'

module MessageExpress
  module Bus
    class Kafka < AbstractBus
      attr_reader :kafka

      def initialize(kafka_client)
        @kafka = kafka_client
      end

      def publish(message)
        message = {
          message_name: message.name,
          message_payload: message.payload
        }

        producer = kafka.producer
        producer.produce(message.to_json, topic: 'messages')
        producer.deliver_messages
      end

      def subscribe(consumer_group_id:, topic:)
        consumer = @kafka.consumer(group_id: consumer_group_id)
        consumer.subscribe(topic)

        trap('TERM') { consumer.stop }

        consumer.each_message(automatically_mark_as_processed: true) do |kafka_message|
          message_as_hash = JSON.parse(kafka_message.value)
          message = Message.new(message_as_hash['message_name'], message_as_hash['message_payload'])

          yield(message)
        end
      end
    end
  end
end
