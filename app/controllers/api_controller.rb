class ApiController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Process login for mobile app. Return true, walker id, name, surname and vokativ if success.
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
                         :vokativ => w.vokativ}
      else
        render :json => {:success => false}
      end
    end
  end

  # /api/races(.json)
  def races
    races = Race.select("name_cs, name_en, start_time, finish_time, visible, created_at, updated_at, length").where(:visible => true, :owner => [0, current_walker[:id]]).order('finish_time DESC')
    render :json => races
  end

  # /api/race_data/:id(.json)?walker_id=:walker_id
  def race_data
    race = Race.select("name_cs, name_en, start_time, finish_time, visible, created_at, updated_at, length").find(params[:id])

    show_time = Time.now + 1.hours  # allow only one hour before start or later
    if (race.start_time < show_time && race.visible?)
      checkpoints = race.checkpoints.order(:checkid)
      walkers_score = Scoreboard.where(:race_id => race.id, :walker_id => params[:walker_id]).first
      if !walkers_score.present?
        walker = Walker.find(params[:walker_id])
        walkers_score = Scoreboard.new(:race => race, :walker => walker, :raceState => 0, :lastCheckpoint => 0, :distance => 0, :avgSpeed => 0.0)
      end
      render :json => {:race => race, :scoreboard => walkers_score, :checkpoints => checkpoints}
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
        walkersAhead << {:name => w.nameSurname,
                         :distance => wa.distance,
                         :speed => wa.avgSpeed,
                         :raceState => wa.raceState,
                         :latitude => wa.latitude,
                         :longitude => wa.longitude,
                         :updated_at => wa.updated_at}
      end

      walkersBehind = []
      walkersBehindDB.each do |wb|
        w = Walker.find(wb.walker)
        walkersBehind << {:name => w.nameSurname,
                         :distance => wb.distance,
                         :speed => wb.avgSpeed,
                         :raceState => wb.raceState,
                         :latitude => wb.latitude,
                         :longitude => wb.longitude,
                         :updated_at => wb.updated_at}
      end

      render :json => {:distance => walkers_score.distance,
             :speed => walkers_score.avgSpeed,
             :raceState => walkers_score.raceState,
             :latitude => walkers_score.latitude,
             :longitude => walkers_score.longitude,
             :updated_at => walkers_score.updated_at,
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
        walkersAhead << {:name => w.nameSurname,
                         :distance => wa.distance,
                         :speed => wa.avgSpeed,
                         :raceState => wa.raceState,
                         :latitude => wa.latitude,
                         :longitude => wa.longitude,
                         :updated_at => wa.updated_at}
      end

      render :json => {:distance => 0,
             :speed => 0,
             :raceState => 0,
             :latitude => 0,
             :longitude => 0,
             # does not contain updated_at
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
        if event.race_id != 0 # if not unknown race_id
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
      
      if (event.eventType == "StartRace")
        start_race(event)
      elsif (event.eventType == "StopRace")
        stop_race(event)
      elsif (event.eventType == "LocationUpdate")
        update_distance(event)
      end

    end

    # Process event with type StartRace. Updates scoreboard for particular walker.
    def start_race(event)
      #Create scoreboard entry if not exists
      score = Scoreboard.new(:race_id => event.race_id,
                                 :walker_id => event.walker_id,
                                 :raceState => 1,
                                 :lastCheckpoint => 0,
                                 :distance => 0,
                                 :avgSpeed => 0.0)
      if !score.save
        # if exists, just update raceState
        score = Scoreboard.where(:race_id => event.race_id, :walker_id => event.walker_id).first
        score.raceState = 1
        score.save
      else
        # if new, set location to Race start location (checkpoint 0)
        start = Checkpoint.where(:race_id => event.race_id, :checkid => 0).first
        score.latitude = start.latitude
        score.longitude = start.longitude
        score.save
      end
    end

    # Process event with type StopRace. Updates race state field of scoreboard for particular walker.
    def stop_race(event)
      score = Scoreboard.where(:race_id => event.race_id, :walker_id => event.walker_id).first
      score.raceState = 2
      score.save
    end

    # Process event with type LocationUpdate. Updates fields of scoreboard for particular walker.
    def update_distance(event)
      score = Scoreboard.where(:race_id => event.race_id, :walker_id => event.walker_id).first
      new_distance = event.eventData['distance']

      if new_distance > score.distance # is walker farther away than before
        score.distance = new_distance
        score.avgSpeed = event.eventData['avgSpeed']
        score.lastCheckpoint = event.eventData['lastCheckpoint']
        score.latitude = event.eventData['latitude']
        score.longitude = event.eventData['longitude']
        score.save
        puts "Distance updated to: "+new_distance.to_s # debug print
      end
    end
end
