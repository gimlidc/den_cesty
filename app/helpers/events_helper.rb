module EventsHelper

	# Battery state conversion to string representation
	def batteryStatePretty(batteryState)
		case batteryState
			when 0
			  "Unknown"
			when 1
			  "Unplugged"
			when 2
			  "Charging"
			when 3
			  "Full"
			else
			  "Undefined"
		end
	end
end
