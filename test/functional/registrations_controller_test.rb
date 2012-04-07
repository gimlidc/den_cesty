require 'test_helper'

# @author gimli
# @version Apr 6, 2012

class RegistrationsControllerTest < ActionController::TestCase
	include Devise::TestHelpers

	def setup_admin
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in Factory.create(:admin)
  end

	def setup_walker
    @request.env["devise.mapping"] = Devise.mappings[:elis]
    sign_in Factory.create(:elis)
  end

  test "new without login" do
		setup_walker
		get :new
    assert_response :fail, "Registration page is accessible without login"
		assert_select "#walker_nav", "#{I18n.t("Register")} #{I18n.t("or")} #{I18n.t("Sign_in")}"
	end

	test "new of logged walker before shirt deadline" do
	end

	test "new of logged walker after shirt deadline" do
	end

	test "new of logged walker after deadline" do
	end

	test "renew of canceled reg before shirt deadline" do
	end

	test "renew of canceled reg after shirt deadline" do
	end

	test "renew of canceled reg after deadline" do
	end

	test "reg cancelation before shirt deadline" do
	end

	test "reg cancelation after shirt deadline" do
	end

	test "reg cancelation after deadline" do
	end

end
