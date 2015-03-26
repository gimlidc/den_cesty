# encoding: utf-8
class ApplicationController < ActionController::Base
  
  protect_from_forgery

  before_filter :check_admin?
  before_filter :check_logged_in?
  before_filter :loadDcParams  
  
  $sex_options = [[I18n.t('male'), "male"], [I18n.t('female'), "female"]]

  before_filter :set_locale

  helper_method :check_logged_in?, :check_admin?, :is_admin?

  def check_logged_in?
    if !walker_signed_in?
      flash.notice = "Please sing in before accessing this page."
      redirect_to new_walker_session_path
    return false
    end
    return true
  end

  $admin_email = ["gimli@matfyz.cz", "evajs@matfyz.cz"]

  def is_admin?
    if !walker_signed_in?
      return false
    else
      if !$admin_email.include?(current_walker.email)
        return false
      else
        return true
      end

    end
  end

  def check_admin?
    if !is_admin?
      flash.notice = "Sorry you are not ADMINISTRATOR"
      redirect_to :controller => "pages", :action => "unauthorized"
    end
  end

  def loadDcParams
    if ENV["RAILS_ENV"] != "test"
      $dc = Dc.find(23)  
      $dc_app_start = $dc.start_time - 10.minutes
      $dc_app_end =   $dc.start_time + 12.hours + 10.minutes
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
  
end
