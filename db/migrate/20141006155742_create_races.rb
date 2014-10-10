class CreateRaces < ActiveRecord::Migration
  def change
    create_table :races do |t|
      t.integer :walker
      t.integer :lastCheckpoint
      t.integer :raceState
      t.integer :distance
      t.float :avgSpeed

      t.timestamps
    end

    add_index "races", ["walker"], :unique => true
  end
end
