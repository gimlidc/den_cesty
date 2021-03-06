require 'rest-client'

class AdminController < ApplicationController

  include RegistrationsHelper

	def add_report
			@walkers = Walker.order("surname")
      @dcs = Dc.order("id")
	end

  def make_distance_official
      results = Result.where('dc_id < ?', 19)
      results.each do |result|
        result.official = result.distance
        if !result.save
          flash.alert("Update of official failed. Please try it again.")
        end
      end
      redirect_to root_path
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
	  @registration = Registration.joins(:walker).where(:dc_id => $dc.id).order('walkers.surname')
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
        if (registration.scarf == true || registration.shirt_size != 'NO' || registration.shirt_polyester != 'NO' || registration.colour_map == true)
          WalkerMailer.send_payment_request(registration).deliver
          flash.notice += registration.walker.email + ", "
        end
      end
    else
      flash.notice = "All registrations have been paid."
    end
    redirect_to admin_registered_path
  end

  def payments_download
    json = RestClient.get 'https://www.fio.cz/ib_api/rest/periods/95EXD0vTvuF7VUkXia6x8RdLiKZ045cIYpWhq68BxWzXl9pcXM4S6MfiBszGf52c/2020-03-01/2020-06-30/transactions.json'

    data = JSON.parse(json)
    added = []
    badVS = []
    badSS = []
    notMatched = []
    badAmount = []
    alreadyMatched = []

    data['accountStatement']['transactionList']['transaction'].each do |transaction|
      if transaction['column6'].nil? || transaction['column6']['value'] == "666"
        # unfilled KS we ignore and try to match the payment according to VS
        if transaction['column5'].nil? || transaction['column5']['value'].nil?
          badVS.push(transaction['column5'])
          logger.info("VS is not set. Payment ignored: " + transaction['column1']['value'].to_s)
        else
          dcId = transaction['column5']['value'].to_i / 10000
          walkerId = transaction['column5']['value'].to_i % 10000
          reg = Registration.where(dc_id: dcId, walker_id: walkerId)
          if reg.length && reg.length == 1
            price = price(reg[0])
            if price == transaction['column1']['value']
              if !reg[0].confirmed?
                added.push(walkerId)
                reg[0].confirmed = true
                reg[0].save
              else
                alreadyMatched.push(walkerId)
              end
            else
              badAmount.push([ "id", walkerId, "amount", transaction['column1']['value'] ])
              logger.warn("Price payed and required vary. Required: " + price.to_s + " Payed: " + transaction['column1']['value'].to_s + " WalkerId: " + walkerId.to_s)
            end
          else
            notMatched.push(transaction['column5']['value'])
            logger.info("VS mapping to dcId and walkerId failed. VS:" + transaction['column5']['value'] + " No record found.")
          end
        end
      else
        badSS.push(transaction['column1']['value'])
        logger.info("Payment with set but unknown SS - ignored" + transaction['column1']['value'].to_s)
      end
    end
    flash.notice = ["Paired payments:" + added.map { |wid| wid.to_s }.join(", "),
      "Bad amount: " + badAmount.map { |wid| wid.to_s }.join(", "),
      "Bad VS:" + badVS.join(", "),
      "Urecognized registration: " + notMatched.join(", "),
      "Not matched SS (other payments): " + badSS.join(", ")]
    redirect_to admin_registered_path
  end

  def cleanup_unpaid_textile
    flash.notice = "Mail send to:"
    @registrations = Registration.where(:confirmed => false, :dc_id => $dc.id)
    @registrations.each do |registration|
      if (registration.scarf == true || registration.shirt_size != 'NO' || registration.shirt_polyester != 'NO')
        registration.scarf = false
        registration.shirt_size = 'NO'
        registration.shirt_polyester = 'NO'
        if !registration.save
          flash.notice += "Registration " + registration.id.to_s + " save failed.<br />"
        else
          if !registration.canceled
            WalkerMailer.notify_registration_update(registration).deliver
            flash.notice +=  "<br />" + registration.walker.email
          end
        end
      end
    end
    redirect_to admin_registered_path
  end

  def cleanup_unpaid_maps
    flash.notice = "Mail send to: "
    @registrations = Registration.where(:confirmed => false, :dc_id => $dc.id, :colour_map => true)
    @registrations.each do |registration|
      registration.colour_map = false
      if !registration.save
        flash.notice += "Registration "+registration.id+" save failed.<br />"
      else
        if !registration.canceled
          WalkerMailer.notify_registration_update(registration).deliver
          flash.notice += "<br />" + registration.walker.email
        end
      end
    end
    redirect_to admin_registered_path
  end

	def merge		
			real = Walker.find(params[:walker][:id])
			virtual = Walker.find(params[:walker_virtual][:id])
			if real.nil? || virtual.nil?
			  flash[:alert] = "Walker not found in database"
			  redirect_to :action => 'merge_list'
			  return
			end
			
			# switch results
			results = Result.where(:walker_id => virtual.id).order(:dc_id)
			
			results.each do |result|
			  conflict = Result.where(:walker_id => real.id, :dc_id => result.dc_id)
			  if !conflict.nil? && !conflict.empty?
			    flash[:alert] = "RESULT conflict in DC" + result.dc_id + " double reference must be solved manually: " + real.id + "->" + virtual.id
			    redirect_to :action => 'merge_list'
			    return
			  end
			  result.walker_id = real.id
			  result.save
			end

      # switch reports
			reports = Report.where(:walker_id => virtual.id).order(:dc_id)
      reports.each do |report|
        conflict = Report.where(:walker_id => real.id, :dc_id => report.dc_id)
        if !conflict.nil? && !conflict.empty?
          flash[:alert] = "REPORT onflict in  DC" + report.dc_id + " double reference must be solved manually: " + real.id + "->" + virtual.id
          redirect_to :action => 'merge_list'
          return
        end
        report.walker_id = real.id
        report.save
      end
			
			# switch registrations
			registrations = Registration.where(:walker_id => virtual.id).order(:dc_id)
			registrations.each do |registration|
        conflict = Registration.where(:walker_id => real.id, :dc_id => registration.dc_id)
        if !conflict.nil? && !conflict.empty?
          flash[:alert] = "REPORT onflict in  DC" + registration.dc_id + " double reference must be solved manually: " + real.id + "->" + virtual.id
          redirect_to :action => 'merge_list'
          return
        end
        registration.walker_id = real.id
        registration.save
      end
			
			if !virtual.delete
        flash[:alert] = "Merged walker #{virtual.id} cannot be deleted. Do it manually.\n"
      else
        flash[:notice] = "Merge successful\n"
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
		  
      result = Result.where(:walker_id => value[:walker_id], :dc_id => value[:dc_id]).first
      
      if result.nil?
        result = Result.create(:walker_id => value[:walker_id], :dc_id => value[:dc_id], :distance => value[:distance], :official => value[:official])
      else
        result.update_attributes(:distance => value[:distance], :official => value[:official])
      end
  
      walker = Walker.find(value[:walker_id])
      walker.update_attributes(:lokal => value[:lokal])
  
    end
    
    redirect_to :action => 'results_setting', :id => params[:dc_id]
	end

	def results_setting
			if params[:id].nil?
				@set_dc = $dc.id
			else
				@set_dc = Integer("#{params[:id]}")
			end
			
			@walkers = Walker.find_by_sql("SELECT wal_reg.id AS id, name, surname, year, lokal, wal_reg.dc_id AS dc_id, distance, official FROM (SELECT walkers.id AS id, name, surname, year, lokal, registrations.dc_id AS dc_id FROM walkers JOIN registrations ON walkers.id = registrations.walker_id WHERE registrations.dc_id = #{@set_dc} AND canceled = 'false') AS wal_reg LEFT OUTER JOIN results ON wal_reg.id = results.walker_id AND wal_reg.dc_id = results.dc_id ORDER BY surname, name")
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
