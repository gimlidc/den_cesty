class ImportDc20Checkpoints < ActiveRecord::Migration
  def up
  	Checkpoint.create(:dc => 20, :checkid => 0, :meters => 0, :latitude => 49.8509289, :longitude => 14.7023164)
	Checkpoint.create(:dc => 20, :checkid => 1, :meters => 4400, :latitude => 49.8824822, :longitude => 14.7285136)
	Checkpoint.create(:dc => 20, :checkid => 2, :meters => 11000, :latitude => 49.8725675, :longitude => 14.8027314)
	Checkpoint.create(:dc => 20, :checkid => 3, :meters => 18000, :latitude => 49.8808928, :longitude => 14.8876453)
	Checkpoint.create(:dc => 20, :checkid => 4, :meters => 30000, :latitude => 49.8447842, :longitude => 14.9625925)
	Checkpoint.create(:dc => 20, :checkid => 5, :meters => 39000, :latitude => 49.7960792, :longitude => 14.9245100)
	Checkpoint.create(:dc => 20, :checkid => 6, :meters => 50000, :latitude => 49.7768067, :longitude => 15.0316119)
	Checkpoint.create(:dc => 20, :checkid => 7, :meters => 63000, :latitude => 49.7296217, :longitude => 15.1612569)
	Checkpoint.create(:dc => 20, :checkid => 8, :meters => 73000, :latitude => 49.7146008, :longitude => 15.2213333)
	Checkpoint.create(:dc => 20, :checkid => 9, :meters => 80000, :latitude => 49.6965169, :longitude => 15.2759400)
	Checkpoint.create(:dc => 20, :checkid => 10, :meters => 93000, :latitude => 49.6675142, :longitude => 15.3966600)
	Checkpoint.create(:dc => 20, :checkid => 11, :meters => 102000, :latitude => 49.6308664, :longitude => 15.4871344)
	Checkpoint.create(:dc => 20, :checkid => 12, :meters => 106000, :latitude => 49.6115606, :longitude => 15.5189383)
	Checkpoint.create(:dc => 20, :checkid => 13, :meters => 113000, :latitude => 49.5995289, :longitude => 15.5878600)
  end

  def down
  	Checkpoint.delete_all(:dc => 20)
  end
end
