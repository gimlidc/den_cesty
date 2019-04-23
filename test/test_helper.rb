ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
    
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all  

  # Add more helper methods to be used by all tests here...
  def loadDcTest
    $dc = dcs(:two)
    $shirt_deadline = ($dc.start_time - 17.days).end_of_day
    $registration_deadline = ($dc.start_time - 4.days).end_of_day
    $registration_edit_deadline = $dc.start_time - 4.hours
    $registration_starts = true
    $report_deadline = ($dc.start_time + 1.month).end_of_day
  end
end
