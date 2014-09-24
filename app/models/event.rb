class Event < ActiveRecord::Base

	# To configure a different table name:
	# self.table_name = "events"

	serialize :eventData, Hash

end
