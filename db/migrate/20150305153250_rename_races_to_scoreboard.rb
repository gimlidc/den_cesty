class RenameRacesToScoreboard < ActiveRecord::Migration
  def up
  	rename_table :races, :scoreboard
  end

  def down
  	rename_table :scoreboard, :races
  end
end
