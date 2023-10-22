require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fingertipsco
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # rails 6.1 settings
    config.active_record.has_many_inversing = true
    config.active_storage.track_variants = true
    config.active_job.retry_jitter = 0.15
    config.active_job.skip_after_callbacks_if_terminated = true
    ActiveSupport.utc_to_local_returns_utc_offset_times = true
    config.action_dispatch.ssl_default_redirect_status = 308
    config.active_record.legacy_connection_handling = false
    config.action_view.form_with_generates_remote_forms = false
    config.active_storage.queues.analysis = nil
    config.active_storage.queues.purge = nil
    config.action_mailbox.queues.incineration = nil
    config.action_mailbox.queues.routing = nil
    config.action_mailer.deliver_later_queue_name = nil
    config.action_view.preload_links_header = true
    config.action_dispatch.cookies_same_site_protection = :lax
    config.action_controller.urlsafe_csrf_tokens = true

    # Set the rails web appplication default langauge to Hong Kong
    # Default is en
    # TODO: will having language change for future use
    config.i18n.default_locale = :'zh-HK'

    # Change the default time zone to Japan(Tokyo) to fit the order exact create time
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    config.active_job.queue_adapter = :sidekiq

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      g.assets      false
      g.helper      false
      g.decorator   false
    end
  end
end
