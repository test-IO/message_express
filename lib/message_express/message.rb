require 'rschema'

module MessageExpress
  Exception = Class.new(StandardError)
  InvalidSchema = Class.new(RuntimeError)

  class Message
    attr_reader :payload

    def self.define(&blck)
      @schema = RSchema.define_hash(&blck)
    end

    def self.coerce!(payload)
      validate!(payload)
      new(payload)
    end

    def self.valid?(payload)
      return true if @schema.nil?

      @schema.valid?(payload)
    end

    def self.validate!(payload)
      return nil if @schema.nil?

      validation_result = @schema.validate(payload)
      raise InvalidSchema, validation_result.error unless validation_result.valid?

      validation_result
    end

    def initialize(name = nil, payload) # rubocop:disable Style/OptionalArguments
      @name = name
      @payload = payload
    end

    def name
      @name ||= self.class.name.gsub(/::/, '/')
                    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                    .tr('-', '_')
                    .downcase
    end

    def [](param)
      payload[param]
    end

    def dig(*params)
      payload.dig(*params)
    end
  end
end
