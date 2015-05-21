# CRUD controller for Scoreboard (race live rankings).
#
# Accessible only for administrators.
# 
# Author::  Lukáš Machalík
# 
class ScoreboardController < ApplicationController

  # Shows race progress and walkers ordered by elapsed distance.
  #
  # Available with: GET /races/:race_id/scoreboard
  def index
    @race = Race.find(params[:race_id])
    @scoreboard = @race.scoreboard.order("distance DESC")
  end

  # Deletes Scoreboard with given id.
  #
  # Available with: DELETE /races/:race_id/scoreboard/:id
  def destroy
    race = Race.find(params[:race_id])

    @scoreboard = race.scoreboard.find(params[:id])
    @scoreboard.destroy

    flash[:notice] = "Scoreboard entry for '#{@scoreboard.walker.nameSurname}' destroyed successfully."
    redirect_to(race_scoreboard_index_url)
  end

end
