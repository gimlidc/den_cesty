class ScoreboardController < ApplicationController

  skip_before_filter :check_admin?
  before_filter :check_logged_in?

  def check_ownership?
    race = Race.find(params[:race_id])
    if race.owner != current_walker.id and !is_admin?
      redirect_to(:controller => 'admin', :action => :unauthorized)
      return
    end
  end

  # Shows race progress and walkers order based on elapsed distance.
  # /races/:race_id/scoreboard
  def index
    check_ownership?
    @race = Race.find(params[:race_id])
    @scoreboard = @race.scoreboard.order("distance DESC")
  end

  # DELETE /races/:race_id/scoreboard/:id
  def destroy
    check_ownership?
    race = Race.find(params[:race_id])

    @scoreboard = race.scoreboard.find(params[:id])
    @scoreboard.destroy

    flash[:notice] = "Scoreboard entry for '#{@scoreboard.walker.nameSurname}' destroyed successfully."
    redirect_to(race_scoreboard_index_url)
  end

end
