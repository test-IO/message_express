require 'message_express'
require 'message_express/message'

module MessageExpress
  module Publisher
    def publish(message_name, payload, validate: true)
      message_class = MessageExpress.message_name_to_class(message_name)
      message = validate ? message_class.coerce!(payload) : message_class.new(payload)

      MessageExpress.config.bus.publish(message)
    end

    def publish_async(message_name, payload)
      MessageExpress.message_name_to_class(message_name).validate! payload
      MessageExpress::AsyncPublisher.perform_async(message_name, payload)
    end
  end
end
