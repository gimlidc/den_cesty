class ScoreboardController < ApplicationController

  # Shows race progress and walkers order based on elapsed distance.
  # /races/:race_id/scoreboard
  def index
    @race = Race.find(params[:race_id])
    @scoreboard = @race.scoreboard.order("distance DESC")
  end

end
