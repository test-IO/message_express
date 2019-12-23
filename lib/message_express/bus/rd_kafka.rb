require 'message_express/bus/abstract_bus'
require 'message_express/message'

module MessageExpress
  module Bus
    class RdKafka < AbstractBus
      attr_reader :kafka

      def initialize(kafka_client, topic: nil)
        @kafka = kafka_client
        @topic = topic || 'messages'
      end

      def publish(message)
        producer_params = {
          topic: @topic,
          payload: message.payload,
          key: "#{@topic}-#{rand(10**10)}"
        }

        producer = @kafka.producer
        producer.produce(producer_params).wait
      end

      def subscribe(consumer_group_id:, topic: @topic)
        consumer = @kafka.consumer(group_id: consumer_group_id)
        consumer.subscribe(topic)

        trap('TERM') { consumer.stop }

        consumer.each do |kafka_message|
          Rails.logger.info "Message: #{kafka_message}"
        end
      end
    end
  end
end
