class PagesController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  def actual
		@registered_walkers = Registration.where(:dc_id => $dc.id, :canceled => false).joins(:walker).order(:surname, :name)
		render "podzim2013.html.erb"
  end

	def rules
		if I18n.locale == :cs
			render "pravidla.html.erb"
		else
			render "rules.html.erb"
		end
	end

	def hall_of_glory

	end
	
	def dc_results
	  # shows results reached in each year
	  if params[:get].nil?
	    @dc_id = $dc.id
	  else
	    @dc_id = params[:get][:dc_id]
	  end
	  @dcs = Dc.order(:start_time).all
	  @results = Result.where(:dc_id => @dc_id).order('distance DESC').all
	end

	def contacts
		if I18n.locale == :cs
			render "kontakty.html.erb"
		else
			render "contacts.html.erb"
		end
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
