#encoding: UTF-8
require 'test_helper'

class DcsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:walker]
    sign_in walkers(:gimli)
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
      @dcNew = Dc.new(:name_cs => "Testovací DC name", :name_en => "Testing DC name", :start_time => "2012-04-27 09:30:00",  :description => "toto je popisek cesty", :rules_id => 1, :reg_price => 30, :map_bw_price => 5, :map_color_price => 50, :shirt_price => 250, :own_shirt_price => 150)       
      post :create, :dc => @dcNew.attributes
    end

    assert_redirected_to dc_path(assigns(:dc))
  end

  test "should show dc" do
    get :show, :id => @dc.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @dc.to_param
    assert_response :success
  end

  test "should update dc" do
    put :update, :id => @dc.to_param, :dc => @dc.attributes
    assert_redirected_to dc_path(assigns(:dc))
  end

  test "should destroy dc" do
    assert_difference('Dc.count', -1) do
      delete :destroy, :id => @dc.to_param
    end

    assert_redirected_to dcs_path
  end
end
