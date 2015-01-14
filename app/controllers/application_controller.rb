# encoding: utf-8
class ApplicationController < ActionController::Base
  
  protect_from_forgery

  before_filter :check_admin?
  before_filter :check_logged_in?
  before_filter :loadDcParams  
  
  $sex_options = [[I18n.t('male'), "male"], [I18n.t('female'), "female"]]

  before_filter :set_locale

  helper_method :check_logged_in?, :check_admin?

  def check_logged_in?
    if !walker_signed_in?
      flash.notice = "Please sing in before accessing this page."
      redirect_to new_walker_session_path
    return false
    end
    return true
  end

  $admin_name = ["gimli", "evajs"]

  def check_admin?
    if !walker_signed_in?
    return false
    else
      if !$admin_name.include?(current_walker.username)
        #flash.notice = "Sorry you are not ADMINISTRATOR"
        #redirect_to :controller => "pages", :action => "unauthorized"
        return false
      else
        return true
      end

    end
  end

  def loadDcParams
    if ENV["RAILS_ENV"] != "test"
      $dc = Dc.find(20)  
      $dc_app_start = Time.zone.parse("2015-01-17 06:50:00 +0100")
      $dc_app_end =   Time.zone.parse("2015-01-17 19:05:00 +0100")
      $shirt_deadline = ($dc.start_time - 17.days).end_of_day
      $registration_deadline = ($dc.start_time - 4.days).end_of_day
      $registration_starts = true
      $report_deadline = ($dc.start_time + 1.month).end_of_day          
    end    
    $race_limit = $dc.limit    
  end

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
  
end
