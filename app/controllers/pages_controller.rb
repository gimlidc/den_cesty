class PagesController < ApplicationController
  def actual
		@walkers = Walker.find(:all, :select => "username")
  end

	def rules

	end

	def hall_of_glory

	end

end
