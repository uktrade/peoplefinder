# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.5'

# gem 'actioncable', '~> 6.0.1'
# gem 'actionmailbox', '~> 6.0.1'
gem 'actionmailer', '~> 6.0.1'
gem 'actionpack', '~> 6.0.1'
# gem 'actiontext', '~> 6.0.1'
gem 'actionview', '~> 6.0.1'
gem 'activejob', '~> 6.0.1'
gem 'activemodel', '~> 6.0.1'
gem 'activerecord', '~> 6.0.1'
gem 'activestorage', '~> 6.0.1'
gem 'activesupport', '~> 6.0.1'

gem 'active_model_serializers'
gem 'activerecord-session_store'
gem 'ancestry'
gem 'aws-sdk-s3'
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
gem 'geckoboard-ruby'
gem 'govuk_elements_form_builder', '~> 0.0'
gem 'govuk_elements_rails', '~> 2.2'
gem 'govuk_frontend_toolkit'
gem 'govuk_template'
gem 'haml-rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'json'
gem 'kramdown'
gem 'mail'
gem 'mini_magick'
gem 'omniauth-oauth2'
gem 'paper_trail', '~> 10.3'
gem 'pg'
gem 'premailer-rails'
gem 'puma'
gem 'pundit'
gem 'sass-rails'
gem 'sentry-raven'
gem 'text'
gem 'uglifier'
gem 'unf'
gem 'useragent'
gem 'virtus'
gem 'whenever', require: false
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'zendesk_api'

gem 'carrierwave', '~> 1.3.1'

# TODO: Sprockets 4 is currently causing too many issues with the assets mess
#       in People Finder. Once the frontend code has been cleaned up, we can
#       start looking into this.
gem 'sprockets', '~> 3'

group :assets do
  gem 'coffee-rails'
end

group :production do
  gem 'logstasher'
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
  gem 'rspec-rails', '~> 4.0.0beta3' # TODO: Unpin when 4.0 release is out
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
