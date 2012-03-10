class AdminController < ApplicationController

	def walker_list
		if walker_signed_in? && current_walker.username =="gimli"
			@walkers = Walker.all
		else
			redirect_to :action => 'unauthorized'
		end
	end

	def walker_update
		if walker_signed_in? && current_walker.username =="gimli"
			walker = Walker.find(:first, params[:walker][:id])

			if walker.nil?
				@notice = "Walker not found."
			else
				walker.username = params[:walker][:username]
				walker.name = params[:walker][:name]
				walker.surname = params[:walker][:surname]
				walker.email = params[:walker][:email]
				walker.year = params[:walker][:year]
				if walker.save
					@notice = "Update successful"
				else
					@notice = "Walker not updated."
				end
			end

			walker_list

			render :action => 'walker_list'

		else
			redirect_to :action => 'unauthorized'
		end
	end

	def walker_destroy
		if walker_signed_in? && current_walker.username =="gimli"
			@walker = Walker.find(:first, "#{params[:id]}")
			if !@walker.nil? && @walker.destroy
				@notice = "Destroy successful"
			else
				@notice = "Walker not destroyed."
			end

			redirect_to :action => 'walker_list'

		else
			redirect_to :action => 'unauthorized'
		end
	end

	def unauthorized

	end

end
