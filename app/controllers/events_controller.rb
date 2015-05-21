# Controller for Events debug print.
#
# Accessible only for logged users.
# 
# Author::  Lukáš Machalík
# 
class EventsController < ApplicationController

  skip_before_filter :check_admin?

  layout false

  # Shows all events for race id, optionaly for walker id.
  #
  # Warning: May be memory expensive. Use it for debuging purposes only.
  # 
  # Available with: GET /events/dump/:id
  # 
  # Available with: GET /events/dump/:id?walker_id=:walker_id
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
