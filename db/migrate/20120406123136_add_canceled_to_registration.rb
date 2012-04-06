class AddCanceledToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :canceled, :boolean, :default => false
  end

  def self.down
    remove_column :registrations, :canceled
  end
end
