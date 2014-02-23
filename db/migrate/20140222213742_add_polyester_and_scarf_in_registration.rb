class AddPolyesterAndScarfInRegistration < ActiveRecord::Migration
  def up
    add_column :registrations, :shirt_polyester, :string, :default => 'NO'
    add_column :registrations, :scarf, :boolean, :default => true
  end

  def down
    remove_column :registrations, :scarf
    remove_column :registrations, :shirt_polyester
  end
end
