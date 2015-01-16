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
      @events = Event.where(:dc_id => [0, $dc.id]).order(:id)
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

  # API methods:

  # Process JSON request for sending events for walker id.
  # Returns JSON with event ids of processed events.
  # /events/create/{id}
  def create
    in_race = Time.now > $dc_app_start && Time.now < $dc_app_end

    saved = []
    jsonHash = request.POST[:_json];
    jsonHash.each do |jsonEvent|
      event = Event.new
      if in_race
        event.dc_id = $dc.id
      else
        event.dc_id = 0 # request is not during race (probably testing)
      end
      event.walker_id = params[:id]
      event.eventId = jsonEvent["eventId"]
      event.eventType = jsonEvent["type"]
      event.eventData = jsonEvent["data"]
      event.batteryLevel = jsonEvent["batL"]
      event.batteryState = jsonEvent["batS"]
      event.timestamp = Time.zone.parse(jsonEvent["time"])
      if event.save # if new
        saved << jsonEvent["eventId"]
        if in_race
          after_create(event)
        end
      else # if exists
        saved << jsonEvent["eventId"]
        puts "Not Saved!" # debug print
        puts jsonEvent    # debug print 
      end
    end
    render :json => {:savedEventIds => saved}
  end

  private

    # Event processing after creating new event in db
    def after_create(event)
      
      start_race(event)
      stop_race(event)
      update_distance(event)

    end

    # Process event with type StartRace. Updates race info in table Race for particular walker.
    def start_race(event)
      if (event.eventType == "StartRace")
        #Create race if not exists
        race_info = Race.new(:dc_id => $dc.id, :walker_id => event.walker_id, :raceState => 1,
                             :lastCheckpoint => 0, :distance => 0, :avgSpeed => 0)
        if !race_info.save
          # if exists, just update raceState
          race_info = Race.where(:dc_id => $dc.id, :walker_id => event.walker_id).first
          race_info.raceState = 1
          race_info.save
        else
          # if new, set location to Dc start location (checkpoint 0)
          start = Checkpoint.where(:dc_id => $dc.id, :checkid => 0).first
          race_info.latitude = start.latitude
          race_info.longitude = start.longitude
          race_info.save
        end
      end
    end

    # Process event with type StopRace. Updates race state field in table Race for particular walker.
    def stop_race(event)
      if (event.eventType == "StopRace")
        race_info = Race.where(:dc_id => $dc.id, :walker_id => event.walker_id).first
        race_info.raceState = 2
        race_info.save
      end
    end

    # Process event with type LocationUpdate. Updates distance field in table Race for particular walker.
    def update_distance(event)
      if (event.eventType == "LocationUpdate")
        if event.eventData['horAcc'] < 200 # inaccurate location updates filter

          raceInfo = Race.where(:dc_id => $dc.id, :walker_id => event.walker_id).first
          latitude = event.eventData['latitude']
          longitude = event.eventData['longitude']

          # gets checkid of finish (actually the last one is not finish, the previous one is)
          lastCheckId = Checkpoint.where(:dc_id => $dc.id).maximum(:checkid) - 1 

          # saves last checkpoint to nextCheckpoint; it's outside of for loop for better performance (see below)
          nextCheckpoint = Checkpoint.where(:dc_id => $dc.id, :checkid => raceInfo.lastCheckpoint).first

          # distance from last checkpoint to walker location; it's outside of for loop for better performance (see below)
          distance_next = gps_distance [nextCheckpoint.latitude,nextCheckpoint.longitude],[latitude,longitude]

          for i in raceInfo.lastCheckpoint .. lastCheckId
            lastCheckpoint = nextCheckpoint # it's already computed in previous iteration
            nextCheckpoint = Checkpoint.where(:dc_id => $dc.id, :checkid => i+1).first

            # distance from last checkpoint to walker location
            distance_last = distance_next # it's already obtained in previous iteration
            # distance from walker location to next checkpoint
            distance_next = gps_distance [latitude, longitude],[nextCheckpoint.latitude,nextCheckpoint.longitude]
            # distance between checkpoints
            distance_between = gps_distance [lastCheckpoint.latitude,lastCheckpoint.longitude],[nextCheckpoint.latitude,nextCheckpoint.longitude]

            # only if walker location is between checkpoints
            if distance_next < distance_between && distance_last < distance_between

              progress_between = distance_last / (distance_last+distance_next) # percentage of elapsed distance between checkpoints
              real_distance_between = nextCheckpoint.meters - lastCheckpoint.meters # real distance between checkpoints
              new_distance = (progress_between * real_distance_between).to_i + lastCheckpoint.meters # convertion of elapsed distance to real distance

              if raceInfo.distance < new_distance # is walker farther away than before
                raceInfo.distance = new_distance
                raceInfo.avgSpeed = ((new_distance / (event.timestamp - $dc.start_time))*3.6).round(2) # v = s/t converted to km/h and rounded :-)
                raceInfo.lastCheckpoint = i
                raceInfo.latitude = latitude
                raceInfo.longitude = longitude
                raceInfo.save
                event.eventData["distance"] = new_distance # marks event with calculated distance, for future debugging
                event.save
                puts "Distance updated to: "+new_distance.to_s # debug print
              end

              break # it's between checkpoints, so there is no need to continue checking other checkpoints (it ends for loop)
            end
            # else continue for loop

          end
        end
      end
    end

    # GPS distance calculation using Haversine formula
    # From: http://stackoverflow.com/a/12969617
    def gps_distance a, b
      rad_per_deg = Math::PI/180  # PI / 180
      rkm = 6371                  # Earth radius in kilometers
      rm = rkm * 1000             # Radius in meters

      dlon_rad = (b[1]-a[1]) * rad_per_deg  # Delta, converted to rad
      dlat_rad = (b[0]-a[0]) * rad_per_deg

      lat1_rad, lon1_rad = a.map! {|i| i * rad_per_deg }
      lat2_rad, lon2_rad = b.map! {|i| i * rad_per_deg }

      a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

      rm * c # Delta in meters
    end
end
