class ApiController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Process login for mobile app. Return true, walker id, name, surname and username if success.
  # /api/login(.json)
  def login
    email = request.POST[:email]
    password = request.POST[:password]
    
    w = Walker.where(:email => email).first
    if w.nil? # walker with this email not found
      render :json => {:success => false}
    else
      bcrypt = ::BCrypt::Password.new(w.encrypted_password)
      password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)

      if w.encrypted_password == password
        render :json => {:success => true,
                         :id => w.id,
                         :name => w.name,
                         :surname => w.surname,
                         :username => w.username}
      else
        render :json => {:success => false}
      end
    end
  end

  # /api/races(.json)
  def races
    show_time = Time.now - 1.day  # show only future races races that finished max 24 hours ago
    races = Race.where("finish_time > ?", show_time).where(:visible => true).order(:start_time)
    render :json => races
  end

  # /api/race_data/:id(.json)
  def race_data
    race = Race.find(params[:id])

    show_time = Time.now + 1.hours  # allow only one hour before start or later
    if (race.start_time < show_time && race.visible?)
      checkpoints = race.checkpoints.order(:checkid)
      render :json => {:race_info => race, :race_checkpoints => checkpoints}
    else
      head :forbidden
    end
  end

  # Returns informations about other walkers for particular race id and walker id.
  # /api/scoreboard/:id(.json)?walker_id=:walker_id
  def scoreboard
    race_id = params[:id]
    walker_id = params[:walker_id]
    walkers_score = Scoreboard.where(:race_id => race_id, :walker_id => walker_id).first

  	if walkers_score

      numWalkersAhead = Scoreboard.where(:race_id => race_id).count(:conditions => "distance > " + walkers_score.distance.to_s)
      numWalkersBehind = Scoreboard.where(:race_id => race_id).count(:conditions => "distance <= " + walkers_score.distance.to_s + " AND walker_id <> " + walkers_score.walker.id.to_s)
      numWalkersEnded = Scoreboard.where(:race_id => race_id).count(:conditions => "\"raceState\" = 2 AND walker_id <> " + walkers_score.walker.id.to_s)
      walkersAheadDB = Scoreboard.where("race_id = ? AND distance > ?", race_id, walkers_score.distance).order("distance DESC")
      walkersBehindDB = Scoreboard.where("race_id = ? AND distance <= ? AND walker_id <> ?", race_id, walkers_score.distance, walkers_score.walker.id.to_s).order("distance DESC")

      walkersAhead = []
      walkersAheadDB.each do |wa|
        w = Walker.find(wa.walker)
        walkersAhead << {:name => w.nameSurname, :distance => wa.distance, :speed => wa.avgSpeed}
      end

      walkersBehind = []
      walkersBehindDB.each do |wb|
        w = Walker.find(wb.walker)
        walkersBehind << {:name => w.nameSurname, :distance => wb.distance, :speed => wb.avgSpeed}
      end

      render :json => {:distance => walkers_score.distance,
             :speed => walkers_score.avgSpeed,
             :numWalkersAhead => numWalkersAhead,
             :numWalkersBehind => numWalkersBehind,
             :numWalkersEnded => numWalkersEnded,
             :walkersAhead => walkersAhead,
             :walkersBehind => walkersBehind
            }

    else # may happen if first start race event is late than race info request

      numWalkersAhead = Scoreboard.where(:race_id => race_id).count
      numWalkersBehind = 0
      numWalkersEnded = 0
      walkersAheadDB = Scoreboard.where(:race_id => race_id).order("distance DESC")
      walkersBehind = []

      walkersAhead = []
      walkersAheadDB.each do |wa|
        w = Walker.find(wa.walker)
        walkersAhead << {:name => w.nameSurname, :distance => wa.distance, :speed => wa.avgSpeed}
      end

      render :json => {:distance => 0,
             :speed => 0,
             :numWalkersAhead => numWalkersAhead,
             :numWalkersBehind => numWalkersBehind,
             :numWalkersEnded => numWalkersEnded,
             :walkersAhead => walkersAhead,
             :walkersBehind => walkersBehind
            }
    end
  end

  # Process JSON request for sending events for race id and walker id.
  # Returns JSON with event ids of processed events.
  # /api/push_events(.json)
  def push_events
    #in_race = Time.now > race.start_time && Time.now < race.finish_time

    saved = []
    jsonHash = request.POST[:_json];
    jsonHash.each do |jsonEvent|
      event = Event.new
      event.race_id = jsonEvent["raceId"]
      event.walker_id = jsonEvent["walkerId"]
      event.eventId = jsonEvent["eventId"]
      event.eventType = jsonEvent["type"]
      event.eventData = jsonEvent["data"]
      event.batteryLevel = jsonEvent["batL"]
      event.batteryState = jsonEvent["batS"]
      event.timestamp = Time.zone.parse(jsonEvent["time"])
      if event.save # if new
        saved << jsonEvent["eventId"]
        #if in_race
          #after_create(event)
        #end
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
      #update_distance(event)

    end

    # Process event with type StartRace. Updates race info in table Race for particular walker.
    def start_race(event)
      if (event.eventType == "StartRace")
        #Create race if not exists
        race_info = Scoreboard.new(:dc_id => $dc.id, :walker_id => event.walker_id, :raceState => 1,
                             :lastCheckpoint => 0, :distance => 0, :avgSpeed => 0)
        if !race_info.save
          # if exists, just update raceState
          race_info = Scoreboard.where(:dc_id => $dc.id, :walker_id => event.walker_id).first
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
        race_info = Scoreboard.where(:dc_id => $dc.id, :walker_id => event.walker_id).first
        race_info.raceState = 2
        race_info.save
      end
    end

    # Process event with type LocationUpdate. Updates distance field in table Race for particular walker.
    def update_distance(event)
      if (event.eventType == "LocationUpdate")
        if event.eventData['horAcc'] < 200 # inaccurate location updates filter

          raceInfo = Scoreboard.where(:dc_id => $dc.id, :walker_id => event.walker_id).first
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
