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
    if (Time.now > $dc.start_time)
		  @results = Result.where(:dc_id => $dc.id).order('official DESC, distance DESC').all		
		else # otherwise print proposition of the current race
		  @registered_walkers = Registration.joins(:walker).where(:dc_id => $dc.id, :canceled => false).order(:surname, :name)
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
      @dc_max[dc.id] = Result.where(:dc_id => dc.id, :distance => @year_maxima[dc.id]).joins(:walker).order(:surname).all      
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
      while i < size do
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
	
	def dc_results
	  # shows results reached in each year
	  if params[:get].nil?
	    @dc_id = $dc.id
	  else
	    @dc_id = params[:get][:dc_id]
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
