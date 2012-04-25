# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

	$current_dc_id = 16
	$dc_date = Time.local(2012, 4, 21, 10, 00, 00, 00);
	$shirt_deadline = Time.local(2012, 4, 1, 00, 00, 00, 00);
	$registration_deadline = Time.local(2012, 4, 18, 12, 00, 00, 00);
	$admin_name = "gimli"
	$sex_options = [["male", I18n.t('male')], ["female", I18n.t('female')]]
	$report_deadline = Time.local(2012, 5, 21, 00, 00, 00, 00);
	$dc_spec = ["jaro 2005 - Sázava",
		"podzim 2005 - Sázava II",
		"jaro 2006 - Otava",
		"podzim 2006 - Otava II",
		"jaro 2007 - Středohořím",
		"podzim 2007 - Deštivým středohořím",
		"jaro 2008 - Vrchovinou",
		"podzim 2008 - Vrchovinou II",
		"jaro 2009 - Lázeňská",
		"léto 2010 - Na Ještěd",
		"podzim 2009 - Lázeňská II",
		"jaro 2010 - Zelenohorská",
		"podzim 2010 - Zelenohorská II",
		"jaro 2011 - Blaník",
		"podzim 2011 - Do stříbrného města II",
		"jaro 2012 - Nejkrásnější Moravská",
		"podzim 2012 - Nejkrásnější Moravská II",
	]

	before_filter :set_locale

	def set_locale
		I18n.locale = params[:locale] || I18n.default_locale
	end

	def default_url_options(options={})
		logger.debug "default_url_options is passed options: #{options.inspect}\n"
		{ :locale => I18n.locale }
	end
end
