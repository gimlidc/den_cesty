class AddGoalToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :goal, :string
  end
end
