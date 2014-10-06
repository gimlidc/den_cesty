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
        createSimulationEvents(jsonEvent)
		  else
        saved << jsonEvent["eventId"]
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

    def createSimulationEvents(jsonEvent)

      if jsonEvent["type"] == "LocationUpdate"

        
        jsonEvent["data"]["latitude"] += 0.002
        jsonEvent["data"]["longitude"] += 0.002
        event998 = Event.new
        event998.walker = 998
        event998.eventId = jsonEvent["eventId"]
        event998.eventType = jsonEvent["type"]
        event998.eventData = jsonEvent["data"]
        event998.batteryLevel = -1
        event998.batteryState = -1
        event998.timestamp = Time.zone.parse(jsonEvent["time"])
        event998.save

        
        jsonEvent["data"]["latitude"] -= 0.004
        jsonEvent["data"]["longitude"] -= 0.004
        event999 = Event.new
        event999.walker = 999
        event999.eventId = jsonEvent["eventId"]
        event999.eventType = jsonEvent["type"]
        event999.eventData = jsonEvent["data"]
        event999.batteryLevel = -1
        event999.batteryState = -1
        event999.timestamp = Time.zone.parse(jsonEvent["time"])
        event999.save
      end

    end
end
