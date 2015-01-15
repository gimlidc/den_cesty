class Event < ActiveRecord::Base

	# JSON serialization into hash
	serialize :eventData, Hash

	validates_uniqueness_of :dc, scope: [:walker, :eventId]
end
