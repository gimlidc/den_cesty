class ReportController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?, :only => [:list] 
  
	def list
	  # 
		@dc_id = (params[:id].nil? || params[:id] == "") ? nil : params[:id]
		@author = (params[:walker].nil? || params[:walker] == "") ? nil :  Walker.where(:id => params[:walker]).first
    dcs = Dc.all().order(:id)
    @publishers = Walker.joins(:report).order(:surname).uniq

    # user does not select nothing
		if (@dc_id == nil && @author == nil)
			@reports = Report.joins(:walker).all.order('updated_at DESC')
		else
		  # user selects Den Cesty
			if (@author == nil)
				@dc_id = params[:id]
				@reports = Report.joins(:walker).where(:dc_id => @dc_id).order('updated_at DESC')
			# user selects Author
			else
			  # Den Cesty is also defined
				if (@dc_id == nil)
					@reports = Report.joins(:walker).where(:walker_id => params[:walker]).order('updated_at DESC')
				# wtf?
				else
					@dc_id = params[:id]
					@reports = Report.joins(:walker).where(:dc_id => @dc_id, :walker_id => params[:walker]).order('updated_at DESC')
				end
			end
		end

		@dc_select=""
		for i in 1..$dc.id do
			if @dc_id != nil && i == Integer(@dc_id)
				@dc_select+="<option value=#{i} selected=\"selected\">#{dcs[i-1].seasonYear} - #{dcs[i-1].name_cs}</option>\n"
			else
				@dc_select+="<option value=#{i}>#{dcs[i-1].seasonYear} - #{dcs[i-1].name_cs}</option>\n"
			end
		end

	end

	def new
		if !report_accessible?
			redirect_to :action => :list
			return
		end

		if !walker_signed_in?
			redirect_to :action => :unauthorized
			return
		end

		if has_report?
			flash[:notice] = "Report already exist, redirected to editing report."
			redirect_to :action => :edit
			return
		end

		@report = Report.new
	end

	def edit
		if !report_accessible?
			redirect_to :action => :list
			return
		end

		if !walker_signed_in?
			redirect_to :action => :unauthorized
			return
		end

		if !has_report?
			flash[:notice] = "No report found, redirected to new report."
			redirect_to :action => :new
			return
		end

		@report = Report.where(:walker_id => current_walker[:id], :dc_id => $dc.id)
	end

	def show
		if !has_report?
			flash[:notice] = "No report found!"
		end

		@report = Report.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first
	end

	def save
		if !walker_signed_in?
			redirect_to :action => :unauthorized
			return
		end

		@report = Report.where(:walker_id => current_walker[:id], :dc_id => $dc.id).first

		if @report.nil?
			@report = Report.new
			@report.walker_id = current_walker[:id]
			@report.dc_id = $dc.id
		end

		@report.report_html = params[:report][:report_html]
		if @report.save
			flash[:notice] = "Report successfuly saved"
		else
			flash[:notice] = "We apologize there is some problem with saving!"
		end

		redirect_to :action => 'show'
	end

	def unauthorized
		flash[:notice] = "You are not authorized for report editing"
		redirect_to :controller => 'pages', :action => 'actual'
	end

	def has_report?
		@report = Report.all(:conditions => {:dc_id => $dc.id, :walker_id => current_walker[:id] })
		return !@report.nil? && !@report.empty?
	end

	def report_accessible?
		return Time.now > $dc.start_time && Time.now < $report_deadline
	end

end
