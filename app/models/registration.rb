class Registration < ActiveRecord::Base
  after_initialize :default_values

	$shirt_sizes = ["NO", "XS", "S", "M", "L", "XL", "XXL"]	

	belongs_to :walker
	belongs_to :dc

  accepts_nested_attributes_for :walker, :dc

	validates_inclusion_of :shirt_size, :in => $shirt_sizes
	validates_inclusion_of :shirt_polyester, :in => $shirt_sizes
	validates :walker_id, :dc_id, :shirt_size, :goal, :shirt_polyester, :presence => true
  validates_inclusion_of :scarf, :bw_map, :colour_map, in: [true, false]
	validates :phone, :presence => true, :allow_blank => false
	attr_accessible :walker_id, :dc_id, :bw_map, :colour_map, :shirt_size, :shirt_polyester, :scarf, :goal, :phone, :canceled, :confirmed, :created_at
	validates :phone, :presence => true, :allow_blank => false
	
	def has_textile?
	  if self.scarf || self.shirt_size != "NO" || self.shirt_polyester != "NO"
	    return true
	  end
	  return false 
	end

	private
    def default_values
      self.bw_map ||= false
      self.colour_map ||= false
      self.shirt_size ||= "NO"
      self.shirt_polyester ||= "NO"
      self.scarf ||= false
    end
	
end
