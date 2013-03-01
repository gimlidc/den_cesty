class CreateDcs < ActiveRecord::Migration
  def change
    create_table :dcs do |t|
      t.string :name_cs
      t.string :name_en
      t.text :description
      t.integer :rules_id
      t.datetime :start_time
      t.integer :shirt_price
      t.integer :own_shirt_price
      t.integer :reg_price
      t.integer :map_bw_price
      t.integer :map_color_price

      t.timestamps
    end
  end
end
