class CreateRaces < ActiveRecord::Migration
  def up
    create_table :races do |t|
      t.string :name_cs, :null => false
      t.string :name_en, :null => false
      t.datetime :start_time, :null => false
      t.datetime :finish_time, :null => false
      t.boolean :visible, :default => false

      t.timestamps
    end
  end

  def down
    drop_table :races
  end
end
