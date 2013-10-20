class AdminController < ApplicationController

	def add_report
			@walkers = Walker.order("surname")
      @dcs = Dc.order("id")
	end

	def save_report
			@report = Report.find(:first, :conditions => { :walker_id => params[:walker][:id], :dc_id => params[:dc][:id]})
			@walker = Walker.find(:first, :conditions => { :id => params[:walker][:id]})

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
			@walkers = Walker.find(:all, :order => "surname, name", :conditions => {:virtual => false})
			@walkers_virtual = Walker.find(:all, :order => "surname, name", :conditions => {:virtual => true})		
	end

	def print_list
		@registration = Registration.joins(:walker).where(:canceled => false, :dc_id => $dc.id).order(:surname)
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
		redirect_to :action => 'walker_list'
	end

	def walker_list		
			@walkers = Walker.find(:all, :order => "surname, name")
			@new_walker = Walker.new		
	end

	def walker_update
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
