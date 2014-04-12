class ChangeScarfDefaultValue < ActiveRecord::Migration
  def up
    change_column :registrations, :scarf, :boolean, :default => false
  end

  def down
    change_column :registrations, :scarf, :boolean, :default => true
  end
end
