class Result < ActiveRecord::Base

	belongs_to :walker
	attr_accessible :walker_id, :dc_id, :distance, :duration

end
