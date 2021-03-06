class RacesController < ApplicationController

  skip_before_filter :check_admin?, :check_logged_in?
  before_filter :check_admin?, :except => [:track]
  before_filter :check_logged_in?, :except => [:track]

  def index
    @races = Race.order('id DESC')
  end

  def new
    @race = Race.new
    @race.start_time = Time.now.change(:min => 0)
    @race.finish_time = @race.start_time + 12.hours
  end

  def create
    # Instantiate a new object using form parameters
    @race = Race.new(params[:race].permit(:name_cs, :name_en, :start_time, :finish_time))
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

  def edit
    @race = Race.find(params[:id])
  end

  def update
    # Find an existing object using form parameters
    @race = Race.find(params[:id])
    # Update the object
    if @race.update_attributes(params[:race].permit(:name_cs, :name_en, :start_time, :finish_time, :visible))
      # If update succeeds, redirect to the index action
      flash[:notice] = "Race updated successfully."
      redirect_to(:action => 'index')
    else
      # If update fails, redisplay the form so user can fix problems
      render('edit')
    end
  end

  def destroy
    race = Race.find(params[:id]).destroy
    flash[:notice] = "Race '#{race.name_cs}' destroyed successfully."
    redirect_to(:action => 'index')
  end

  def track
    @race = Race.find_by_id(params[:race_id])
    @route = Checkpoint.where(:race_id => params[:race_id]).order(:checkid)

    respond_to do |format|
      format.gpx do
        headers['Content-Disposition'] = 'attachment;filename="track.gpx"'
      end
    end
  end
end
