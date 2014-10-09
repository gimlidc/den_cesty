class EventsController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Web methods:

  def index
  	@events = Event.order(:id)
  end

  def map
    if request.format.xml?
      if params[:id].present?
        @locationUpdates = Event.where(:walker => params[:id], :eventType => "LocationUpdate").order("\"eventId\" ASC")
        render "map_for_walker"
      else
        @locationUpdates = Event.where(:eventType => "LocationUpdate").order("\"walker\" ASC, \"eventId\" ASC")
        render "map_for_all_walkers"
      end
    else
      redirect_to "https://maps.google.com/maps?q=" + request.original_url + ".xml?t=" + Time.now.to_i.to_s
    end
  end

  # API methods:

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
      if event.save
        saved << jsonEvent["eventId"]
        after_create(event)
        create_simulation_events(event)
      else
        saved << jsonEvent["eventId"]
        puts "Not Saved!"
        puts jsonEvent
      end
    end
    render :json => {:savedEventIds => saved}
  end

  private

    def after_create(event)
      
      start_race(event)
      stop_race(event)
      update_checkpoint(event)
      update_distance(event)

    end

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

    def stop_race(event)
      if (event.eventType == "StopRace")
        race_info = Race.find_by_walker(event.walker)
        race_info.raceState = 2
        race_info.save
      end
    end

    def update_checkpoint(event)
      if (event.eventType == "Checkpoint")
        newCheckpoint = event.eventData["kId"]
        raceInfo = Race.find_by_walker(event.walker)
        oldCheckpoint = raceInfo.lastCheckpoint
        if newCheckpoint > oldCheckpoint
          raceInfo.lastCheckpoint = newCheckpoint
          newCheckpointDB = Checkpoint.find_by_checkid(newCheckpoint)
          raceInfo.distance = newCheckpointDB.meters
          raceInfo.save
        end
      end
    end

    def update_distance(event)
      if (event.eventType == "LocationUpdate")
        if event.eventData['horAcc'] < 200
          raceInfo = Race.find_by_walker(event.walker)
          lastCheckpoint = Checkpoint.find_by_checkid(raceInfo.lastCheckpoint)
          nextCheckpoint = Checkpoint.find_by_checkid(raceInfo.lastCheckpoint+1)
          latitude = event.eventData['latitude']
          longitude = event.eventData['longitude']
          add = false

          distance_last = gps_distance [lastCheckpoint.latitude,lastCheckpoint.longitude],[latitude,longitude]
          
          if nextCheckpoint # neposledni checkpoint, jsem mezi checkpointy

            distance_next = gps_distance [latitude, longitude],[nextCheckpoint.latitude,nextCheckpoint.longitude]
            distance_between = gps_distance [lastCheckpoint.latitude,lastCheckpoint.longitude],[nextCheckpoint.latitude,nextCheckpoint.longitude] # TODO optimize

            if distance_next < distance_between && distance_last < distance_between # vylouceni updatu, ktere nejsou mimo checkpointy
              progress_between = distance_last / (distance_last+distance_next)
              real_distance_between = nextCheckpoint.meters - lastCheckpoint.meters
              new_distance = (progress_between * real_distance_between).to_i + lastCheckpoint.meters

              if raceInfo.distance < new_distance
                add = true
              end
            end

          else # jsem za poslednim checkpointem

            new_distance = distance_last.to_i + lastCheckpoint.meters
            if raceInfo.distance < new_distance
              add = true
            end

          end

          if add
            raceInfo.distance = new_distance
            raceInfo.avgSpeed = ((new_distance / (event.timestamp - raceInfo.created_at))*3.6).round(2)
            raceInfo.save
            event.eventData["distance"] = new_distance
            event.save
            puts "Distance updated to: "+new_distance.to_s
          end
        end
      end
    end

    # http://stackoverflow.com/a/12969617
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
