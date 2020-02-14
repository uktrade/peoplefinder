# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.5'

# TODO: Only load the subgems we need
#  This is currently not possible because some `govuk_*` gems wrongly specify
#  the whole of `rails` as a dependency.
gem 'rails', '~> 6.0.2'

gem 'ancestry'
gem 'carrierwave'
gem 'country_select'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'elasticsearch', '~> 6.1' # TODO: Pinned because we're using ES 6.x, not 7.x
gem 'elasticsearch-model', '~> 6.0.0' # TODO: Pinned due to search result order issue in >= 6.1
gem 'elasticsearch-rails', '~> 6.1'
gem 'faker'
gem 'fastimage'
gem 'fog-aws'
gem 'friendly_id'
gem 'govuk_elements_form_builder', '~> 0.0'
gem 'govuk_elements_rails', '~> 2.2'
gem 'govuk_frontend_toolkit'
gem 'govuk_template'
gem 'haml-rails'
gem 'health_check'
gem 'jquery-rails'
gem 'kramdown'
gem 'mini_magick'
gem 'notifications-ruby-client'
gem 'omniauth-oauth2'
gem 'paper_trail'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'redis'
gem 'sass-rails'
gem 'sentry-raven'
gem 'sidekiq'
gem 'sprockets', '~> 3' # TODO: Pinned due to asset issues with >= 4.0
gem 'uglifier'
gem 'useragent'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'zendesk_api'

group :production do
  gem 'logstasher'
  gem 'rails_12factor'
end

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'rspec-rails', '~> 4.0.0beta4' # TODO: Unpin when 4.0 release is out
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'site_prism'
  gem 'webmock'
  gem 'whenever-test'
end

group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'reek'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'simplecov'
  gem 'timecop'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
