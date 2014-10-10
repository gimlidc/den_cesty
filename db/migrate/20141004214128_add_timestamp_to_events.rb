class AddTimestampToEvents < ActiveRecord::Migration
  def change
    add_column :events, :timestamp, :datetime
  end
end
