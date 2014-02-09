class Registration < ActiveRecord::Base

	$shirt_sizes = ["NO", "XS", "S", "M", "L", "XL", "XXL"]	

	belongs_to :walker
	belongs_to :dc

	validates_inclusion_of :shirt_size, :in => $shirt_sizes
	validate :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :goal, :presence => true
	validate :phone, :presence => true, :allow_blank => false
	attr_accessible :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :goal, :phone, :canceled, :confirmed
	validate :phone, :presence => true, :allow_blank => false
end
