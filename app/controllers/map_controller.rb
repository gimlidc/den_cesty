# Public map of competitors.
# 
# Author::  Lukáš Machalík
# 
class MapController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  # Redirects for recent race map.
  #
  # Available with: GET /map
  def index
    # Redirect to last visible race
    race = Race.where(:visible => true).last
    if !race.nil?
      redirect_to :action => :show, :id => race.id
    else
      redirect_to :controller => "pages", :action => "unauthorized"
    end
  end

  # Shows map of competitors for given race id.
  # 
  # Available with: GET /map/:id
  def show
    @race = Race.find_by_id(params[:id])

    if !@race.nil? && @race.visible then # && @race.start_time < Time.now then
      @checkpoints = @race.checkpoints.select([:latitude, :longitude])
      @scoreboard = @race.scoreboard.joins(:walker).select([:name, :surname, :distance, :latitude, :longitude])
    else
      flash.notice = "Map will be available after the race start."
      redirect_to :controller => "pages", :action => "unauthorized"
    end
  end

end
