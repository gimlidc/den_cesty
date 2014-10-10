module RaceHelper

	# Race state conversion to string representation
	def raceStatePretty(raceState)
		case raceState
			when 0
			  "Not Started"
			when 1
			  "Started"
			when 2
			  "Ended"
			else
			  "Undefined"
		end
	end

end
