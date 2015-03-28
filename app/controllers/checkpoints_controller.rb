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

  # GET /races/:race_id/checkpoints/import
  def import
  end

  def upload
    file_name = params[:file]
    file = File.open(file_name.path)
    doc = Nokogiri::XML(file) do |config|
      config.strict.nonet
    end
    file.close

    filter = params[:distance_filter].to_i
    filter_enabled = !params[:enable_distance_filtering].nil?
    
    if !filter_enabled then
      filter = 0
    end

    counter = process_gpx_document(doc, filter)

    flash[:notice] = "#{counter} checkpoints created successfully."
    redirect_to(race_checkpoints_url)
  end

  def map
    @race = Race.find(params[:race_id])
    @checkpoints = @race.checkpoints.select([:checkid, :latitude, :longitude, :meters])
  end

  private

    def process_gpx_document(doc, filter)
      points = doc.xpath('//xmlns:trkpt')

      inserts = []

      counter = 0
      lastLat = 0.0
      lastLon = 0.0
      sum = 0.0
      lastSum = filter

      points.each do |point|
        lat = point.attribute('lat').value.to_f
        lon = point.attribute('lon').value.to_f

        if lastLat.zero? then
          lastLat = lat
          lastLon = lon
        else
          distance = gps_distance([lastLat, lastLon],[lat,lon])
          sum = sum + distance
          lastSum = lastSum + distance.to_i
          lastLat = lat
          lastLon = lon
        end

        if lastSum >= filter then
          # Add new checkpoint
          inserts.push "(#{counter}, #{lat}, #{lon}, #{sum.to_i}, #{params[:race_id].to_i})"

          lastSum = 0;
          counter += 1
        end
      end

      if !counter.zero? && !lastSum.zero? then
        # Add last checkpoint (if was previously filtered)
        inserts.push "(#{counter}, #{lastLat}, #{lastLon}, #{sum.to_i}, #{params[:race_id].to_i})"
      end

      mass_insert(inserts)

      return counter
    end

    # https://www.coffeepowered.net/2009/01/23/mass-inserting-data-in-rails-without-killing-your-performance/
    def mass_insert(inserts)
        #puts inserts.join(", \n")
        sql = "INSERT INTO \"checkpoints\" (\"checkid\", \"latitude\", \"longitude\", \"meters\", \"race_id\") VALUES #{inserts.join(", ")}"
        ActiveRecord::Base.connection.execute sql
    end

    # GPS distance calculation using Haversine formula
    # From: http://stackoverflow.com/a/12969617
    def gps_distance(a, b)
      rad_per_deg = Math::PI/180  # PI / 180
      rkm = 6371                  # Earth radius in kilometers
      rm = rkm * 1000             # Radius in meters

      dlon_rad = (b[1]-a[1]) * rad_per_deg  # Delta, converted to rad
      dlat_rad = (b[0]-a[0]) * rad_per_deg

      lat1_rad, lon1_rad = a.map! {|i| i * rad_per_deg }
      lat2_rad, lon2_rad = b.map! {|i| i * rad_per_deg }

      a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

      rm * c # Delta in meters
    end

end
