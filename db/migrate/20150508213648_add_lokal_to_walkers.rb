class AddLokalToWalkers < ActiveRecord::Migration
  def change
    add_column :walkers, :lokal, :string, :default => ''
  end
end
