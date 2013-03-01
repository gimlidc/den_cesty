require 'test_helper'

class DcsControllerTest < ActionController::TestCase
  setup do
    @dc = dcs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dcs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dc" do
    assert_difference('Dc.count') do
      post :create, dc: @dc.attributes
    end

    assert_redirected_to dc_path(assigns(:dc))
  end

  test "should show dc" do
    get :show, id: @dc.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dc.to_param
    assert_response :success
  end

  test "should update dc" do
    put :update, id: @dc.to_param, dc: @dc.attributes
    assert_redirected_to dc_path(assigns(:dc))
  end

  test "should destroy dc" do
    assert_difference('Dc.count', -1) do
      delete :destroy, id: @dc.to_param
    end

    assert_redirected_to dcs_path
  end
end
