require 'message_express/configuration'
require 'message_express/version'

module MessageExpress
  def self.configure
    yield config if block_given?
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.config
    configuration
  end

  def self.message_name_to_class(message_name)
    constantize(message_name.to_s.split('_').collect(&:capitalize).join)
  end

  # stolen from rails
  # https://github.com/rails/rails/blob/ebda02d017e623ce0edade5a5ed37ebf2f2c7442/activesupport/lib/active_support/inflector/methods.rb#L271
  def self.constantize(camel_cased_word)
    names = camel_cased_word.split('::')

    # Trigger a built-in NameError exception including the ill-formed constant in the message.
    Object.const_get(camel_cased_word) if names.empty?

    # Remove the first blank element in case of '::ClassName' notation.
    names.shift if names.size > 1 && names.first.empty?

    names.inject(Object) do |constant, name|
      if constant == Object
        constant.const_get(name)
      else
        candidate = constant.const_get(name)
        next candidate if constant.const_defined?(name, false)
        next candidate unless Object.const_defined?(name)

        # Go down the ancestors to check if it is owned directly. The check
        # stops when we reach Object or the end of ancestors tree.
        constant = constant.ancestors.each_with_object(constant) do |ancestor, const|
          break const    if ancestor == Object
          break ancestor if ancestor.const_defined?(name, false)
        end

        # owner is in Object, so raise
        constant.const_get(name, false)
      end
    end
  end
end
