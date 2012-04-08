module ReportHelper

	def has_report
		@report = Report.all(:conditions => {:dc_id => $current_dc_id, :walker_id => current_walker[:id] })
		return !@report.nil? && !@report.empty?
	end

	def format(text)
		text.gsub("\n",'<br />')
	end

end