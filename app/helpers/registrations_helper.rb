module RegistrationsHelper

  def polyester_shirt_price(shirt_size)
    price = 0
    if ($dc.polyester_shirt_price == -1)
      return 0
    end
    if (!shirt_size.eql?("NO"))
      price += $dc.polyester_shirt_price
    end
    return price
  end
  
  def scarf_price(scarf)
    price = 0
    if ($dc.scarf_price == -1)
      return 0
    end
    if (scarf == true)
      return $dc.scarf_price
    end
    return price
  end

	def shirt_price(shirt_size)
		price = 0
		if ($dc.shirt_price == -1)
		  return 0
		end
		if (!shirt_size.eql?("NO") && !shirt_size.eql?("OWN"))
			price += $dc.shirt_price
		end
		if (shirt_size.eql?("OWN"))
			price += $dc.own_shirt_price
		end
		return price
	end

	def bw_map_price(bw_map)
		price = 0
		if (bw_map == true && $dc.map_bw_price != -1)
			price+= $dc.map_bw_price
		end
		return price
	end

	def colour_map_price(colour_map)
		price = 0
		if (colour_map == true && $dc.map_color_price != -1)
			price+= $dc.map_color_price
		end
		return price
	end

	def price(reg)
		return $dc.reg_price + shirt_price(reg.shirt_size) + bw_map_price(reg.bw_map) + colour_map_price(reg.colour_map) + scarf_price(reg.scarf) + polyester_shirt_price(reg.shirt_polyester)
	end

	def is_registered
		@reg = Registration.find(:all, :conditions => {:walker_id => current_walker[:id], :dc_id => $dc.id})
		if @reg.nil? || @reg.empty? || @reg[0].canceled == true
			return false
		else
			return true
		end
	end
	
	def races_finished
	  if walker_signed_in?
	    Result.count(:conditions => ["walker_id = ? AND distance != ?", current_walker[:id], 0])
	  else
	    return 0
	  end
	end
	
	def registered?
	  if walker_signed_in?
	    return Registration.where(:dc_id => $dc.id, :walker_id => current_walker[:id]).size == 1
	  else
	    return false
	  end
	end
	
	def isLimit
    Registration.find(:all, :conditions => {:dc_id => $dc.id, :canceled => false}).count >= $race_limit
  end

  def bool2str(value)
    if value
        return "yes_value"
    end
    return "no_value"
  end

  def shirt2str(value)
    if value.eql?("NO")
      return "no_value"
    end
    return value
  end

end
