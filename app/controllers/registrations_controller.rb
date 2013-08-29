class RegistrationsController < ApplicationController

  skip_before_filter :check_admin?, :except => [:unregister]

	def new
		@reg = Registration.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $dc.id})
		if !@reg.nil? && !@reg.empty?
			if (!@reg[0].canceled)
				flash.notice = "You are already registered."
			end
			redirect_to :action => :edit
		end
		@registration = Registration.new
		@walker = Walker.find(current_walker[:id])
		@store_string = I18n.t("sign_up_dc")
		@action = "create"		
	end

	def create
		@reg = Registration.new
		@reg.walker_id = current_walker[:id]
		@walker = Walker.find(current_walker[:id])
		@reg.dc_id = $dc.id
		update_db(@reg, @walker)
  end

	def show
		if (walker_signed_in?)
			@registration = Registration.joins(:walker).where(:canceled => false, :dc_id => $dc.id).order(:surname)
			@reg = Registration.find(:first, :conditions => {:walker_id => current_walker[:id], :dc_id => $dc.id})
		end
	end

	def edit
		@reg = Registration.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $dc.id})
		if @reg.nil? || @reg.empty?
			redirect_to :action => :new
		end
		@registration = @reg.first
		@walker = Walker.find(current_walker[:id])
		@store_string = I18n.t("Save")
		@action = "update"
	end

	def update_db(reg, walker)
		if (Time.now > $registration_deadline)
			flash.notice = "It's after deadline for registration, changes was not accepted."
			redirect_to :action => :show
		else
			if !reg.nil?
				reg.bw_map = params[:registration][:bw_map]
				reg.colour_map = params[:registration][:colour_map]
				reg.goal = params[:registration][:goal]
				reg.phone = params[:registration][:phone]
				reg.canceled = false
				
				@phone = params[:registration][:phone]
				walker.phone = @phone
        
				# field for shirt selection is missing
				if (Time.now > $shirt_deadline)
					if reg.shirt_size.nil?
						reg.shirt_size = "NO"
					end
				else
					reg.shirt_size = params[:registration][:shirt_size]
				end

				if reg.save
					if walker.save
					  flash.notice = "Registration details sucessfully stored."
					  redirect_to :action => 'show'
					else  
					  @registration = reg
					  flash.alert = walker.errors.full_messages.to_sentence
            redirect_to :action => :edit
          end
				else
					@registration = reg
					flash.alert = reg.errors.full_message.to_sentence
					redirect_to :action => :edit
				end
			else
				flash.notice = "Data of registration is missing, illegal access?!"
			end
		end
	end    

	def update
		@reg = Registration.find(:first, :conditions => {:walker_id => params[:registration][:walker_id], :dc_id => params[:registration][:dc_id]})
		@walker = Walker.find(current_walker[:id])
		update_db(@reg, @walker)
	end

	def destroy
		@reg = Registration.find(:first, :conditions => {:walker_id => current_walker[:id], :dc_id => $dc.id})

		if !@reg.nil?
			@reg.canceled = true
			if @reg.save
				flash.notice = "Registration was cancelled."
			else
				flash.notice = "Unregistration failed."
			end
		else
			flash.notice = "Registration not found."
		end

		redirect_to :controller => 'pages', :action => 'actual'
	end

	def unregister		
		@reg = Registration.find(:first, :conditions => {:id => "#{params[:id]}" })
    @walker = Walker.find(:first, :conditions => {:id => @reg.walker_id})
    if !@reg.nil?
      @reg.canceled = true
      if @reg.save
        flash.notice = "Registration of " << @walker.username.to_s << " was cancelled."
      else
        flash.notice = "Delete failed."
      end
    else
      flash.notice = "Registration not found."
    end		

		redirect_to :action => 'show'

	end
	
end
