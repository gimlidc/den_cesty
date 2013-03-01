class DcController < ApplicationController
  
  walker_signed_in? && current_walker.username == $admin_name
  
  def create    
  end
  
  def show
  end
  
  def destroy    
  end
  
  def edit    
  end
  
end
