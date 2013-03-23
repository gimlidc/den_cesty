class AddVirtualToWalker < ActiveRecord::Migration
  def up
    add_column :walkers, :virtual, :boolean, :default => false
  end
 
  def down
    remove_column :walkers, :virtual
  end
end
