class RemoveUniquenessOfVokativInWalker < ActiveRecord::Migration
  def up
    rename_column :walkers, :vokativ, :username
    remove_index :walkers, :username
    add_index :walkers, :username
    rename_column :walkers, :username, :vokativ
  end

  def down
    rename_column :walkers, :vokativ, :username
    remove_index :walkers, :username
    add_index :walkers, :username, :unique => true
    rename_column :walkers, :username, :vokativ
  end
end
