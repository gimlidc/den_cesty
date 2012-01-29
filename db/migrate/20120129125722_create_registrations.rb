class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
			t.integer :walker_id
			t.integer :dc_id
			t.boolean :colour_map
			t.boolean :bw_map
			t.string	:shirt_size

      t.timestamps
    end
  end
end
