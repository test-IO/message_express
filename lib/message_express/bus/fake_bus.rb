require 'message_express/bus/abstract_bus'

module MessageExpress
  module Bus
    class FakeBus < AbstractBus
      def initialize
        @handlers = []
      end

      def publish(message, _options = {})
        @handlers.each do |blck|
          blck.call(message)
        end
      end

      def subscribe(_options = {}, &blck)
        @handlers << blck
      end
    end
  end
end
