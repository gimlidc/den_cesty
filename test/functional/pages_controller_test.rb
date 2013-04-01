require 'test_helper'

class PagesControllerTest < ActionController::TestCase
	include Devise::TestHelpers

	test "should get actual without login" do
	  loadDc
    get :actual
    assert_response :success, "Actual page is not accessible"
		assert_select "#walker_nav", "#{I18n.t("Register")} #{I18n.t("or")} #{I18n.t("Sign_in")}"
  end

	test "should get hall of glory without login" do
		get :hall_of_glory
    assert_response :success, "Hall of glory is not accessible"
		assert_select "#walker_nav", "#{I18n.t("Register")} #{I18n.t("or")} #{I18n.t("Sign_in")}"
	end

	test "should get recommendations without login" do
		get :recommendations
    assert_response :success, "Recommendations are not accessible"
		assert_select "#walker_nav", "#{I18n.t("Register")} #{I18n.t("or")} #{I18n.t("Sign_in")}"
	end

	test "should get rules without login" do
		get :rules
    assert_response :success, "Rules are not accessible"
		assert_select "#walker_nav", "#{I18n.t("Register")} #{I18n.t("or")} #{I18n.t("Sign_in")}"
	end

end
