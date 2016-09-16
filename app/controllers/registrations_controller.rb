require 'rqrcode'

class RegistrationsController < ApplicationController

  skip_before_filter :check_admin?, :except => [:unregister]

  include RegistrationsHelper

	def new
		@reg = Registration.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first
		if !@reg.nil?
			if (!@reg.canceled)
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
	  @reg = Registration.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first
	  if @reg.nil?
		  @reg = Registration.new
		end
		@reg.walker_id = current_walker[:id]
		@walker = Walker.find(current_walker[:id])
		@reg.dc_id = $dc.id
		update_db(@reg, @walker)
  end

  def confirm
    @reg = Registration.find("#{params[:id]}")
    if !@reg.nil?
      @reg.confirmed = true
      if @reg.save
        flash.notice = "Registration of " << @reg.walker.email.to_s << " was confirmed."
      else
        flash.notice = "Confirmation failed."
      end
    else
      flash.notice = "Registration not found."
    end

    redirect_to :action => 'show'
  end

	def show
		if walker_signed_in?
			@registration = Registration.joins(:walker).where(:canceled => false, :dc_id => $dc.id).order(:surname)
			@reg = Registration.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first

      qrstring = "SPD*1.0*ACC:" << $IBAN
      qrstring = qrstring << "*AM:" << price(@reg).to_s << "*CC:CZK"
      qrstring = qrstring << "*X-SS:666" << "*X-VS:" << sprintf("%03d", $dc.id) << sprintf("%04d",@reg.walker_id)
      qrstring = qrstring << "*MSG:" << @reg.walker[:email]

			qrcode = RQRCode::QRCode.new(qrstring)
			# With default options specified explicitly
			@svg = qrcode.as_svg(offset: 0, color: '000',
													shape_rendering: 'crispEdges',
													module_size: 4)
		end
	end

	def edit
		@reg = Registration.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first
		if @reg.nil?
			redirect_to :action => :new
      return
		end
		@registration = @reg
		if @registration.confirmed
		  flash.notice = "Registration was already payed. If you want to change payed items or registered walker, contact organizers."		  
		end		
		@walker = Walker.find(current_walker[:id])
		@store_string = I18n.t("Save")
		@action = "update"
	end

# @param reg created registration
# @param walker owning the registration
  def update_db(reg, walker)
		if (Time.now > $registration_deadline)
			flash.notice = "It's after deadline for registration, changes was not accepted."
			redirect_to :action => :show
		else
			if !reg.nil?
			  if !reg.confirmed
				  if !params[:registration][:bw_map].nil?
				    reg.bw_map = params[:registration][:bw_map]
				  end
				  if !params[:registration][:colour_map].nil?
				    reg.colour_map = params[:registration][:colour_map]
				  end
				  if !params[:registration][:shirt_size].nil?
				    reg.shirt_size = params[:registration][:shirt_size]
				  end
				  if !params[:registration][:shirt_polyester].nil?
            reg.shirt_polyester = params[:registration][:shirt_polyester]
          end
          if !params[:registration][:scarf].nil?
            reg.scarf = params[:registration][:scarf]
          end
        end
        
				reg.goal = params[:registration][:goal]
				reg.phone = params[:registration][:phone]
				reg.canceled = false				

				@phone = params[:registration][:phone]
				walker.phone = @phone

				# field for shirt selection is missing
				if reg.shirt_size.nil?
					reg.shirt_size = 'NO'
				end								

        if reg.save
					if walker.save
					  flash.notice = 'Registration details successfully stored.'
					  redirect_to :action => 'show'
					else
					  @registration = reg
					  flash.alert = walker.errors.full_messages.to_sentence
            redirect_to :action => :edit
          end
				else
					@registration = reg
					flash.alert = reg.errors.full_messages.to_sentence
					redirect_to :action => :edit
				end
			else
				flash.notice = "Data of registration is missing, illegal access?!"
			end
		end
	end

	def update
		@reg = Registration.where(walker_id: params[:registration][:walker_id], dc_id: params[:registration][:dc_id]).first
		@walker = Walker.find(current_walker[:id])
		update_db(@reg, @walker)
	end

	def destroy
		@reg = Registration.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first

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
		@reg = Registration.find("#{params[:id]}")
    @walker = Walker.find(@reg.walker_id)
    if !@reg.nil?
      @reg.canceled = true
      if @reg.save
        flash.notice = "Registration of " << @walker.email.to_s << " was cancelled."
      else
        flash.notice = "Delete failed."
      end
    else
      flash.notice = "Registration not found."
    end

		redirect_to :action => 'show'

	end
	
	def change_owner
	  @registration = Registration.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first
	end
	
	def change_owner_do
	  if $dc.id.modulo(10) == 0
	    flash.notice = "Registration could not be changed, race is in limited edition."
	    redirect_to :action => 'show'
	    return
	  end 
	  @changedReg = Registration.where(:id => "#{params[:id]}").first
	  if @changedReg.walker_id != current_walker[:id]
	    flash.alert = t "not own registration"
	    redirect_to :action => 'change_owner'
	    return
	  end
	  if not @changedReg.confirmed
	    flash.notice = "Only payed registration can be transferred."
	    redirect_to :action => 'show'
	    return
	  end
	  
	  @walker = Walker.where(:email => "#{params[:walker][:email]}").first
	  
	  if !@walker.nil? # walker exist?
	    # check if walker does not already have one (registration)
	    walkerReg = Registration.where(:dc_id => $dc.id, :walker_id => @walker.id).first
	    if !walkerReg.nil?
	      flash.alert = t("walker already registered")
	      redirect_to :action => 'change_owner'
	      return
	    end
	    
	    # OK walker exist and does not have registration for current DC - switch owner
	    @changedReg[:walker_id] = @walker[:id]
	    @changedReg[:phone] = @walker[:phone]
	    begin
	      @changedReg.save!
	      flash.notice = t("registration transferred") << " " << @walker.name << " " << @walker.surname << " (" << @walker.email << ")"
	      WalkerMailer.notify_registration_transfer(current_walker, @walker)
	      redirect_to :controller => 'pages', :action => 'actual'
	      return
	    rescue => e
	      flash.alert = t("reg transfer error") << e.message
	      redirect_to :action => 'change_owner'
	      return
	    end
    else
      flash.alert = t("unknown email") << ": " << "#{params[:walker][:email]}"
      redirect_to :action => 'change_owner'
	  end	  
	end
end
