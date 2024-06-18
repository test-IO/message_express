# MessageExpress

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/message_express`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'message_express'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install message_express

## Usage

# Create a subscriber

# Configuration

  Add the gem to the Gemfile

  ```ruby
  gem 'message_express', git: 'https://github.com/test-IO/message_express'
  ```

  You need to create an initializer file in config/initializers.

  ```ruby
  require 'kafka'
  require 'message_express'
  require 'message_express/bus/kafka'
  require 'message_express/message_store/memento'

  MessageExpress.configure do |c|
    c.bus MessageExpress::Bus::Kafka.new(Kafka.new([ENV['KAFKA_SEED_BROKER']]))
    c.message_store MessageExpress::MessageStore::Memento.new
    c.sidekiq_queue 'awesome-queue' # optional (default: default)
  end
  ```

# Subscribtion

  ```ruby
  class DummySubscriber
    include MessageExpress::Subscriber

    on 'inventory_item_created' do |message|
      message.dig('foo', 'bar') # => 'baz'
      message['foo']['bar'] # => 'baz'
      message.payload # => { 'foo' => { 'bar' => 'baz' } }
    end

    on :inventory_item_created do |message|
      # It also accept symbols.
    end

    on '*' do |message|
      # It also accept wildcards, all events will be received.

      message.name
      # => 'inventory_item_created'
    end
  end
  ```

  # Publication
  ```ruby
  class DummyPublisher
    include MessageExpress::Publisher

    def create_inventory_item
      # Your logic
      publish('inventory_item_created', { 'id' => item_id })
    end
  end

  publisher = DummyPublisher.new
  publisher.publish('inventory_item_created', { 'id' => item_id })

  ```

  # Kafka
  The default topic of the subscriber is 'messages'.
  You can provide `subscriber_options`, consumer_id is mandatory, and you can specify another topic.

  ```ruby
  class MessageExpressSubscriber
    include MessageExpress::Subscriber

    subscriber_options consumer_group_id: 'event_watcher'
  end
  ```
  # Redis stream
  The default stream is message
  you can provide `subscriber_options`, and you can specify another stream


  ```ruby
  class MessageExpressSubscriber
    include MessageExpress::Subscriber

    subscriber_options stream: 'event_watcher'
  end
  ```

  But you can also define an other stream for the publisher using `publisher_options`

  ```ruby
  class MessageExpressPublisher
    include MessageExpress::Publisher

    publisher_options stream: 'event_watcher'
  end
  ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/test-IO/message_express. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
