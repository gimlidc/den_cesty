class Registration < ActiveRecord::Base

	$shirt_sizes = ["NO", "XS", "S", "M", "L", "XL", "XXL"]

	belongs_to :walker

	validates_inclusion_of :shirt_size, :in => $shirt_sizes
	validate :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :presence => true
	attr_accessible :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size
end
