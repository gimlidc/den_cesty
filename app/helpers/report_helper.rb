module ReportHelper

	def has_report(dc_id)
		@report = Report.where(:dc_id => dc_id, :walker_id => current_walker[:id] )
		return !@report.nil? && !@report.empty?
	end

	def format(text)
		text.gsub("\n",'<br />')
	end

end
