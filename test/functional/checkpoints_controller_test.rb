require 'test_helper'

class CheckpointsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get delete" do
    get :delete
    assert_response :success
  end

  test "should get upload" do
    get :upload
    assert_response :success
  end

  test "should get map" do
    get :map
    assert_response :success
  end

end
