require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module DenCesty
  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
		# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :cs

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

		config.action_mailer.default_url_options = { :host => 'localhost:3000' }
		
		# this skips authorization checks inside devise (out of this project) pages
		config.to_prepare do
      Devise::SessionsController.skip_before_filter :check_admin?
      Devise::SessionsController.skip_before_filter :check_logged_in?
      Devise::RegistrationsController.skip_before_filter :check_admin?
      Devise::RegistrationsController.skip_before_filter :check_logged_in?
      Devise::ConfirmationsController.skip_before_filter :check_admin?
      Devise::ConfirmationsController.skip_before_filter :check_logged_in?
      Devise::PasswordsController.skip_before_filter :check_admin?
      Devise::PasswordsController.skip_before_filter :check_logged_in?
      Devise::OmniauthCallbacksController.skip_before_filter :check_admin?
      Devise::OmniauthCallbacksController.skip_before_filter :check_logged_in?
    end
				
  end  
end
