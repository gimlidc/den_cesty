class AddConfirmedIntoRegistration < ActiveRecord::Migration
  def up
    add_column :registrations, :confirmed, :boolean, :default => false
  end

  def down
    remove_column :registrations, :confirmed
  end
end
