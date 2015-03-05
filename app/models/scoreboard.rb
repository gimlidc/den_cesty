class Scoreboard < ActiveRecord::Base

	#self.table_name = "scoreboard"		# Rails >= 3.2 
	self.set_table_name "scoreboard"	# Rails <= 3.1

  belongs_to :dc
  belongs_to :walker

	validates_uniqueness_of :walker_id, :scope => :dc_id

end
