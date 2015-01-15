class AddDcToEvents < ActiveRecord::Migration
  def up
    add_column :events, :dc, :integer, :default => 0
    Event.find_each do |e|
    	e.dc = 22
    	e.save
    end
    remove_index "events", :column => ["walker", "eventId"]
    add_index "events", ["dc", "walker", "eventId"], :unique => true
  end

  def down
  	remove_index "events", :column => ["dc", "walker", "eventId"]
  	add_index "events", ["walker", "eventId"], :name => "index_events_on_walker_and_eventId"
  	remove_column :events, :dc
  end
end
