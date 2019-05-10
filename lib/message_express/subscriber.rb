require 'message_express'

module MessageExpress
  module Subscriber
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def on(message_name, &block)
        @message_handlers ||= {}
        @message_handlers[message_name.to_s] ||= []
        @message_handlers[message_name.to_s] << block
      end

      def subscribe!
        @message_handlers ||= {}
        MessageExpress.config.bus.subscribe(subscriber_options) do |message|
          (@message_handlers[message.name] || []).each do |blck|
            blck.call(message)
          end
        end
      end

      def subscriber_options(options = {})
        @subscriber_options = (@subscriber_options || {}).merge(options)
      end
    end
  end
end
