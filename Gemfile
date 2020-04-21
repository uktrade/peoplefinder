# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.5'

RAILS_VERSION = '~> 6.0.2'
gem 'actionpack', RAILS_VERSION
gem 'activemodel', RAILS_VERSION
gem 'activerecord', RAILS_VERSION
gem 'activesupport', RAILS_VERSION
gem 'railties', RAILS_VERSION

gem 'ancestry'
gem 'carrierwave'
gem 'country_select'
gem 'elasticsearch', '~> 6.1' # TODO: Pinned because we're using ES 6.x, not 7.x
gem 'elasticsearch-model', '~> 6.0.0' # TODO: Pinned due to search result order issue in >= 6.1
gem 'elasticsearch-rails', '~> 6.1'
gem 'elastic-apm'
gem 'faker'
gem 'fastimage'
gem 'fog-aws'
gem 'friendly_id'
gem 'gibbon'
gem 'govuk_design_system_formbuilder'
gem 'health_check'
gem 'interactor'
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
gem 'slim'
gem 'webpacker'
gem 'zendesk_api'

group :legacy_frontend, :default do
  # TODO: Once the entire app is moved to GOV.UK Frontend, we can remove all of these dependencies.
  gem 'govuk_elements_form_builder', '~> 0.0'
  gem 'govuk_elements_rails', '~> 2.2'
  gem 'govuk_frontend_toolkit'
  gem 'govuk_template'
  gem 'haml-rails'
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'sprockets', '~> 3' # TODO: Pinned due to asset issues with >= 4.0
  gem 'uglifier'
end

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'site_prism'
  gem 'webmock'
  gem 'whenever-test'
end

group :development, :test do
  gem 'brakeman', require: false
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'timecop'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
