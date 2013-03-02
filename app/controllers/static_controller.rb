class StaticController < ApplicationController
  
  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?
  
end
