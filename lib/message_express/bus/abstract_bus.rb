module MessageExpress
  module Bus
    class AbstractBus
      def publish(_message, options = {})
        raise "publish(message) needs to be implemented for #{self.class}"
      end

      def subscribe(_options = {})
        raise "subscribe(options = {}, &blck) needs to be implemented for #{self.class}"
      end
    end
  end
end
