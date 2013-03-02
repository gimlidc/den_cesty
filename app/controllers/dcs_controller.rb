class DcsController < ApplicationController    
  
  # GET /dcs
  # GET /dcs.json
  def index
    @dcs = Dc.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dcs }
    end
  end

  # GET /dcs/1
  # GET /dcs/1.json
  def show
    @dc = Dc.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dc }
    end
  end

  # GET /dcs/new
  # GET /dcs/new.json
  def new
    @dc = Dc.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dc }
    end
  end

  # GET /dcs/1/edit
  def edit
    @dc = Dc.find(params[:id])
  end

  # POST /dcs
  # POST /dcs.json
  def create
    @dc = Dc.new(params[:dc])

    respond_to do |format|
      if @dc.save
        format.html { redirect_to @dc, notice: 'Dc was successfully created.' }
        format.json { render json: @dc, status: :created, location: @dc }
      else
        format.html { render action: "new" }
        format.json { render json: @dc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dcs/1
  # PUT /dcs/1.json
  def update
    @dc = Dc.find(params[:id])

    respond_to do |format|
      if @dc.update_attributes(params[:dc])
        format.html { redirect_to @dc, notice: 'Dc was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @dc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dcs/1
  # DELETE /dcs/1.json
  def destroy
    @dc = Dc.find(params[:id])
    @dc.destroy

    respond_to do |format|
      format.html { redirect_to dcs_url }
      format.json { head :ok }
    end
  end
  
end
