class AddDcToCheckpoints < ActiveRecord::Migration
  def up
    add_column :checkpoints, :dc, :integer, :default => 0
    Checkpoint.find_each do |ch|
    	ch.dc = 22
    	ch.save
    end
    remove_index "checkpoints", :column => ["checkid"]
    add_index "checkpoints", ["dc", "checkid"], :unique => true
  end

  def down
  	remove_index "checkpoints", :column => ["dc", "checkid"]
  	add_index "checkpoints", ["checkid"], :name => "index_checkpoints_on_checkid"
  	remove_column :checkpoints, :dc # risky, wipes out dc info in rows
  end
end
