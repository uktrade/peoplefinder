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

  config.before :each, geckoboard: true do
    stub_request(:get, 'https://api.geckoboard.com/')
      .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => %r{Geckoboard-Ruby/0\.[\d]+(\.[\d])*} })
      .to_return(status: 200, body: '', headers: {})
  end

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

  config.before :each, csv_report: true do
    delete_csv_reports
  end

  config.after :all, csv_report: true do
    delete_csv_reports
  end

  def delete_csv_reports
    Dir[Report.new.__send__(:tmp_dir).join('**', '*')].each do |file|
      File.delete(file)
    end
  end
end
