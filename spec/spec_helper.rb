# frozen_string_literal: true

require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = 'examples.txt'

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  WebMock.disable_net_connect!(allow: 'elasticsearch:9200', allow_localhost: true)

  # TODO: Mock this in a better way - the URL is an implementation detail of the Notify API
  config.before do
    WebMock.stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
           .to_return(status: 200, body: '{}')
  end
end
