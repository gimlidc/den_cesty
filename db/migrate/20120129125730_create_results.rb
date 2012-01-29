class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
			t.integer :walker_id
			t.integer	:dc_id
			t.float		:distance
			t.integer	:duration

      t.timestamps
    end
  end
end
