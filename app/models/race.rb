class Race < ActiveRecord::Base

  has_many :checkpoints
  has_many :events
  has_many :scoreboard

  attr_accessible :name_cs, :name_en, :start_time, :finish_time, :visible

  def dc_select
    dc_name + " (" + "%.1f" % (length_in_meters/1000) + "km)"
  end

  def dc_name
    name_cs[8..-1]
  end

  def length_in_meters
    latlons = []
    checkpoints.each do |checkpoint|
      latlons << [checkpoint.latitude, checkpoint.longitude]
    end
    calc_distance(latlons)
  end

  private
  def calc_distance(latlons)
    latlons.map! do |latlon|
      deg_to_rad(latlon)
    end
    (0...latlons.length - 1).inject(0) { |dist, i| dist + hubeny(latlons[i], latlons[i + 1]) }
  end

  def deg_to_rad(latlng)
    latlng.map do |deg|
      deg * Math::PI / 180
    end
  end

  def hubeny(latlng_1, latlng_2)
    a = 6378137.000
    b = 6356752.314245

    pow_e = 1 - b ** 2 / a ** 2

    ave = (latlng_1[0] + latlng_2[0]) / 2
    dp = latlng_1[0] - latlng_2[0]
    dr = latlng_1[1] - latlng_2[1]
    sin_ave = Math.sin(ave)
    cos_ave = Math.cos(ave)
    w = Math.sqrt(1 - pow_e * sin_ave ** 2)
    m = a * (1 - pow_e) / w ** 3
    n = a / w

    Math.sqrt((m * dp) ** 2 + (n * cos_ave * dr) ** 2)
  end

end
