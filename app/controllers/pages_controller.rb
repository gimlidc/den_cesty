class PagesController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  def running_results
    @race = Race.find(params[:id])
    @scoreboard = @race.scoreboard.order("distance DESC")
  end

  def tracker_info
    
  end

  def actual
    # print results if the newest race was already started
		@race = Race.find($race_id)
    if (Time.now > $dc.start_time)
		  @results = Result.where(:dc_id => $dc.id).order('official DESC, distance DESC').all		
		else # otherwise print proposition of the current race
		  @registered_walkers = Registration.includes(:walker)
																.where(:dc_id => $dc.id, :canceled => false)
                                .order('walkers.surname', 'walkers.name')
      @registered = ActiveRecord::Base.connection.execute("select reg.id, reg.name, reg.surname, result.official, reg.updated_at, reg.confirmed from (select walkers.id as id, walkers.name as name, walkers.surname as surname, registrations.updated_at as updated_at, registrations.confirmed as confirmed from registrations join walkers on (registrations.walker_id = walkers.id) where registrations.canceled = false and registrations.dc_id = "+$dc.id.to_s+") as reg left outer join (select MAX(results.official) as official, results.walker_id from results group by walker_id) as result on (reg.id = result.walker_id) order by result.official DESC, reg.surname, reg.name");
		  render "dc".concat($dc.id.to_s).concat(".html.erb")
		end
  end

	def rules
		if I18n.locale == :cs
			render "pravidla.html.erb"
		else
			render "rules.html.erb"
		end
	end

	def hall_of_glory
    @year_maxima = Result.group(:dc_id).order(:dc_id).maximum(:distance)
    @dc_max = []    
    Dc.all.each do |dc|
      @dc_max[dc.id] = Result.where(:dc_id => dc.id, :distance => @year_maxima[dc.id]).joins(:walker).order('walkers.surname').all      
    end
    
    @records = @dc_max.flatten(1)
    
    @recordmans = Hash.new
    
    @dr = []  
    size = @year_maxima.keys.last
    # for each year count DR
    @year_maxima.each do |j,value|            
      if @year_maxima[j].nil? # if no maxima in year is set, skip to next year
        @dr[j] = 1        
        next;
      end
      i = j - 1            
      @dr[j] = 1
      while i > 0 do
        if !@year_maxima[i].nil?
          if @year_maxima[i] <= value
            @dr[j] = @dr[j] + 1
          else
            break;
          end
        end
        i = i - 1
      end
      i = j + 1
      while i <= size do
        if !@year_maxima[i].nil?
          if @year_maxima[i] <= value
            @dr[j] = @dr[j] + 1
          else
            break;
          end
        end
        i = i + 1
      end
      @dc_max[j].each do |result|
        if @recordmans[result.walker_id].nil? || @recordmans[result.walker_id][:dr] < @dr[j]
          @recordmans[result.walker_id] = { :name => result.walker.name, :surname => result.walker.surname, :dr => @dr[j] }
        end
      end      
    end
    @recordmans = @recordmans.sort_by{|k, v| v[:dr]}.reverse
	end
	
	def statistics
	  @sums = Result.joins(:walker).group(:walker_id, :name, :surname).select('walkers.name as name, walkers.surname as surname, sum(distance) as sum').order('sum DESC')
	  @avgs = Result.joins(:walker).group(:walker_id, :name, :surname).select('walkers.name as name, walkers.surname as surname, avg(distance) as avg').order('avg DESC')
	  @dc_best = Result.maximum(:official)
	  @dc_avg = Result.average(:official)
	  @dc_sum = Result.sum(:official)
	  @distanceOrder = Result.where('official is not null').order('official DESC').limit(100)
	end
	
	def dc_results
	  # shows results reached in each year
	  if params[:dc_id].nil?
	    @dc_id = $dc.id - 1
	  else
	    @dc_id = params[:dc_id]
	  end
	  @dcs = Dc.order(:start_time).all
	  @results = Result.where(:dc_id => @dc_id).order('official DESC, distance DESC').all
	end

	def contacts
		if I18n.locale == :cs
			render "kontakty.html.erb"
		else
			render "contacts.html.erb"
		end
	end
	
	def history
	  @dcs = Dc.order(:id).all
	end
	
	def unauthorized
	  
	end
	
	def walker_results
	  @walkers = Walker.order(:surname, :name).all
	  if !params[:walker].nil?
	    params[:walker].each do |key, value|
	      walker_id = value.to_i
	      if key == "first"
	        @walker_first = Walker.find(walker_id)
	        @results_first = Result.where(:walker_id => walker_id).order(:dc_id)
	      else
	        @walker_second = Walker.find(walker_id)
          @results_second = Result.where(:walker_id => walker_id).order(:dc_id)
	      end
	    end
	  end
	end
	
end
