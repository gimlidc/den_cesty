class PagesController < ApplicationController
  def actual
		@registered_walkers = Registration.where(:dc_id => $current_dc_id, :canceled => false).joins(:walker).order(:username)
		render "pod12_17.html.erb"
  end

	def rules

	end

	def hall_of_glory

	end

	def contacts
		
	end
end
