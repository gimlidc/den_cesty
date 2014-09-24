class EventsController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  def new
  	@event = Event.new # because of default values from database
  	@event.walker = 1
  	@event.eventId = 0
  	@event.eventType = "LocationUpdateTest"
  	@event.eventData = '{"key2"=>"value2", "key1"=>"value1"}'
  end

  def index
  	@events = Event.all
  end

  def create 
  	saved = []
  	jsonData = request.POST[:jsondata]
  	jsonHash = JSON.parse(jsonData)
    jsonHash.each do |jsonEvent|
    	event = Event.new
    	event.walker = params[:id]
    	event.eventId = jsonEvent["eventId"]
    	event.eventType = jsonEvent["type"]
    	event.eventData = jsonEvent["data"]
    	if event.save
		  saved << jsonEvent["eventId"]
		else
		  puts "Not Saved!"
		  puts jsonEvent
		end
    end
    render :json => {:savedEventIds => saved}
  end

  private

  	def event_params
  	  params.require(:event).permit(:walker, :eventId, :eventType, :eventData)
  	end
end
