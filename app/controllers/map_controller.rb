class MapController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  def index
    # Redirect to last visible race
    race = Race.where(:visible => true).last
    if !race.nil?
      redirect_to :action => :show, :id => race.id
    else
      redirect_to :controller => "pages", :action => "unauthorized"
    end
  end

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

  def walker
    @race = Race.find_by_id(params[:race_id])

    if !@race.nil? && @race.visible then # && @race.start_time < Time.now then
      @checkpoints = @race.checkpoints.select([:latitude, :longitude])
      events = @race.events.where(:walker_id => params[:walker_id]).order(:timestamp)

      events.each do |event|
        data = JSON.parse event.eventData.to_s.gsub('=>', ':')
        if (data["latitude"].nil?)
          next
        end
        trk = {}
        trk[:latitude] = data["latitude"]
        trk[:longitude] = data["longitude"]
        @trks << trk
      end

    else
      flash.notice = "Race not yet started or not exist."
      redirect_to :controller => "pages", :action => "unauthorized"
    end

  end

end
