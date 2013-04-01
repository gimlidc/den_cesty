require 'test_helper'

# @author gimli
# @version Apr 6, 2012

class RegistrationsControllerTest < ActionController::TestCase
	include Devise::TestHelpers

	def setup_admin
    @request.env["devise.mapping"] = Devise.mappings[:walker]
    sign_in walkers(:gimli)
  end

	def setup_walker
    @request.env["devise.mapping"] = Devise.mappings[:walker]
    sign_in walkers(:elis)
  end

  test "new without login" do
    get :new
		assert_redirected_to walker_session_path		

		get(:new, {:id => 1})
		assert_redirected_to walker_session_path
	end

	test "new of logged walker before shirt deadline" do
		setup_walker
		loadDc
		get :new
		assert_response :success, "New registration form for elis not generated"
		#assert_select 'select'
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
