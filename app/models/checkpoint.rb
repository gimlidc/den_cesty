class Checkpoint < ActiveRecord::Base

  belongs_to :dc

	validates_uniqueness_of :dc_id, :scope => :checkid

end
