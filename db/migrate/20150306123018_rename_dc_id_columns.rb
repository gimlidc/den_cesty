class RenameDcIdColumns < ActiveRecord::Migration
  def up
  	# Rename column dc_id to race_id on table Checkpoints
  	remove_index "checkpoints", :column => ["dc_id", "checkid"]
  	rename_column :checkpoints, :dc_id, :race_id
  	add_index "checkpoints", ["race_id", "checkid"], :unique => true

  	# Rename column dc_id to race_id on table Scoreboard
  	remove_index "scoreboard", :column => ["dc_id", "walker_id"]
  	rename_column :scoreboard, :dc_id, :race_id
  	add_index "scoreboard", ["race_id", "walker_id"], :unique => true

  	# Rename column dc_id to race_id on table Events
  	remove_index "events", :column => ["dc_id", "walker_id", "eventId"]
  	rename_column :events, :dc_id, :race_id
  	add_index "events", ["race_id", "walker_id", "eventId"]
  end

  def down
  	remove_index "checkpoints", :column => ["race_id", "checkid"]
  	rename_column :checkpoints, :race_id, :dc_id
  	add_index "checkpoints", ["dc_id", "checkid"], :unique => true

  	remove_index "scoreboard", :column => ["race_id", "walker_id"]
  	rename_column :scoreboard, :race_id, :dc_id
  	add_index "scoreboard", ["dc_id", "walker_id"], :unique => true

  	remove_index "events", :column => ["race_id", "walker_id", "eventId"]
		rename_column :events, :race_id, :dc_id
  	add_index "events", ["dc_id", "walker_id", "eventId"]
  end
end
