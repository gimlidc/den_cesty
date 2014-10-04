class EventsController < ApplicationController

  skip_before_filter :check_admin?
  skip_before_filter :check_logged_in?

  layout false

  def index
  	@events = Event.all
  end

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
