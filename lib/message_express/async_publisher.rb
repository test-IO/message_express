require 'message_express/publisher'

module MessageExpress
  class AsyncPublisher
    include MessageExpress::Publisher
    include Sidekiq::Worker
    sidekiq_options queue: ENV['MESSAGE_EXPRESS_SIDEKIQ_QUEUE'] || 'default'

    def perform(message_name, payload)
      publish(message_name, payload, validate: false)
    end
  end
end
