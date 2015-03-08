class RenameRacesToScoreboard < ActiveRecord::Migration
  def up
  	remove_index "races", :column => ["dc_id", "walker_id"]
  	rename_table :races, :scoreboard
  	add_index "scoreboard", ["dc_id", "walker_id"], :unique => true # , :name => "index_scoreboard_on_dc_id_and_walker_id"
  end

  def down
  	remove_index "scoreboard", :column => ["dc_id", "walker_id"]
  	rename_table :scoreboard, :races
  	add_index "races", ["dc_id", "walker_id"], :unique => true #, :name => "index_races_on_dc_id_and_walker_id"
  end
end
