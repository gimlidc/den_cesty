class Checkpoint < ActiveRecord::Base

	validates_uniqueness_of :dc, :scope => :checkid

end
