class CheckpointsController < ApplicationController
  
  # GET /races/:race_id/checkpoints
  def index
    @race = Race.find(params[:race_id])
    @checkpoints = @race.checkpoints
  end

  # GET /races/:race_id/checkpoints/new
  def new
    race = Race.find(params[:race_id])
    @checkpoint = race.checkpoints.build
    @checkpoint.race = race
    @checkpoint.checkid = race.checkpoints.count
  end

  # POST /races/:race_id/checkpoints
  def create
    race = Race.find(params[:race_id])

    # Instantiate a new object using form parameters
    @checkpoint = race.checkpoints.create(params[:checkpoint]) # TODO: security, whitelisting of parameters needed
    # Save the object
    if @checkpoint.save
      # If save succeeds, redirect to the index action
      flash[:notice] = "Checkpoint created successfully."
      redirect_to(race_checkpoints_url)
    else
      # If save fails, redisplay the form so user can fix problems
      render('new')
    end
  end

  # GET /races/:race_id/checkpoints/:id/edit
  def edit
    race = Race.find(params[:race_id])
    @checkpoint = race.checkpoints.find(params[:id])
  end

  # PUT /races/:race_id/checkpoints/:id
  def update
    race = Race.find(params[:race_id])

    # Find an existing object using form parameters
    @checkpoint = race.checkpoints.find(params[:id])
    # Update the object
    if @checkpoint.update_attributes(params[:checkpoint]) # TODO: security, whitelisting of parameters needed
      # If update succeeds, redirect to the index action
      flash[:notice] = "Race updated successfully."
      redirect_to(race_checkpoints_url)
    else
      # If update fails, redisplay the form so user can fix problems
      render('edit')
    end
  end

  # DELETE /races/:race_id/checkpoints/:id
  def destroy
    race = Race.find(params[:race_id])

    @checkpoint = race.checkpoints.find(params[:id])
    @checkpoint.destroy

    flash[:notice] = "Checkpoint '#{@checkpoint.checkid}' destroyed successfully."
    redirect_to(race_checkpoints_url)
  end

  def upload
  end

  def map
  end

end
