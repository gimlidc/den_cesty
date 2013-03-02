class Dc < ActiveRecord::Base

  # integration with other models
  has_many :result
  has_many :reports
  has_many :registration
  
  # Definition of accessible attributes
  attr_accessible :name_cs, :name_en, :start_time, :description, :rules_id, :reg_price, :map_bw_price, :map_color_price, :shirt_price, :own_shirt_price
  
  # Extra validation
  validates :name_cs, :name_en, :start_time, :description, :reg_price, :map_bw_price, :map_color_price, :shirt_price, :own_shirt_price, :presence => true, :allow_blank => false
  validates :name_cs, :name_en, :uniqueness => true
  
end
