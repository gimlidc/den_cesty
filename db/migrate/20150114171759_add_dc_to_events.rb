class AddDcToEvents < ActiveRecord::Migration
  def up
    add_column :events, :dc_id, :integer, :default => 0
    remove_index :events, :column => ["walker", "eventId"]
    rename_column :events, :walker, :walker_id
    add_index :events, ["dc_id", "walker_id", "eventId"], :unique => true
  end

  def down
  	remove_index "events", :column => ["dc_id", "walker_id", "eventId"]
  	rename_column :events, :walker_id, :walker
  	add_index "events", ["walker", "eventId"], :name => "index_events_on_walker_and_eventId"
  	remove_column :events, :dc_id # warning, this wipes out dc idexes
  end
end
