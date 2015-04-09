class AdminController < ApplicationController

	def add_report
			@walkers = Walker.order("surname")
      @dcs = Dc.order("id")
	end

	def save_report
			@report = Report.where(:walker_id => params[:walker][:id], :dc_id => params[:dc][:id]).first
			@walker = Walker.find(params[:walker][:id])

			if @report.nil?	&& !@walker.nil?
				@dc_id = Integer("#{params[:dc][:id]}")

				report = Report.new
				report.dc_id = @dc_id
				report.walker_id = Integer("#{params[:walker][:id]}")
				report.report_html = params[:report_html]

				if report.save
					flash[:notice] = "Report successfully stored #{report.walker.nameSurnameYear}, #{report.dc.specifyName}"
				else
					flash[:alert] = "Report save failed"
				end
			else
				if !@walker.nil?
					flash[:alert] = "You are trying to rewrite existing report. Action was canceled."
				else
					flash[:alert] = "Unknown walker id."
				end
			end

			redirect_to :controller => 'report', :action => 'list', :id => @dc_id, :author => params[:walker_id]
	end
	
	# page allowing creation of new registration
	def register
	  walker_id = "#{params[:id]}"
    @walker = Walker.find(walker_id)
    @registration = Registration.where(:walker_id => walker_id, :dc_id => $dc.id).first
    
    if @registration.nil?
      @registration = Registration.new
      @new_registration = true
    end
  end
  
  # method edit existing registration or creates new one
  def register_do
    # check if there is only one registration for specified walker
    @regs = Registration.where(:dc_id => $dc.id, :walker_id => "#{params[:registration][:walker_id]}")
    if (@regs.size > 1) # there is more than one registration for the walker
      @regs.each do |reg|
        reg.delete # remove them all
      end
    end
    
    # try to find registration
    @reg = Registration.where(:dc_id => $dc.id, :walker_id => "#{params[:registration][:walker_id]}").first
    # is there registration of the walker for current dc?
    if (@reg.nil?) # no -> create it
      @reg = Registration.new(params[:registration])
      if @reg.save # save
        flash.notice = "Registration successfully created."
      else
        # this is strange - check DB health
        flash.notice = "Error registration not saved."
      end
    else # there is already one registration -> update parameters according to admin form
      if @reg.update_attributes(params[:registration])
        flash.notice = "Registration successfully updated."
      else
        flash.notice = "Error registration not saved."
      end
    end
    redirect_to admin_registered_path
  end
	
	def registered
	  @registration = Registration.joins(:walker).where(:canceled => false, :dc_id => $dc.id).order('walkers.surname')
    @reg = Registration.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first
    @bwmaps = @registration.where(:bw_map => true, :canceled => false).count
    @colormaps = @registration.where(:colour_map => true, :canceled =>false, :confirmed => true).count
    # table of shirts according to: [typ={cotton, pes}, sex={F,M}, velikost={S-XXL}]
    scarfs = Registration.where(:canceled => false, :confirmed => true, :dc_id => $dc.id, :scarf => true).count
    # female cotton
    fCShirt = Hash.new(0)
    # male cotton
    mCShirt = Hash.new(0)
    # female polyester
    fPShirt = Hash.new(0)
    # male polyester
    mPShirt = Hash.new(0)
    $shirt_sizes.each do |size| # fill whole table
      fCShirt[size] = @registration.where(:confirmed => true, :shirt_size => size, :walkers => { :sex => "female" }).size
      mCShirt[size] = @registration.where(:confirmed => true, :shirt_size => size, :walkers => { :sex => "male" }).size
      fPShirt[size] = @registration.where(:confirmed => true, :shirt_polyester => size, :walkers => { :sex => "female" }).size
      mPShirt[size] = @registration.where(:confirmed => true, :shirt_polyester => size, :walkers => { :sex => "male" }).size
    end
    @textil = { "scarfs" => scarfs, "damskyPolyester" => fPShirt, "panskyPolyester" => mPShirt, "damskaBavlna" => fCShirt, "panskaBavlna" => mCShirt }
  end
  
  def gimli_test
    flash.notice = "Mail sent to gimli"
    WalkerMailer.send_spam(Walker.find(1), "[DC]: mailer testing email", "Pokud tento mail dorazil, mailer funguje spravne.").deliver
    redirect_to admin_registered_path
  end
  
  def payment_notification
    @registrations = Registration.where(:confirmed => false, :canceled => false, :dc_id => $dc.id)
    if !@registrations.empty?
      flash.notice = "Mail send to: "
      @registrations.each do |registration|
        WalkerMailer.send_payment_request(registration).deliver
        flash.notice += registration.walker.email + ", "
      end
    else
      flash.notice = "All registrations have been paid."
    end
    redirect_to admin_registered_path
  end
  
  def cleanup_unpaid_textile
    @registrations = Registration.where(:confirmed => false, :canceled => false, :dc_id => $dc.id)
    @registrations.each do |registration|
      registration.scarf = false
      registration.shirt_size = 'NO'
      registration.shirt_polyester = 'NO'
      if !registration.save
        flash.notice += "Registration "+registration.id+" save failed.<br />"
      else
        WalkerMailer.notify_registration_update(registration).deliver
        flash.notice = "Mail send to: " + registration.walker.email
       end
    end
    redirect_to admin_registered_path
  end

  def cleanup_unpaid_maps
    @registrations = Registration.where(:confirmed => false, :canceled => false, :dc_id => $dc.id)
    @registrations.each do |registration|
      registration.colour_map = false
      if !registration.save
        flash.notice += "Registration "+registration.id+" save failed.<br />"
      else
        WalkerMailer.notify_registration_update(registration).deliver
        flash.notice = "Mail send to: " + registration.walker.email
      end
    end
    redirect_to admin_registered_path
  end

	def merge		
			@walker_a = Walker.find(params[:walker][:id])
			@walker_b = Walker.find(params[:walker_virtual][:id])
			if !@walker_a.nil? && !@walker_b.nil?
				@results_a = Result.where(:walker_id => @walker_a.id).order(:dc_id)
				@results_b = Result.where(:walker_id => @walker_b.id).order(:dc_id)

				# check problems in results
				a=0
				b=0
				for i in 1..$dc.id
					while(!@results_a[a].nil? && @results_a[a].dc_id < i)
						a += 1
					end
					while(!@results_b[b].nil? && @results_b[b].dc_id < i)
						b += 1
					end

					if (!@results_b[b].nil? && @results_a[a] == @results_b[b])
						flash[:alert] = "Conflict in results: #{@results_a[a]}, double record! Merge failed"
						redirect_to :action => 'merge_list'
						return
					end
				end

				@reports_a = Report.where(:walker_id => @walker_a.id).order(:dc_id)
				@reports_b = Report.where(:walker_id => @walker_b.id).order(:dc_id)

				# check problems in reports
				a=0
				b=0
				for i in 1..$dc.id
					while(!@reports_a[a].nil? && @reports_a[a].dc_id < i)
						a += 1
					end
					while(!@reports_b[b].nil? && @reports_b[b].dc_id < i)
						b += 1
					end

					if (!@reports_a[a].nil? && @reports_a[a] == @reports_b[b])
						flash[:alert] = "Conflict in reports: #{@reports_a[a]}, double record! Merge failed"
						redirect_to :action => 'merge_list'
						return
					end
				end

				#everything seems to be OK
				if !@results_a.nil? && !@results_a.empty?
					@results_a.each do |result|
						result.walker_id = @walker_b.id
						if !result.save
							flash[:alert] = "Result #{result.id} rewrite walker_id failed. Please do it manually\n"
						end
					end
				end

				if !@reports_a.nil? && !@reports_a.empty?
					@reports_a.each do |report|
						report.walker_id = @walker_b.id
						if !result.save
							flash[:alert] = "Result #{result.id} rewrite walker_id failed. Please do it manually\n"
						end
					end
				end

				if !@walker_a.delete
					flash[:alert] = "Merged walker #{@walker_b.id} cannot be deleted. Do it manually.\n"
				else
					flash[:notice] = "Merge successful\n"
				end
			else
				flash[:alert] = "Walkers not found"
			end
			redirect_to :action => 'merge_list'		
	end

	def merge_list
			@walkers = Walker.where(:virtual => false).order("surname, name")
			@walkers_virtual = Walker.where(:virtual => true).order("surname, name")
	end

	def print_list
		@registration = Registration.joins(:walker).where(:canceled => false, :dc_id => $dc.id).order('walkers.surname')
	end

	def results_update
	  @results = params[:results] 
	  
		@results.each do |key, value|
		  if value[:distance] == '' && value[:official] == ''
		    next
		  end
		  
      result = Result.first(:conditions => {:walker_id => value[:walker_id], :dc_id => value[:dc_id]})
      
      if result.nil?
        result = Result.create(:walker_id => value[:walker_id], :dc_id => value[:dc_id], :distance => value[:distance], :official => value[:official])
      else
        result.update_attributes(:distance => value[:distance], :official => value[:official])
      end
  
    end
    
    redirect_to :action => 'results_setting', :id => params[:dc_id]
	end

	def results_setting
			if params[:id].nil?
				@set_dc = $dc.id
			else
				@set_dc = Integer("#{params[:id]}")
			end
			
			@walkers = Walker.find_by_sql("SELECT wal_reg.id AS id, name, surname, year, wal_reg.dc_id AS dc_id, distance, official FROM (SELECT walkers.id AS id, name, surname, year, registrations.dc_id AS dc_id FROM walkers JOIN registrations ON walkers.id = registrations.walker_id WHERE registrations.dc_id = #{@set_dc} AND canceled = 'false') AS wal_reg LEFT OUTER JOIN results ON wal_reg.id = results.walker_id AND wal_reg.dc_id = results.dc_id ORDER BY surname, name")
	end

	def results_list

	end

	def walker_create
			@walkers = Walker.where(:name => params[:walker][:name], :surname => params[:walker][:surname])
			if @walkers.nil? || @walkers.empty?
				walker = Walker.new(params[:walker])
        if params[:walker][:email].empty?
				  walker.email = "#{walker.id}@#{walker.name}.#{walker.surname}"
        else
          walker.email = params[:walker][:email]
        end
				walker.sex = params[:walker][:sex]
				if walker.save(:validate => false)
					flash[:notice] = "Walker created"
				else
					flash[:notice] = "Walker creation failed"
				end
			else
				flash[:alert] = "Walker with the same name exist!"
			end
		redirect_to :action => 'walker_list'
	end

	def walker_list		
      @walkers = Walker.all.order("surname, name")
			@new_walker = Walker.new		
	end

	def walker_update
    walker = Walker.find(params[:walker][:id])

			if walker.nil?
				@notice = "Walker not found."
			else
				if (params[:walker][:vokativ].nil?)
					validate = false
				else
					walker.vokativ = params[:walker][:vokativ]
					walker.email = params[:walker][:email]
				end
				walker.name = params[:walker][:name]
				walker.surname = params[:walker][:surname]
				walker.phone = params[:walker][:phone]
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
	end

	def walker_destroy
		
			@walker = Walker.find(params[:id])
			if !@walker.nil? && @walker.destroy
				@notice = "Destroy successful"
			else
				@notice = "Walker not destroyed."
			end

			redirect_to :action => 'walker_list'		
	end

	def unauthorized

	end

end
