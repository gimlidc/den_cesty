class AddBatteryInfoToEvents < ActiveRecord::Migration
  def change
    add_column :events, :batteryLevel, :integer
    add_column :events, :batteryState, :integer
  end
end
