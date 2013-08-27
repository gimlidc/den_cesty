class Registration < ActiveRecord::Base

	$shirt_sizes = ["NO", "OWN", "XS", "S", "M", "L", "XL", "XXL"]
	$reg_price = 30
	$bw_map_price = 10
	$colour_map_price = 50
	$shirt_price = 250
	$own_shirt_price = 125

	belongs_to :walker
	belongs_to :dc

	validates_inclusion_of :shirt_size, :in => $shirt_sizes
	validate :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :goal, :presence => true
	attr_accessible :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :goal, :canceled
end
