class Checkpoint < ActiveRecord::Base

	validates_uniqueness_of :checkid

end
