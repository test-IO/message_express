module MessageExpress
  class AsyncPublisher
    include MessageExpress::Publisher
    include Sidekiq::Worker

    def perform(message_name, payload)
      publish(message_name, payload, validate: false)
    end
  end
end
