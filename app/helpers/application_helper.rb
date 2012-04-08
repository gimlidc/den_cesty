module ApplicationHelper

	def dc_name(id)
		return $dc_spec[id-1]
	end

end