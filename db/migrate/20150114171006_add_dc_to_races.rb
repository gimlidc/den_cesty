class AddDcToRaces < ActiveRecord::Migration
  def up
    add_column :races, :dc_id, :integer, :default => 0
    Race.find_each do |r|
    	r.dc_id = 22
    	r.save
    end
    remove_index "races", :column => ["walker"]
    rename_column :races, :walker, :walker_id
    add_index "races", ["dc_id", "walker_id"], :unique => true
  end

  def down
  	remove_index "races", :column => ["dc_id", "walker_id"]
  	rename_column :races, :walker_id, :walker
  	add_index "races", ["walker"], :name => "index_races_on_walker"
  	remove_column :races, :dc_id # risky, wipes out dc info in rows
  end
end
