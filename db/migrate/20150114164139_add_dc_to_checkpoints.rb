class AddDcToCheckpoints < ActiveRecord::Migration
  def up
    add_column :checkpoints, :dc_id, :integer, :default => 0
    Checkpoint.find_each do |ch|
    	ch.dc_id = 22
    	ch.save
    end
    remove_index "checkpoints", :column => ["checkid"]
    add_index "checkpoints", ["dc_id", "checkid"], :unique => true
  end

  def down
  	remove_index "checkpoints", :column => ["dc_id", "checkid"]
  	add_index "checkpoints", ["checkid"], :name => "index_checkpoints_on_checkid"
  	remove_column :checkpoints, :dc_id # risky, wipes out dc info in rows
  end
end
