require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fingertipsco
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

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
