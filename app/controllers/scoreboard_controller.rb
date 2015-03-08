class ScoreboardController < ApplicationController
  
  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?


  # Shows race progress and walkers order based on elapsed distance.
  # /scoreboard/id
  def index
    @race = Race.find(params[:id])
    @scoreboard = @race.scoreboard.order("distance DESC")
  end

end
