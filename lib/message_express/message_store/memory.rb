require 'message_express/message_store/abstract_message_store'

module MessageExpress
  module MessageStore
    class Memory < AbstractMessageStore
      attr_reader :messages

      def initialize
        @messages = []
      end

      def save_message(message)
        @messages << message
      end
    end
  end
end
