class ReportController < ApplicationController

	def list
		@dc_id = (params[:id].nil? || params[:id] == "") ? nil : params[:id]
		@author = (params[:author].nil? || params[:author] == "") ? nil : Walker.find(:all, :conditions => { :id => params[:author] })[0]

		if (@dc_id == nil && @author == nil)
			@reports = Report.joins(:walker).find(:all)
			@walkers = Report.joins(:walker).select("username, walker_id").uniq
		else
			if (@author == nil)
				@dc_id = params[:id]
				@reports = Report.joins(:walker).find(:all, :conditions => {:dc_id => @dc_id})
				@walkers = Report.joins(:walker).where(:dc_id => @dc_id).select("username, walker_id").uniq
			else
				if (@dc_id == nil)
					@reports = Report.joins(:walker).find(:all, :conditions => {:walker_id => params[:author]})
					@walkers = Report.joins(:walker).select("username, walker_id").uniq
				else
					@dc_id = params[:id]
					@reports = Report.joins(:walker).find(:all, :conditions => {:dc_id => @dc_id, :walker_id => params[:author]})
					@walkers = Report.joins(:walker).where(:dc_id => @dc_id).select("username, walker_id").uniq
				end
			end
		end

		@dc_select=""
		for i in 1..$current_dc_id do
			if @dc_id != nil && i == Integer(@dc_id)
				@dc_select+="<option value=#{i} selected=\"selected\">#{$dc_spec[i-1]}</option>\n"
			else
				@dc_select+="<option value=#{i}>#{$dc_spec[i-1]}</option>\n"
			end
		end

	end

	def new
		if !report_accessible?
			redirect_to :action => :list
		end

		if !walker_signed_in?
			redirect_to :action => :unauthorized
		end

		if has_report?
			flash[:notice] = "Report already exist, redirected to editing report."
			redirect_to :action => :edit
		end

		@report = Report.new
	end

	def edit
		if !report_accessible?
			redirect_to :action => :list
		end

		if !walker_signed_in?
			redirect_to :action => :unauthorized
		end

		if !has_report?
			flash[:notice] = "No report found, redirected to new report."
			redirect_to :action => :new
		end

		@report = Report.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})
	end

	def show
		if !has_report?
			flash[:notice] = "No report found!"
		end

		@report = Report.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})[0]
	end

	def save
		if !walker_signed_in?
			redirect_to :action => :unauthorized
		end

		@report = Report.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})

		if @report.nil? || @report.empty?
			@report = Report.new
			@report.walker_id = current_walker[:id]
			@report.dc_id = $current_dc_id
		else
			@report = @report[0]
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
		@report = Report.all(:conditions => {:dc_id => $current_dc_id, :walker_id => current_walker[:id] })
		return !@report.nil? && !@report.empty?
	end

	def report_accessible?
		return Time.now > $dc_date && Time.now < $report_deadline
	end

end
