class AdminController < ApplicationController

	def results_update
		if walker_signed_in? && current_walker.username == $admin_name
		else
			rediredct_to :action => 'unauthorized'
		end
	end

	def results_setting
		if walker_signed_in? && current_walker.username == $admin_name
			@walkers = Walker.find(:all, :order => "surname");
			@results = Result.find(:all, :order => "walker_id, dc_id")
			if params[:id].nil?
				@set_dc = $current_dc_id
			else
				@set_dc = Integer("#{params[:id]}")
			end
		else
			rediredct_to :action => 'unauthorized'
		end
	end

	def walker_list
		if walker_signed_in? && current_walker.username == $admin_name
			@walkers = Walker.find(:all, :order => "surname")
		else
			redirect_to :action => 'unauthorized'
		end
	end

	def walker_update
		if walker_signed_in? && current_walker.username == $admin_name
			walker = Walker.find(params[:walker][:id])

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
		if walker_signed_in? && current_walker.username == $admin_name
			@walker = Walker.find(params[:id])
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
