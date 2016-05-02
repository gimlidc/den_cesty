class AddRaceIdIntoDcs < ActiveRecord::Migration
  def change
    add_column :dcs, :race_id, :integer
  end
end
