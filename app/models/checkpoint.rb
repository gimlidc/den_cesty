class Checkpoint < ActiveRecord::Base

	validates_uniqueness_of :checkid, :scope => :dc

end
