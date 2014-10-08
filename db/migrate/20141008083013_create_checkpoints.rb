class CreateCheckpoints < ActiveRecord::Migration
  def change
    create_table :checkpoints do |t|
      t.integer :checkid 
      t.integer :meters
      t.float :latitude
      t.float :longitude
    end

    add_index "checkpoints", ["checkid"], :unique => true
  end
end
