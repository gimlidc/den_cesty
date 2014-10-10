class AddIndexToEvents < ActiveRecord::Migration
  def change
  	add_index "events", ["walker", "eventId"], :unique => true
  end
end
