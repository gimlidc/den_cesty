class OutgrowthsController < ApplicationController

  skip_before_filter :check_admin?

  def race_record
    events = Event.where(:race_id => params[:race_id], :walker_id => params[:walker_id]).order(:id)
    @walker = Walker.find_by_id(params[:walker_id])
    @trks = []
    events.each do |event|
      data = JSON.parse event.eventData.to_s.gsub('=>', ':')
      if (data["latitude"].nil?)
        next
      end
      trk = {}
      trk[:latitude] = data["latitude"]
      trk[:longitude] = data["longitude"]
      trk[:time] = data["timestamp"]
      @trks << trk
    end

    @race = Race.find_by_id(params[:race_id])

    @route = Checkpoint.where(:race_id => params[:race_id]).order(:checkid)

    respond_to do |format|
      format.gpx do
        headers['Content-Disposition'] = 'attachment;filename="rece_record.gpx"'
      end
    end
  end

  def show
    @stats = statistics(current_walker)
    @diploms = Dc.select('id, diplom_path').order('id DESC')
    @max = max
    raceIds = Event.uniq.select(:race_id).where(:walker_id => current_walker)
    dcs = Dc.select('id', 'race_id').where(:race_id => raceIds)
    @gpx = Array.new($dc.id)
    dcs.each do |dc|
      @gpx[dc.id] = dc.race_id
    end
  end
  
  def compare
    @stats = statistics("#{params[:id]}")
    @max = max
  end

  private

  def statistics(walker_id)
    @stats = Hash.new
    results = Result.joins(:dc).where(:walker_id => walker_id).select('dcs.name_cs, dcs.start_time, walker_id, distance, official, dc_id').order('dc_id DESC')
    @stats[:results] = results
    @stats[:walker] = Walker.find(walker_id)
    @stats[:top5] = top(walker_id, 5)
    @stats[:top10] = top(walker_id, 10)
    @stats[:avg] = average(results)
    @stats[:sum] = sum(results)
    return @stats
  end

  def top(walker_id, n)
    results = Result.where(:walker_id => walker_id).select('distance').order('distance DESC')
    if (results.length > n+1)
      topData = results.first(n+1).last(n)
      @top = 0
      topData.each do |res|
        @top = @top + res.distance
      end
      return @top / n
    else
      return nil
    end
  end

  def sum(results)
    results.sum(:distance)
  end

  def average(results)
    results.average(:distance)
  end

  def max
    Result.group(:dc_id).order(:dc_id).maximum(:distance)
  end

end
