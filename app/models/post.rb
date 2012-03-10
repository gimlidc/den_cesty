class Post < ActiveRecord::Base

	belongs_to :walker
	attr_accessible :note
	
end
