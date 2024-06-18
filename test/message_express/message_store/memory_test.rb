require 'test_helper'

require 'message_express/message'
require 'message_express/message_store/memory'

describe MessageExpress::MessageStore::Memory do
  class InventoryItemCreated < MessageExpress::Message
    define do
      {
        'id' => _String,
        'name' => _String
      }
    end
  end

  class InventoryItemRenamed < MessageExpress::Message
    define do
      {
        'id' => _String,
        'new_name' => _String
      }
    end
  end

  describe '#save_message' do
    it 'store messages in an array' do
      store = MessageExpress::MessageStore::Memory.new
      message_foo = InventoryItemCreated.coerce!('id' => SecureRandom.uuid,
                                                 'name' => 'Foo')
      message_bar = InventoryItemRenamed.coerce!('id' => message_foo['id'],
                                                 'new_name' => 'Bar')

      store.save_message(message_foo)
      store.save_message(message_bar)

      value(store.messages).must_equal [message_foo, message_bar]
    end
  end
end
