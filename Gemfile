source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Using ap
gem 'awesome_print'

# Cancan
gem 'cancancan'

# Calling decorate method
gem 'draper'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1', '>= 6.1.7.6'
gem 'rails-i18n', '~> 7.0', '>= 7.0.8'

# Use Puma as the app server
gem 'puma', '~> 3.11'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Error notification
# Any other things that need to be notified
gem 'slack_500'
gem 'slack-notifier'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# TODO: Skip it temp to avoid waring message
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Syntax checking
gem 'rubocop', '~> 1.31', require: false

# Environment variables setting
gem 'dotenv-rails'

# Login
gem 'devise'
gem 'sorcery'

# Frontend related
gem 'ajax-datatables-rails'
gem "bootstrap-sass", "~>3.3.6"
gem "bootstrap_form", "~> 5.0"
gem 'font-awesome-sass', '~> 5.4.1'
gem 'jquery-rails'
gem "jquery-ui-rails"
gem 'popper_js', '~> 2.9.3'
gem 'kaminari'
# gem 'jquery-datatables-rails', '~> 3.4.0'
gem 'jquery-datatables'
# moment.js
gem 'momentjs-rails'

# Tempus Dominus
gem 'bootstrap4-datetime-picker-rails'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-daterangepicker-rails'
gem 'flatpickr'

# Object-based searching
gem 'ransack'

# Form
gem "cocoon"
gem 'simple_form'

# Model related
gem 'counter_culture', '~> 3.2'
gem 'enumerize'
gem 'paper_trail'
gem 'state_machines'
gem 'state_machines-activerecord'

# Export report related gem
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'
gem 'rubyzip', '>= 1.2.1'

# Clone order related gem
gem 'deep_cloneable', '~> 3.2.0'

# Import file task related gem
gem 'roo'

# Queue Job gem
gem 'sidekiq'
gem 'sidekiq-scheduler'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development, :production do
  # Database adapter install
  gem 'pg'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Database adapter install
  # gem 'mysql2'

  gem 'foreman'

  gem "ruby-lsp", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Production setting
group :production do
  gem 'rails_12factor'
end
