class EventsController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Web methods:

  # Shows all events, or all events for walker id
  # May be memory inefficient, for debuging purposes only
  # /events/dump
  # /events/dump/{id}
  def dump
    if params[:id].present?
      @events = Event.where(:walker_id => params[:id]).order(:id)
    else
      @events = Event.order(:id)
    end
  end

  # Generates KML 2.2 output of all events, or all events for walker id
  # May be memory inefficient, for debuging purposes only
  # /events/mapdump.xml
  # /events/mapdump/{id}.xml
  # Redirect to Google Maps
  # /events/mapdump
  # /events/mapdump/{id}
  def mapdump
    if request.format.xml?
      @checkpoints = Checkpoint.where(:dc_id => $dc.id).order(:checkid)
      @checkpoints_count = @checkpoints.count

      if params[:id].present?
        @locationUpdates = Event.where(:dc_id => $dc.id, :walker_id => params[:id], :eventType => "LocationUpdate").order("\"eventId\"")
        render "map_for_walker"
      else
        @locationUpdates = Event.where(:dc_id => $dc.id, :eventType => "LocationUpdate").order(:walker_id, "\"eventId\"")
        render "map_for_all_walkers"
      end

    else # Google maps redirect and added timestamp for bypassing their cache
      redirect_to "https://maps.google.com/maps?q=" + request.original_url + ".xml?t=" + Time.now.to_i.to_s
    end
  end

  # Generates KML 2.2 positions of all walkers
  # /events/map.xml
  # Redirect to Google Maps
  # /events/map
  def map # TODO: move to race_controller
    if request.format.xml?
      @checkpoints = Checkpoint.where(:dc_id => $dc.id).order(:checkid)
      @checkpoints_count = @checkpoints.count

      @races = Race.where(:dc_id => $dc.id)
      render "map_of_race"

    else # Google maps redirect and added timestamp for bypassing their cache
      redirect_to "https://maps.google.com/maps?q=" + request.original_url + ".xml?t=" + Time.now.to_i.to_s
    end
  end

end
