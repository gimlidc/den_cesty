class AddTextilPricesInDc < ActiveRecord::Migration
  def up
    add_column :dcs, :polyester_shirt_price, :integer
    add_column :dcs, :scarf_price, :integer
  end

  def down
    remove_column :dcs, :polyester_shirt_price
    remove_column :dcs, :scarf_price
  end
end
