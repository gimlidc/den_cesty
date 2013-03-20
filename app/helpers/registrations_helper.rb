module RegistrationsHelper

	def shirt_price(shirt_size)
		price = 0
		if (!shirt_size.eql?("NO") && !shirt_size.eql?("OWN"))
			price += $shirt_price
		end
		if (shirt_size.eql?("OWN"))
			price += $own_shirt_price
		end
		return price
	end

	def bw_map_price(bw_map)
		price = 0
		if (bw_map == true)
			price+= $bw_map_price
		end
		return price
	end

	def colour_map_price(colour_map)
		price = 0
		if (colour_map == true)
			price+= $colour_map_price
		end
		return price
	end

	def price(reg)
		return $reg_price + shirt_price(reg.shirt_size) + bw_map_price(reg.bw_map) + colour_map_price(reg.colour_map)
	end

	def is_registered
		@reg = Registration.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $current_dc_id})
		if @reg.nil? || @reg.empty? || @reg[0].canceled == true
			return false
		else
			return true
		end
	end
	
	def isLimit
    Registration.find(:all, :conditions => {:dc_id => $current_dc_id, :canceled => false}).count > $race_limit
  end

end
