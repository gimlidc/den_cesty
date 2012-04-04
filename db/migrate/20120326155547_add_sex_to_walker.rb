class AddSexToWalker < ActiveRecord::Migration
  def self.up
    add_column :walkers, :sex, :string
  end

  def self.down
    remove_column :walkers, :sex
  end
end
