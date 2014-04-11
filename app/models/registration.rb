class Registration < ActiveRecord::Base
  after_initialize :default_values

	$shirt_sizes = ["NO", "XS", "S", "M", "L", "XL", "XXL"]	

	belongs_to :walker
	belongs_to :dc

	validates_inclusion_of :shirt_size, :in => $shirt_sizes
	validates_inclusion_of :shirt_polyester, :in => $shirt_sizes
	validate :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :goal, :shirt_polyester, :scarf, :presence => true
	validate :phone, :presence => true, :allow_blank => false
	attr_accessible :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :shirt_polyester, :scarf, :goal, :phone, :canceled, :confirmed, :created_at
	validate :phone, :presence => true, :allow_blank => false
	
  private
    def default_values
      self.bw_map ||= false
      self.colour_map ||= false
      self.shirt_size ||= "NO"
      self.shirt_polyester ||= "NO"
      self.scarf ||= false
    end
	
end
