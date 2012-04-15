class AdminController < ApplicationController

	def results_update
		if walker_signed_in? && current_walker.username == $admin_name
			dc_id = Integer("#{params[:dc_id]}")
			@walkers = Walker.find_by_sql("SELECT wal_reg.id AS id, name, surname, year, wal_reg.dc_id AS dc_id, distance FROM (SELECT walkers.id AS id, name, surname, year, registrations.dc_id AS dc_id FROM walkers JOIN registrations ON walkers.id = registrations.walker_id) AS wal_reg LEFT OUTER JOIN results ON wal_reg.id = results.walker_id AND wal_reg.dc_id = results.dc_id")
			@results = Result.where(:dc_id => dc_id).order(:walker_id)
			res = 0
			@walkers.each do |walker|
				if @results.nil? || @results.empty? || @results[res].nil? || @results[res].walker_id != walker.id
					result = Result.new
					result.dc_id = dc_id
					result.walker_id = walker.id
				else
					result = @results[res]
					res += 1
				end

				distance = params["#{walker.id}"]
				if !distance.nil? && distance != ""
					result.distance = distance

					if (!result.save)
						flash[:notice] = "#{flash[:notice]}, result: #{result.walker_id},#{result.dc_id},#{result.distance} not saved";
					else
						flash[:notice] = "#{flash[:notice]}, result: #{result.walker_id},#{result.dc_id},#{result.distance} saved";
					end
				else
					flash[:notice] = "#{flash[:notice]}, distance for walker: #{walker.id} not set";
				end
			end
			redirect_to :action => "results_setting", :id => dc_id
		else
			redirect_to :action => 'unauthorized'
		end
	end

	def results_setting
		if walker_signed_in? && current_walker.username == $admin_name
			if params[:id].nil?
				@set_dc = $current_dc_id
			else
				@set_dc = Integer("#{params[:id]}")
			end
			@walkers = Walker.find_by_sql("SELECT wal_reg.id AS id, name, surname, year, wal_reg.dc_id AS dc_id, distance FROM (SELECT walkers.id AS id, name, surname, year, registrations.dc_id AS dc_id FROM walkers JOIN registrations ON walkers.id = registrations.walker_id) AS wal_reg LEFT OUTER JOIN results ON wal_reg.id = results.walker_id AND wal_reg.dc_id = results.dc_id")
		else
			rediredct_to :action => 'unauthorized'
		end
	end

	def results_list

	end

	def walker_create
		if walker_signed_in? && current_walker.username == $admin_name
			@walkers = Walker.find(:all, :conditions => {:name => params[:walker][:name], :surname => params[:walker][:surname]})
			if @walkers.empty?
				walker = Walker.new(params[:walker])
				walker.email = "#{walker.id}@#{walker.name}.#{walker.surname}"
				walker.sex = params[:walker][:sex]
				if walker.save(:validate => false)
					flash[:notice] = "Walker created"
				else
					flash[:notice] = "Walker creation failed"
				end
			else
				flash[:alert] = "Walker with the same name exist!"
			end
		end
		redirect_to :action => 'walker_list'
	end

	def walker_list
		if walker_signed_in? && current_walker.username == $admin_name
			@walkers = Walker.find(:all, :order => "surname, name")
			@new_walker = Walker.new
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
				if (params[:walker][:username].nil?)
					validate = false
				else
					walker.username = params[:walker][:username]
					walker.email = params[:walker][:email]
				end
				walker.name = params[:walker][:name]
				walker.surname = params[:walker][:surname]
				walker.sex = params[:walker][:sex]
				walker.year = params[:walker][:year]
				if walker.save(:validate => validate)
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
