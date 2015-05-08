class Result < ActiveRecord::Base

	belongs_to :walker
	belongs_to :dc
	
	attr_accessible :walker_id, :dc_id, :distance, :duration, :official, :result

  def self.result
    if self.dc_id < 20
      return self.distance
    else
      return self.official
    end
  end

end
