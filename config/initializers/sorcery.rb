# Rails.application.config.sorcery.submodules = []
Rails.application.config.sorcery.submodules = [:session_timeout]

# Here you can configure each submodule's features.
Rails.application.config.sorcery.configure do |config|
  # ...
  # --- user config ---
  config.user_config do |user|
    # ...
    user.stretches = 1 if Rails.env.test?

    # Change sorcery default email column to username column
    user.username_attribute_names = [:username]
  end

  # Set timeout
  config.session_timeout = 3600
  config.session_timeout_from_last_action = true

  config.user_class = 'Admin'
end
