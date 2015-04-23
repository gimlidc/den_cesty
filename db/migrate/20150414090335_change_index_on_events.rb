class ChangeIndexOnEvents < ActiveRecord::Migration
  def up
    remove_index "events", :column => ["race_id", "walker_id", "eventId"]

    # This will fix the index nonuniqueness after mobile app reinstall
    add_index "events", ["race_id", "walker_id", "eventId", "timestamp"]
  end

  def down
    remove_index "events", :column => ["race_id", "walker_id", "eventId", "timestamp"]
    add_index "events", ["race_id", "walker_id", "eventId"]
  end
end
