require 'test_helper'

class WalkerTest < ActiveSupport::TestCase
  test "create walker" do
		walker = Walker.new
		assert !Walker.save
  end
end
