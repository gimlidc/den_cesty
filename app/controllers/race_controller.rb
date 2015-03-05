class RaceController < ApplicationController
  
  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  # Web methods:

  # Shows race progress and walkers order based on elapsed distance.
  # /race
  def index
    @races = Race.where(:dc_id => $dc.id).order("distance DESC")
  end

  # API methods:

  # Process login for mobile app. Return true, walker id, name, surname and username if success.
  # /race/login
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

  # Returns informations about other walkers for particular walker id.
  # /race/info/{id}
  def info
    walker = Race.where(:dc_id => $dc.id, :walker_id => params[:id]).first

  	if walker

      numWalkersAhead = Race.where(:dc_id => $dc.id).count(:conditions => "distance > " + walker.distance.to_s)
      numWalkersBehind = Race.where(:dc_id => $dc.id).count(:conditions => "distance <= " + walker.distance.to_s + " AND walker_id <> " + walker.walker.id.to_s)
      numWalkersEnded = Race.where(:dc_id => $dc.id).count(:conditions => "\"raceState\" = 2 AND walker_id <> " + walker.walker.id.to_s)
      walkersAheadDB = Race.where("dc_id = ? AND distance > ?", $dc.id, walker.distance).order("distance DESC")
      walkersBehindDB = Race.where("dc_id = ? AND distance <= ? AND walker_id <> ?", $dc.id, walker.distance, walker.walker.id.to_s).order("distance DESC")

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

      render :json => {:distance => walker.distance,
             :speed => walker.avgSpeed,
             :numWalkersAhead => numWalkersAhead,
             :numWalkersBehind => numWalkersBehind,
             :numWalkersEnded => numWalkersEnded,
             :walkersAhead => walkersAhead,
             :walkersBehind => walkersBehind
            }

    else # may happen if first start race event is late than race info request

      numWalkersAhead = Race.where(:dc_id => $dc.id).count
      numWalkersBehind = 0
      numWalkersEnded = 0
      walkersAheadDB = Race.where(:dc_id => $dc.id).order("distance DESC")
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
