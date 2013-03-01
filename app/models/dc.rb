class Dc < ActiveRecord::Base

  # integration with other models
  has_many :result
  has_many :reports
  has_many :registration
  
  # Definition of accessible attributes
  attr_accessible :name_cs, :name_en, :start_time, :description, :rules_id, :reg_price, :bw_map_price, :colour_map_price, :shirt_price, :own_shirt_price
  
  # Extra validation
  validates :name_cs, :name_en, :start_time, :description, :reg_price, :bw_map_price, :colour_map_price, :shirt_price, :own_shirt_price, :presence => true
  validates :name_cs, :name_en, :allow_blank => false
  validates :name_cs, :name_en, :uniqueness => true
  
end
