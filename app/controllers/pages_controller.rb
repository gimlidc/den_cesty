class PagesController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  def actual
		@registered_walkers = Registration.where(:dc_id => $dc.id, :canceled => false).joins(:walker).order(:username)
		render "jaro2013.html.erb"
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

	def contacts
		if I18n.locale == :cs
			render "kontakty.html.erb"
		else
			render "contacts.html.erb"
		end
	end
	
	def unauthorized
	  
	end
	
end
