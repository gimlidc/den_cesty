# encoding: utf-8
module PageHelper

	def time_remaining_to_now_in_czech(timestamp)
		remains  = timestamp - Time.now

		out = ""

		if remains > 0
			out += "za "
		else
			out += "před "
		end

		days = (Integer(remains / ( 24 * 60 * 60))).abs;
		if days > 365
		else
			if days == 1
				out += "1 den"
			else
				if days > 1 && days < 5
					out += "#{days} dny"
				else
					out += "#{days} dní"
				end
			end
		end

		out += " "

		hours = Integer((remains - (days * 24 * 60 * 60))/ 3600).abs
		if hours == 1
			out += "1 hodinu"
		else
			if hours > 1 && hours < 5
				out += "#{hours} hodiny"
			else
				out += "#{hours} hodin"
			end
		end

		out += " "

		minutes = Integer((remains - days * 24 * 60 * 60 - hours * 60 * 60)/ 60).abs
		if minutes == 1
			out += "1 minutu"
		else
			if minutes > 1 && minutes < 5
				out += "#{minutes} minuty"
			else
				out += "#{minutes} minut"
			end
		end
		return out
	end
end
