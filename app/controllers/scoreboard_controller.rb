class ScoreboardController < ApplicationController
  
  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Web methods:

  # Shows race progress and walkers order based on elapsed distance.
  # /scoreboard
  def index
    @scoreboard = Scoreboard.where(:dc_id => $dc.id).order("distance DESC")
  end

end
