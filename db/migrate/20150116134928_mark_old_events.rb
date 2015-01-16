class MarkOldEvents < ActiveRecord::Migration
  def up
  	Event.find_each do |e|
    	e.dc_id = 22
    	e.save
    end
  end

  def down
  end
end
