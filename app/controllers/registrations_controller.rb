class RegistrationsController < ApplicationController

	def new
		@reg = Registration.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})
		if !@reg.nil? && !@reg.empty?
			redirect_to :action => :edit, :notice => "You are already registered."
		end
		@registration = Registration.new
		@store_string = "Register"
		@action = "create"
	end

	def create
		@reg = Registration.new
		@reg.walker_id = current_walker[:id]
		@reg.dc_id = $current_dc_id
		update_db(@reg)
  end

	def show
		if (walker_signed_in?)
			@registration = Registration.joins(:walker)
			@reg = Registration.find(:first, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})
		end
	end

	def edit
		@reg = Registration.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})
		if @reg.nil? || @reg.empty?
			redirect_to :action => :new
		end
		@registration = @reg
		@walker = Walker.find(current_walker[:id])
		@store_string = "Save"
		@action = "update"
	end

	def update_db(reg)
		if !reg.nil?
			reg.bw_map = params[:registration][:bw_map]
			reg.colour_map = params[:registration][:colour_map]
			reg.shirt_size = params[:registration][:shirt_size]
			if reg.save
				@notice = "Registration details sucessfully stored."
				redirect_to :action => 'show'
			else
				@notice = @reg.errors.full_messages[0]
				@registration = reg
				render :action => 'edit'
			end
		else
			@notice = "Registration not found, try to create new."
		end
	end

	def update
		@reg = Registration.find(:first, :conditions => {:walker_id => params[:registration][:walker_id], :dc_id => params[:registration][:dc_id]})
		update_db(@reg)
	end

	def destroy
		@reg = Registration.find(:first, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})

		if !@reg.nil?
			if @reg.delete
				@notice = "Registration was cancelled."
			else
				@notice = "Delete failed."
			end
		else
			@notice = "Registration not found."
		end
	end

	def unregister
		if walker_signed_in? && current_walker.username =="gimli"

			@reg = Registration.find(:first, :conditions => {:id => "#{params[:id]}" })
			@walker = Walker.find(:first, :conditions => {:id => @reg.walker_id})
			if !@reg.nil?
				if @reg.delete
					@notice = "Registration of " << @walker.username.to_s << " was cancelled."
				else
					@notice = "Delete failed."
				end
			else
				@notice = "Registration not found."
			end
		else
			@notice = "Operation unauthorized"
			render :action => 'edit'
		end

		render :action => 'show'

	end

end
