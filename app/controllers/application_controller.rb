class ApplicationController < ActionController::Base
  protect_from_forgery

	$current_dc_id = 16
	$dc_date = Time.local(2012, 4, 21, 10, 00, 00, 00);
	$shirt_deadline = Time.local(2012, 4, 1, 00, 00, 00, 00);
	$admin_name = "gimli"
	$sex_options = [["male", I18n.t('male')], ["female", I18n.t('female')]]

	before_filter :set_locale

	def set_locale
		I18n.locale = params[:locale] || I18n.default_locale
	end

	def default_url_options(options={})
		logger.debug "default_url_options is passed options: #{options.inspect}\n"
		{ :locale => I18n.locale }
	end
end
