class Race < ActiveRecord::Base

  has_many :checkpoints
  has_many :events
  has_many :scoreboard

  attr_accessible :name_cs, :name_en, :start_time, :finish_time, :visible

end
