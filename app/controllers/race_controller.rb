class RaceController < ApplicationController
  
  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Web methods:

  # Shows race progress and walkers order based on elapsed distance.
  # /race
  def index
    @race = Race.order("\"races\".\"distance\" DESC")
  end


  # API methods:

  # Process login for mobile app. Return true, walker id, name, surname and username if success.
  # /race/login
  def login
    email = request.POST[:email]
    password = request.POST[:password]

    w = Walker.where(:email => email).first
    if w.nil? # uživatel s emailem nenalezen
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

  # Returns informations about other walkers for particular walker id.
  # /race/info/{id}
  def info
    walker = Race.find_by_walker(params[:id])

  	if walker

      numWalkersAhead = Race.count(:conditions => "\"races\".\"distance\" > "+walker.distance.to_s)
      numWalkersBehind = Race.count(:conditions => "\"races\".\"distance\" <= "+walker.distance.to_s+" AND \"races\".\"walker\" <> "+walker.walker.to_s)
      numWalkersEnded = Race.count(:conditions => "\"races\".\"raceState\" = 2 AND \"races\".\"walker\" <> "+walker.walker.to_s)
      walkersAheadDB = Race.where("\"races\".\"distance\" > ?", walker.distance).order("\"races\".\"distance\" DESC")
      walkersBehindDB = Race.where("\"races\".\"distance\" <= ? AND \"races\".\"walker\" <> ?", walker.distance, walker.walker).order("\"races\".\"distance\" DESC")

      walkersAhead = []
      walkersAheadDB.each do |wa|
        w = Walker.find(wa.walker)
        walkersAhead << {:name => w.nameSurname, :distance => wa.distance-walker.distance, :speed => wa.avgSpeed}
      end

      walkersBehind = []
      walkersBehindDB.each do |wb|
        w = Walker.find(wb.walker)
        walkersBehind << {:name => w.nameSurname, :distance => walker.distance-wb.distance, :speed => wb.avgSpeed}
      end

      render :json => {:distance => walker.distance,
             :speed => walker.avgSpeed,
             :numWalkersAhead => numWalkersAhead,
             :numWalkersBehind => numWalkersBehind,
             :numWalkersEnded => numWalkersEnded,
             :walkersAhead => walkersAhead,
             :walkersBehind => walkersBehind
            }

    else # may happen if first start race event is late than race info request

      numWalkersAhead = Race.count
      numWalkersBehind = 0
      numWalkersEnded = 0
      walkersAheadDB = Race.order("\"races\".\"distance\" DESC")
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

end
