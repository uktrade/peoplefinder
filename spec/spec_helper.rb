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

  config.before :each, auth_user_loader: true do
    stub_request(:get, 'http://test.local/api/v1/user/introspect?email=nobody@example.com')
      .with(headers: { 'Authorization' => 'Bearer abc' })
      .to_return(status: 404)

    stub_request(:get, 'http://test.local/api/v1/user/introspect?email=somebody@example.com')
      .with(headers: { 'Authorization' => 'Bearer abc' })
      .to_return(status: 200, body: {
        email: 'auth_user@example.com', user_id: 'deadbeef'
      }.to_json, headers: {})
  end
end
