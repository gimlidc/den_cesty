class RaceController < ApplicationController
  
  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

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
