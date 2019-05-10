module MessageExpress
  class Configuration
    def bus(value = nil)
      @bus = value unless value.nil?
      raise 'bus must be defined' unless defined?(@bus)

      @bus
    end

    def message_store(value = nil)
      @message_store = value unless value.nil?
      raise 'message_store must be defined' unless defined?(@message_store)

      @message_store
    end
  end
end
