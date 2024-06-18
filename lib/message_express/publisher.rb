require 'message_express'
require 'message_express/message'

module MessageExpress
  module Publisher
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def publisher_options(options = {})
        @publisher_options = (@publisher_options || {}).merge(options)
      end
    end

    def publish(message_name, payload, validate: true)
      message_class = MessageExpress.message_name_to_class(message_name)
      message = validate ? message_class.coerce!(payload) : message_class.new(payload)
      options = self.class.instance_variable_get(:@publisher_options) || {}
      MessageExpress.config.bus.publish(message, options)
    end

    def publish_async(message_name, payload)
      MessageExpress.message_name_to_class(message_name).validate! payload
      MessageExpress::AsyncPublisher.set(queue: MessageExpress.config.sidekiq_queue)
                                    .perform_async(message_name, payload)
    end
  end
end
