require 'test_helper'

class PageControllerTest < ActionController::TestCase
  test "should get :actual" do
    get ::actual
    assert_response :success
  end

end
