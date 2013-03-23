module ApplicationHelper

	def dc_name(id)
		return $dc_spec[id-1]
	end

	def dc_select
		@dc_select=""
		for i in 1..$dc.id do
			if i == @dc_id
				@dc_select+="<option value=#{i} selected=\"selected\">#{$dc_spec[i-1]}</option>\n"
			else
				@dc_select+="<option value=#{i}>#{$dc_spec[i-1]}</option>\n"
			end
		end

		return @dc_select
	end

end