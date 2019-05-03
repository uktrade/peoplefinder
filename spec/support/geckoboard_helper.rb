# frozen_string_literal: true

module SpecSupport
  module GeckoboardHelper
    RSpec.configure do |config|
      config.before do
        mock_response = {
          id: '12345',
          fields: [],
          unique_by: []
        }

        stub_request(:any, %r{api\.geckoboard\.com/}).to_return(status: 200, body: mock_response.to_json)
      end
    end
  end
end
