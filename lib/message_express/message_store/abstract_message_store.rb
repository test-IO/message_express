module MessageExpress
  module MessageStore
    class AbstractMessageStore
      def save_message(_message)
        raise "save_message(message) needs to be implemented for #{self.class}"
      end
    end
  end
end
