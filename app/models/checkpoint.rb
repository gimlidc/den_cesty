class Checkpoint < ActiveRecord::Base

  belongs_to :race

  validates_uniqueness_of :race_id, :scope => :checkid


  def coordinates
    "#{longitude}, #{latitude}"
  end

end
