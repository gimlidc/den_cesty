class Event < ActiveRecord::Base

  belongs_to :walker
  belongs_to :dc

	# JSON serialization into hash
	serialize :eventData, Hash

	validates_uniqueness_of :dc_id, scope: [:walker_id, :eventId]
end
