class AddLengthToRaces < ActiveRecord::Migration
  def change
    add_column :races, :length, :float
  end
end
