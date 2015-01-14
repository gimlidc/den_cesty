class Race < ActiveRecord::Base

	validates_uniqueness_of :walker, :scope => :dc

end
