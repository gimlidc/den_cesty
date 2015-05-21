# CRUD controller for Races (for mobile app).
#
# Accessible only for administrators.
# 
# Author::  Lukáš Machalík
# 
class RacesController < ApplicationController

  # Shows list of Races.
  # 
  # Available with: GET /races
  def index
    @races = Race.order('id DESC')
  end

  # Shows form for Race creation.
  # 
  # Available with: GET /races/new
  def new
    @race = Race.new
    @race.start_time = Time.now.change(:min => 0)
    @race.finish_time = @race.start_time + 12.hours
  end

  # Creates new Race based on form data.
  # 
  # Available with: POST /races
  def create
    # Instantiate a new object using form parameters
    @race = Race.new(params[:race]) # TODO: security, whitelisting of parameters needed
    # Save the object
    if @race.save
      # If save succeeds, redirect to the index action
      flash[:notice] = "Race created successfully."
      redirect_to(:action => 'index')
    else
      # If save fails, redisplay the form so user can fix problems
      render('new')
    end
  end

  # Shows form for editing Race with given id.
  # 
  # Available with: GET /races/:id/edit
  def edit
    @race = Race.find(params[:id])
  end

  # Updates Race data based on form data.
  # 
  # Available with: PUT /races/:id
  def update
    # Find an existing object using form parameters
    @race = Race.find(params[:id])
    # Update the object
    if @race.update_attributes(params[:race]) # TODO: security, whitelisting of parameters needed
      # If update succeeds, redirect to the index action
      flash[:notice] = "Race updated successfully."
      redirect_to(:action => 'index')
    else
      # If update fails, redisplay the form so user can fix problems
      render('edit')
    end
  end

  # Deletes Race with given id.
  # 
  # Available with: DELETE /races/:id
  def destroy
    race = Race.find(params[:id]).destroy
    flash[:notice] = "Race '#{race.name_cs}' destroyed successfully."
    redirect_to(:action => 'index')
  end
end
