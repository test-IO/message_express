require "test_helper"

class MessageExpressTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MessageExpress::VERSION
  end
end
