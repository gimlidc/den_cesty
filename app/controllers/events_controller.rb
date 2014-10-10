class EventsController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Web methods:

  # Shows all events, or all events for walker id
  # /events
  # /events/index/{id}
  def index
    if params[:id].present?
      @events = Event.where(:walker => params[:id]).order(:id)
    else
      @events = Event.order(:id)
    end
  end

  # Generates KML 2.2 output of all events, or all events for walker id
  # /events/map.xml
  # /events/map/{id}.xml
  # Redirect to Google Maps
  # /events/map
  # /events/map/{id}
  def map
    if request.format.xml?
      @checkpoints = Checkpoint.order("\"checkid\" ASC")
      @checkpoints_count = @checkpoints.count

      if params[:id].present?
        @locationUpdates = Event.where(:walker => params[:id], :eventType => "LocationUpdate").order("\"eventId\" ASC")
        render "map_for_walker"
      else
        @locationUpdates = Event.where(:eventType => "LocationUpdate").order("\"walker\" ASC, \"eventId\" ASC")
        render "map_for_all_walkers"
      end

    else # Google maps redirect and added timestamp for bypassing their cache
      redirect_to "https://maps.google.com/maps?q=" + request.original_url + ".xml?t=" + Time.now.to_i.to_s
    end
  end

  # API methods:

  # Process JSON request for sending events for walker id.
  # Returns JSON with event ids of processed events.
  # /events/create/{id}
  def create 
    saved = []
    jsonHash = request.POST[:_json];
    jsonHash.each do |jsonEvent|
      event = Event.new
      event.walker = params[:id]
      event.eventId = jsonEvent["eventId"]
      event.eventType = jsonEvent["type"]
      event.eventData = jsonEvent["data"]
      event.batteryLevel = jsonEvent["batL"]
      event.batteryState = jsonEvent["batS"]
      event.timestamp = Time.zone.parse(jsonEvent["time"])
      if event.save # if new
        saved << jsonEvent["eventId"]
        after_create(event)
        #create_simulation_events(event)
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
      update_checkpoint(event)
      update_distance(event)

    end

    # Process event with type StartRace. Updates race info in table Race for particular walker.
    def start_race(event)
      if (event.eventType == "StartRace")
        #Create race if not exists
        race_info = Race.new(:walker => event.walker, :raceState => 1,
                             :lastCheckpoint => 0, :distance => 0, :avgSpeed => 0)
        if !race_info.save
          # if exists, just update raceState
          race_info = Race.find_by_walker(event.walker)
          race_info.raceState = 1
          race_info.save
        end
      end
    end

    # Process event with type StopRace. Updates race state field in table Race for particular walker.
    def stop_race(event)
      if (event.eventType == "StopRace")
        race_info = Race.find_by_walker(event.walker)
        race_info.raceState = 2
        race_info.save
      end
    end

    # Process event with type Checkpoint. Updates last checkpoint field in table Race for particular walker.
    def update_checkpoint(event)
      if (event.eventType == "Checkpoint")
        newCheckpoint = event.eventData["kId"]
        raceInfo = Race.find_by_walker(event.walker)
        oldCheckpoint = raceInfo.lastCheckpoint
        if newCheckpoint > oldCheckpoint # prevent backwards scanning
          raceInfo.lastCheckpoint = newCheckpoint
          newCheckpointDB = Checkpoint.find_by_checkid(newCheckpoint)
          raceInfo.distance = newCheckpointDB.meters # update distance by checkpoint
          raceInfo.save
        end
      end
    end

    # Process event with type LocationUpdate. Updates distance field in table Race for particular walker.
    def update_distance(event)
      if (event.eventType == "LocationUpdate")
        if event.eventData['horAcc'] < 200 # inaccurate location updates filter

          raceInfo = Race.find_by_walker(event.walker)
          lastCheckpoint = Checkpoint.find_by_checkid(raceInfo.lastCheckpoint)
          nextCheckpoint = Checkpoint.find_by_checkid(raceInfo.lastCheckpoint+1)
          latitude = event.eventData['latitude']
          longitude = event.eventData['longitude']
          add = false

          # distance from last checkpoint to walker location
          distance_last = gps_distance [lastCheckpoint.latitude,lastCheckpoint.longitude],[latitude,longitude]
          
          if nextCheckpoint # next checkpoint exists (last checkpoint is not actual last)

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
                add = true # will update distance later
              end
            end

          else # next checkpoint does not exist

            # distance from last checkpoint based on gps measuring (estimate of real distance)
            new_distance = distance_last.to_i + lastCheckpoint.meters
            if raceInfo.distance < new_distance
              add = true # will update distance later
            end

          end

          # distance field in table Race update
          if add
            raceInfo.distance = new_distance
            raceInfo.avgSpeed = ((new_distance / (event.timestamp - raceInfo.created_at))*3.6).round(2) # v = s/t converted to km/h and rounded :-)
            raceInfo.save
            event.eventData["distance"] = new_distance
            event.save
            puts "Distance updated to: "+new_distance.to_s # debug print
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

    # Debug only
    # Simulation of next walkers
    def create_simulation_events(event)

      if event.eventType == "LocationUpdate"

        event998 = Event.new(event.attributes.merge(:walker => 609, :batteryLevel => -1, :batteryState => -1))
        event998.eventData["latitude"] += 0.002
        event998.eventData["longitude"] += 0.002
        event998.save

        event999 = Event.new(event.attributes.merge(:walker => 608, :batteryLevel => -1, :batteryState => -1))
        event999.eventData["latitude"] -= 0.004
        event999.eventData["longitude"] -= 0.004
        event999.save

        after_create(event998)
        after_create(event999)

      elsif event.eventType == "StartRace"

        event998 = Event.new(event.attributes.merge(:walker => 609, :batteryLevel => -1, :batteryState => -1))
        event998.save

        event999 = Event.new(event.attributes.merge(:walker => 608, :batteryLevel => -1, :batteryState => -1))
        event999.save
        
        after_create(event998)
        after_create(event999)


      elsif event.eventType == "Checkpoint"

        event998 = Event.new(event.attributes.merge(:walker => 609, :batteryLevel => -1, :batteryState => -1))
        event998.save

        event999 = Event.new(event.attributes.merge(:walker => 608, :batteryLevel => -1, :batteryState => -1))
        event999.save
        
        after_create(event998)
        after_create(event999)

      end

    end
end
