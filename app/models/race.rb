class Race < ActiveRecord::Base

  belongs_to :dc
  belongs_to :walker

	validates_uniqueness_of :walker_id, :scope => :dc_id

end
