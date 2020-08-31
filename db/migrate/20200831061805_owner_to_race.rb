class OwnerToRace < ActiveRecord::Migration
  def change
    add_column :races, :owner, :integer, default: 0
  end
end
