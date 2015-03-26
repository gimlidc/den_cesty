class AddVokativToWalker < ActiveRecord::Migration
  def change
    rename_column :walkers, :username, :vokativ
  end
end
