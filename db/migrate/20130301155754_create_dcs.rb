class CreateDcs < ActiveRecord::Migration
  def change
    create_table :dcs do |t|
      t.string :name_cs
      t.string :name_en
      t.datetime :start_time
      t.text :description
      t.integer :rules_id
      t.integer :reg_price
      t.integer :bw_map_price
      t.integer :colour_map_price 
      t.integer :shirt_price
      t.integer :own_shirt_price

      t.timestamps
    end
  end
end
