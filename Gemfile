# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.3'

gem 'active_model_serializers', '~> 0.10.2'
gem 'activerecord-session_store'
gem 'ancestry', '~> 3.0.5'
gem 'aws-sdk', '~> 2.5', '>= 2.5.5'
gem 'country_select'
gem 'delayed_job', '~> 4.1.5'
gem 'delayed_job_active_record', '~> 4.1.0'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'faker', '~> 1.7'
gem 'fastimage', '~> 2.1'
gem 'fog-aws', '~> 2.0.1'
gem 'friendly_id', '~> 5.2.5'
gem 'geckoboard-ruby', '~> 0.4.0'
gem 'govspeak'
gem 'govuk_elements_form_builder', '>= 0.0.3', '~> 0.0'
gem 'govuk_elements_rails', '~> 2.2'
gem 'govuk_frontend_toolkit', '>= 5.2.0'
gem 'govuk_template', '~> 0.22.3'
gem 'haml-rails'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails', '>= 4.0.4'
gem 'json'
gem 'keen'
gem 'mail'
gem 'mini_magick'
gem 'omniauth-oauth2'
gem 'paper_trail', '~> 8.1.2'
gem 'pg'
gem 'premailer-rails', '~> 1.9'
gem 'pundit', '~> 1.1'
gem 'rails', '~> 5.1.7'
gem 'sass-rails', '~> 5.0.7'
gem 'sentry-raven'
gem 'text'
gem 'uglifier', '>= 2.7.2'
gem 'unf'
gem 'unicorn', '~> 4.8.3'
gem 'unicorn-worker-killer', '~> 0.4.4'
gem 'useragent', '~> 0.10'
gem 'virtus'
gem 'whenever', require: false
gem 'will_paginate', '~> 3.0', '>=3.0.3'
gem 'will_paginate-bootstrap', '~> 1.0', '>= 1.0.1'
gem 'zendesk_api'

gem 'carrierwave', '~> 1.1.0'

group :assets do
  gem 'coffee-rails'
end

group :production do
  gem 'logstasher', '~> 0.6.2'
  gem 'rails_12factor'
end

group :development do
  gem 'binding_of_caller'
  gem 'daemon'
  gem 'meta_request'
  gem 'rb-fsevent', require: !RUBY_PLATFORM[/darwin/i].to_s.empty?
  gem 'spring-commands-rspec'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'site_prism'
  gem 'webmock'
  gem 'whenever-test'
end

group :development, :test do
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'byebug'
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'guard-jasmine'
  gem 'jasmine-rails'
  gem 'launchy'
  gem 'minitest'
  gem 'poltergeist'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers', '~> 4.0.0.rc1'
  gem 'simplecov'
  gem 'timecop'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
