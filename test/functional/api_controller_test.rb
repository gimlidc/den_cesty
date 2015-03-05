require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get scoreboard" do
    get :scoreboard
    assert_response :success
  end

  test "should get push_events" do
    get :push_events
    assert_response :success
  end

end
