# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_admin?
  before_filter :check_logged_in?

  # $current_dc_id = 17
  # $dc_date = Time.local(2012, 10, 26, 19, 00, 00, 00);
  # $shirt_deadline = Time.local(2012, 10, 10, 23, 59, 00, 00);
  # $registration_deadline = Time.local(2012, 10, 23, 23, 59, 00, 00);
  # $report_deadline = Time.local(2012, 11, 14, 00, 00, 00, 00);

  $current_dc_id = 18
  $dc_date = Time.local(2013, 4, 27, 9, 30, 00, 00)
  $shirt_deadline = Time.local(2013, 4, 10, 23, 59, 00, 00)
  $registration_deadline = Time.local(2013, 4, 23, 23, 59, 00, 00)
  $registration_starts = true
  $report_deadline = Time.local(2013, 5, 14, 00, 00, 00, 00)
  $race_limit = 100

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

  def after_sign_in_path_for(resource)
    sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, :protocol => 'http')
    
    if request.referer == sign_in_url
      super
    else
      stored_location_for(resource) || request.referer || root_path
    end
  end

  def check_logged_in?
    if !walker_signed_in?
      flash.notice = "Please sing in before accessing this page."
      redirect_to new_walker_session_path
      return false
    end
    return true
  end  

  def check_admin?        
    if !check_logged_in?
      return false
    else
      if current_walker.username != $admin_name
        flash.notice = "Sorry you are not ADMINISTRATOR"
        redirect_to :controller => "pages", :action => "unauthorized"
        return false
      else
        return true
      end
      
    end
  end
  
end
