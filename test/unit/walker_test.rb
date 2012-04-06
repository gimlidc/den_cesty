require 'test_helper'

class WalkerTest < ActiveSupport::TestCase
  test "create well defined walker" do
		walker = walkers(:jenda)
		assert walker.save, "Well defined walker not saved"
  end

	test "undefined walker email" do
		assert !walkers(:kase).save, "Saved walker without email"
  end

	test "undefined walker sex" do
		assert walkers(:henry).save, "Sex specification needed"
		assert Walker.find(walkers(:henry)).sex.nil?, "Default value of sex was set"
  end

end
