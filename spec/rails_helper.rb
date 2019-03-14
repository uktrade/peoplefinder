require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['SUPPORT_EMAIL'] = 'support@example.com'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'pry-byebug'
require 'timecop'
require 'paper_trail/frameworks/rspec'
require 'shoulda-matchers'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'site_prism'

unless ENV['SKIP_SIMPLECOV']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/gem/'
    add_filter '.bundle'
  end
  SimpleCov.minimum_coverage 70
end

Capybara.register_driver :poltergeist_silent do |app|
  # Redirect phantomjs log output to a dummy StringIO to ignore it
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: StringIO.new)
end

# define a the PROFILE_API_TOKEN to ensure the API specs can be authenticated
ENV['PROFILE_API_TOKEN'] = 'DEFINED'

# Capybara.javascript_driver = :poltergeist # uncomment to enable console.log
Capybara.javascript_driver = :poltergeist_silent # uncomment this to disable console.log (including warn)
Capybara.default_max_wait_time = 3

# The feature tests check hidden elements using Capybara, which used to work but doesn't anymore, so we
# need to enable this setting.
Capybara.ignore_hidden_elements = false

Dir[File.expand_path('../../{lib,app/*}', __FILE__)].sort.each do |path|
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].sort.each { |f| require f }

Dir[File.expand_path('../controllers/concerns/shared_examples*.rb', __FILE__)].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  # Both Docker Compose and Travis CI use remote DB URLs
  DatabaseCleaner.allow_remote_database_url = true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  config.include FactoryBot::Syntax::Methods
  config.include SpecSupport::Login
  config.include SpecSupport::Search
  config.include SpecSupport::Carrierwave
  config.include SpecSupport::OrgBrowser
  config.include SpecSupport::Email
  config.include SpecSupport::Profile
  config.include SpecSupport::DbHelper
  config.include SpecSupport::ElasticSearchHelper
  config.include SpecSupport::FeatureFlags
  config.include SpecSupport::AppConfig
  config.include SpecSupport::GeckoboardHelper
end
