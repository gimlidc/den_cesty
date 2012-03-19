class PagesController < ApplicationController
  def actual
		@registered_walkers = Registration.where(:dc_id => $current_dc_id).joins(:walker).order(:username)
  end

	def rules

	end

	def hall_of_glory

	end

end
