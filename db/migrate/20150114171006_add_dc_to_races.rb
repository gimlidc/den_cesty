class AddDcToRaces < ActiveRecord::Migration
  def up
    add_column :races, :dc, :integer, :default => 0
    Race.find_each do |r|
    	r.dc = 22
    	r.save
    end
    remove_index "races", :column => ["walker"]
    add_index "races", ["dc", "walker"], :unique => true
  end

  def down
  	remove_index "races", :column => ["dc", "walker"]
  	add_index "races", ["walker"], :name => "index_races_on_walker"
  	remove_column :races, :dc # risky, wipes out dc info in rows
  end
end
