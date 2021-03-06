class Scoreboard < ActiveRecord::Base

  self.table_name = "scoreboard"	# Rails >= 3.2 
  #self.set_table_name "scoreboard"	# Rails <= 3.1

  belongs_to :race
  belongs_to :walker

  attr_accessible :race_id, :walker_id, :raceState, :lastCheckpoint, :distance, :avgSpeed

  validates_uniqueness_of :walker_id, :scope => :race_id

end
