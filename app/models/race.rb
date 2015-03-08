class Race < ActiveRecord::Base

  has_many :checkpoints
  has_many :events
  has_many :scoreboard

end
