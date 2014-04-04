require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module Publify
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    #define default secret token to avoid information duplication
    $default_token = "08aac1f2d29e54c90efa24a4aefef843ab62da7a2610d193bc0558a50254c7debac56b48ffd0b5990d6ed0cbecc7dc08dce1503b6b864d580758c3c46056729a"
    
    # Setup the cache path
    config.action_controller.page_cache_directory = "#{::Rails.root.to_s}/public/cache/"
    config.cache_store=:file_store, "#{::Rails.root.to_s}/public/cache/"
    
    config.plugins = [ :all ]

    config.autoload_paths += %W(
      app/apis
    ).map {|dir| "#{::Rails.root.to_s}/#{dir}"}.select { |dir| File.directory?(dir) }

    # Activate observers that should always be running
    config.active_record.observers = :email_notifier, :web_notifier

    # Turn om timestamped migrations
    config.active_record.timestamped_migrations = true

    # Filter sensitive parameters from the log file
    config.filter_parameters << :password

    # To avoid exception when deploying on Heroku
    config.assets.initialize_on_precompile = false
  end

  # Load included libraries.
  require 'localization'
  require 'sidebar'
  require 'publify_sidebar'
  require 'publify_textfilters'
  require 'publify_avatar_gravatar'
  require 'calendar_date_select/lib/calendar_date_select.rb'
  require 'action_web_service'
  ## Required by the plugins themselves.
  # require 'avatar_plugin'
  require 'email_notify'

  require 'format'
  require 'i18n_interpolation_deprecation'
  require 'route_cache'
  ## Required by the models themselves.
  # require 'spam_protection'
  require 'stateful'
  require 'transforms'
  require 'publify_time'
  require 'publify_guid'
  ## Required by the plugins themselves.
  # require 'publify_plugins'
  require 'bare_migration'
  require 'publify_version'
  require 'rails_patch/active_support'

  require 'publify_login_system'

  Date::DATE_FORMATS.merge!(
    :long_weekday => '%a %B %e, %Y %H:%M'
  )

  ActionMailer::Base.default :charset => 'utf-8'

  # Work around interpolation deprecation problem: %d is replaced by
  # {{count}}, even when we don't want them to.
  # FIXME: We should probably fully convert to standard Rails I18n.
  class I18n::Backend::Simple
    def interpolate(locale, string, values = {})
      interpolate_without_deprecated_syntax(locale, string, values)
    end
  end

  if ::Rails.env != 'test'
    begin
      mail_settings = YAML.load(File.read("#{::Rails.root.to_s}/config/mail.yml"))

      ActionMailer::Base.delivery_method = mail_settings['method']
      ActionMailer::Base.server_settings = mail_settings['settings']
    rescue
      # Fall back to using sendmail by default
      ActionMailer::Base.delivery_method = :sendmail
    end
  end
end
