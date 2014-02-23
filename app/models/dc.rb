# encoding: utf-8
class Dc < ActiveRecord::Base

  # integration with other models
  has_many :result
  has_many :reports
  has_many :registration
  
  # Definition of accessible attributes
  attr_accessible :name_cs, :name_en, :start_time, :description, :rules_id, :reg_price, :map_bw_price, :map_color_price, :shirt_price, :own_shirt_price, :polyester_shirt_price, :scarf_price, :limit
  
  # Extra validation
  validates :name_cs, :name_en, :start_time, :description, :reg_price, :map_bw_price, :map_color_price, :shirt_price, :own_shirt_price, :polyester_shirt_price, :scarf_price, :presence => true, :allow_blank => false
  validates :name_cs, :name_en, :uniqueness => true
  
  def seasonYear
    month = start_time.month
    day = start_time.day
    
    if month < 3 || (month == 3 && day < 21)
      season = "zima"
    else 
      if month < 6 || (month == 6 && day < 21)
        season = "jaro"
      else
        if month < 9  || (month == 9 && day < 23)
          season = "léto"
        else
          season = "podzim"
        end
      end
    end
    
    "#{season} #{start_time.year}"
  end
  
  def specifyName
    "#{seasonYear} - #{name_cs}"  
  end
  
end
