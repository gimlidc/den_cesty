class EventsController < ApplicationController

  skip_before_filter :check_admin?

  layout false

  # Web methods:

  # Shows all events, or all events for race id
  # May be memory inefficient, for debuging purposes only
  # /events/dump/:id
  # /events/dump/:id?walker_id=:walker_id
  def dump
    if params[:id].present?

      if params[:walker_id].present?
        @events = Event.where(:race_id => params[:id], :walker_id => params[:walker_id]).order(:id)
      else
        @events = Event.where(:race_id => params[:id]).order(:id)
      end

    else
      # @events = Event.order(:id)
      redirect_to :controller => "pages", :action => "unauthorized"
    end
  end

end
