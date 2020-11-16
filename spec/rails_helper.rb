# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'timecop'
require 'paper_trail/frameworks/rspec'
require 'shoulda-matchers'
require 'capybara/rspec'
require 'sidekiq/testing'

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      args: %w[headless disable-gpu no-sandbox enable-features=NetworkService,NetworkServiceInProcess]
    }
  )

  Capybara::Selenium::Driver.new app, browser: :chrome, capabilities: capabilities
end

Capybara.server = :webrick
Capybara.javascript_driver = :chrome
Capybara.default_max_wait_time = 3
# rubocop:disable Lint/EmptyBlock
Dir[File.expand_path('../{lib,app/*}', __dir__)].sort.each do |path|
end
# rubocop:enable Lint/EmptyBlock
Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

Dir[File.expand_path('controllers/concerns/shared_examples*.rb', __dir__)].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include SpecSupport::Login
  config.include SpecSupport::Carrierwave
  config.include SpecSupport::Profile
  config.include SpecSupport::AppConfig

  config.infer_spec_type_from_file_location!

  # This enable Rails's `use_transactional_tests` (for legacy reasons, it hasn't been renamed
  # in RSpec config)
  config.use_transactional_fixtures = true

  config.before :each, elasticsearch: true do
    Person.__elasticsearch__.create_index!(force: true)
    Person.__elasticsearch__.refresh_index!
  end

  config.after :each, elasticsearch: true do
    Person.__elasticsearch__.delete_index!
  end
end
