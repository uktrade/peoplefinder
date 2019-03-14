source 'https://rubygems.org'
ruby '2.5.3'

gem 'rails', '~> 5.1.6'
gem 'text'
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
gem 'foreman'
gem 'friendly_id', '~> 5.2.5'
gem 'govspeak'
gem 'govuk_template',         '~> 0.19.2'
gem 'govuk_frontend_toolkit', '>= 5.2.0'
gem 'govuk_elements_rails',   '>= 1.1.2'
gem 'govuk_elements_form_builder', '>= 0.0.3', '~> 0.0'
gem 'geckoboard-ruby', '~> 0.4.0'
gem 'haml-rails'
gem 'httparty'
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
gem 'sass-rails', '~> 5.0.6'
gem 'sentry-raven'
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
  gem 'spring-commands-rspec'
  gem 'rb-fsevent', require: RUBY_PLATFORM[/darwin/i].to_s.size > 0
  gem 'meta_request'
  gem 'binding_of_caller'
  gem 'daemon'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'site_prism'
  gem 'webmock'
  gem 'whenever-test'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
end

group :development, :test do
  gem 'byebug'
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 4.0.0.rc1'
  gem 'simplecov'
  gem 'timecop'
  gem 'guard-jasmine'
  gem 'jasmine-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'annotate'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
