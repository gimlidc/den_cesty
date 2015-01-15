class AddLocationToRaces < ActiveRecord::Migration
  def change
    add_column :races, :latitude, :float, :default => 0
    add_column :races, :longitude, :float, :default => 0
  end
end
