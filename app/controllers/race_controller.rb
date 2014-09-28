class RaceController < ApplicationController
  
  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  def login
    email = request.POST[:email]
    password = request.POST[:password]

    w = Walker.where(:email => email).first
    if w.nil? # uživatel z emailem nenalezen
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

  def index
  	# just for testing
  	render :json => {:numWalkersAhead => 20,
  					 :numWalkersBehind => 42,
  					 :numWalkersEnded => 3,
  					 :walkersAhead => [{:name => "Pepa jednička", :distance => 400, :speed => 7},
  					 				   {:name => "Franta dvojka", :distance => 60, :speed => 6}
  					 				  ],
  					 :walkersBehind => [{:name => "Jirka čtverka", :distance => 200, :speed => 5},
  					 				    {:name => "Petr pětka", :distance => 250, :speed => 4}
  					 				   ]
  					}
  end

end
