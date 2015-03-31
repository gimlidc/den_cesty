class ScoreboardController < ApplicationController

  # Shows race progress and walkers order based on elapsed distance.
  # /races/:race_id/scoreboard
  def index
    @race = Race.find(params[:race_id])
    @scoreboard = @race.scoreboard.order("distance DESC")
  end

  # DELETE /races/:race_id/scoreboard/:id
  def destroy
    race = Race.find(params[:race_id])

    @scoreboard = race.scoreboard.find(params[:id])
    @scoreboard.destroy

    flash[:notice] = "Scoreboard entry for '#{@scoreboard.walker.nameSurname}' destroyed successfully."
    redirect_to(race_scoreboard_index_url)
  end

end
