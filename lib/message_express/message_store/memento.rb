require 'message_express/message_store/abstract_message_store'

module MessageExpress
  module MessageStore
    class Memento < AbstractMessageStore
      def save_message(message); end
    end
  end
end
