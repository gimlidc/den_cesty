class CreateEvents < ActiveRecord::Migration
  def up
    create_table :events, :force => true do |t|
      #walker
      t.integer "walker"
      #eventId
      t.integer "eventId"
      #type
      t.string "eventType"
      #data
      t.text "eventData"
      t.timestamps
    end
    puts "TODO: Add indexes"
  end

  def down
  	drop_table :events
  end
end
