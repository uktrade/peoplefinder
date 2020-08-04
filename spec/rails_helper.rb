# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'timecop'
require 'paper_trail/frameworks/rspec'
require 'shoulda-matchers'
require 'capybara/rspec'
require 'site_prism'
require 'sidekiq/testing'

Capybara.register_driver :poltergeist_silent do |app|
  # Redirect phantomjs log output to a dummy StringIO to ignore it
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: StringIO.new)
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu no-sandbox]
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.server = :webrick
Capybara.javascript_driver = :chrome
Capybara.default_max_wait_time = 3

Dir[File.expand_path('../{lib,app/*}', __dir__)].sort.each do |path|
end

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

Dir[File.expand_path('controllers/concerns/shared_examples*.rb', __dir__)].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include SpecSupport::Login
  config.include SpecSupport::Search
  config.include SpecSupport::Carrierwave
  config.include SpecSupport::Profile
  config.include SpecSupport::AppConfig

  config.infer_spec_type_from_file_location!

  # This enable Rails's `use_transactional_tests` (for legacy reasons, it hasn't been renamed
  # in RSpec config)
  config.use_transactional_fixtures = true
end
