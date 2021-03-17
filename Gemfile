# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.1'

RAILS_VERSION = '~> 6.0.3'
gem 'actionpack', RAILS_VERSION
gem 'activemodel', RAILS_VERSION
gem 'activerecord', RAILS_VERSION
gem 'activesupport', RAILS_VERSION
gem 'railties', RAILS_VERSION

gem 'ancestry'
gem 'carrierwave'
gem 'country_select', '~> 5.0.1'
gem 'elasticsearch', '~> 7.9.0'
gem 'elasticsearch-model', '~> 7.1.1'
gem 'elasticsearch-rails'
gem 'elastic-apm'
gem 'faker'
gem 'fastimage'
gem 'fog-aws'
gem 'friendly_id'
gem 'gibbon'
gem 'govuk_design_system_formbuilder'
gem 'health_check'
gem 'interactor'
gem 'jwt'
gem 'kaminari'
gem 'kramdown'
gem 'loaf'
gem 'lograge'
gem 'mini_magick'
gem 'notifications-ruby-client'
gem 'omniauth-oauth2'
gem 'paper_trail'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'redis'
gem 'sentry-raven'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'slim'
gem 'webpacker'
gem 'zendesk_api'

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'selenium-webdriver', '~> 4.0.0alpha'
  gem 'shoulda-matchers', '~> 4.3.0' # TODO: Pinned due to https://github.com/thoughtbot/shoulda-matchers/issues/1333
  gem 'webmock'
end

group :development, :test do
  gem 'brakeman', require: false
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'timecop'
end
