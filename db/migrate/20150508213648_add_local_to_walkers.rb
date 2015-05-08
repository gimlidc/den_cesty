class AddLocalToWalkers < ActiveRecord::Migration
  def change
    add_column :walkers, :local, :string, :default => ''
  end
end
