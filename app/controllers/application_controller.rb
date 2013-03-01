# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  # $current_dc_id = 17
  # $dc_date = Time.local(2012, 10, 26, 19, 00, 00, 00);
  # $shirt_deadline = Time.local(2012, 10, 10, 23, 59, 00, 00);
  # $registration_deadline = Time.local(2012, 10, 23, 23, 59, 00, 00);
  # $report_deadline = Time.local(2012, 11, 14, 00, 00, 00, 00);

  $current_dc_id = 18
  $dc_date = Time.local(2013, 4, 27, 9, 30, 00, 00);
  $shirt_deadline = Time.local(2013, 4, 10, 23, 59, 00, 00);
  $registration_deadline = Time.local(2013, 4, 23, 23, 59, 00, 00);
  $report_deadline = Time.local(2013, 5, 14, 00, 00, 00, 00);

  $admin_name = "gimli"
  $sex_options = [["male", I18n.t('male')], ["female", I18n.t('female')]]
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
    "jaro 2013 - Revoluční"
  ]

  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end

  def check_admin
    if !walker_signed_in?
      redirect_to :controller => "walkers", :action => "sign_in"
    else
      if current_walker.username != $admin_name
        flash.notice = "Sorry you are not ADMINISTRATOR"
        redirect_to :controller => "pages", :action => "unauthorized"
      end
    end
  end
  
end
