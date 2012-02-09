class ApplicationController < ActionController::Base
  protect_from_forgery

	$current_dc_id = 16
	$dc_date = Time.local(2012, 4, 21, 19, 00, 00, 00);

end
