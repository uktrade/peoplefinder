# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.5'

gem 'active_model_serializers', '~> 0.10.2'
gem 'activerecord-session_store'
gem 'ancestry', '~> 3.0.5'
gem 'aws-sdk', '~> 2.5', '>= 2.5.5'
gem 'country_select'
gem 'delayed_job', '~> 4.1.5'
gem 'delayed_job_active_record', '~> 4.1.0'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'faker'
gem 'fastimage', '~> 2.1'
gem 'fog-aws', '~> 2.0.1'
gem 'friendly_id', '~> 5.2.5'
gem 'geckoboard-ruby', '~> 0.4.0'
gem 'govspeak', '~> 5'
gem 'govuk_elements_form_builder', '>= 0.0.3', '~> 0.0'
gem 'govuk_elements_rails', '~> 2.2'
gem 'govuk_frontend_toolkit', '>= 5.2.0'
gem 'govuk_template', '~> 0.22.3'
gem 'haml-rails'
gem 'jbuilder'
gem 'jquery-rails', '>= 4.0.4'
gem 'json'
gem 'mail'
gem 'mini_magick'
gem 'omniauth-oauth2'
gem 'paper_trail', '~> 8.1.2'
gem 'pg'
gem 'premailer-rails'
gem 'pundit'
gem 'rails', '~> 5.1.7'
gem 'sass-rails'
gem 'sentry-raven'
gem 'text'
gem 'uglifier', '>= 2.7.2'
gem 'unf'
gem 'unicorn', '~> 4.8.3'
gem 'unicorn-worker-killer', '~> 0.4.4'
gem 'useragent'
gem 'virtus'
gem 'whenever', require: false
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'zendesk_api'

gem 'carrierwave', '~> 1.1.0'

# TODO: Sprockets 4 is currently causing too many issues with the assets mess
#       in People Finder. Once the frontend code has been cleaned up, we can
#       start looking into this.
gem 'sprockets', '~> 3'

group :assets do
  gem 'coffee-rails'
end

group :production do
  gem 'logstasher', '~> 0.6.2'
  gem 'rails_12factor'
end

group :development do
  gem 'daemon'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'jasmine-rails'
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
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'byebug'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'simplecov'
  gem 'timecop'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
