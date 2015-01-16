class MarkOldRaces < ActiveRecord::Migration
  def up
  	Race.find_each do |r|
    	r.dc_id = 22
    	r.save
    end
  end

  def down
  end
end
