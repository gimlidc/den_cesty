class Result < ActiveRecord::Base

	belongs_to :walker
	belongs_to :dc
	
	attr_accessible :walker_id, :dc_id, :distance, :duration, :official

end
