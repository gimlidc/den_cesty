class Event < ActiveRecord::Base

  belongs_to :walker
  belongs_to :race

  # JSON serialization into hash
  serialize :eventData, Hash

  validates_uniqueness_of :race_id, scope: [:walker_id, :eventId, :timestamp]
end
