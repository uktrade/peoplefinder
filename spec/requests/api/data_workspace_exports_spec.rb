# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_jwt_examples'

describe 'Data Workspace exports API' do
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:public_key) { private_key.public_key }

  let!(:person) { create(:person) }
  let(:parsed_json) { JSON.parse(response.body).with_indifferent_access }

  before do
    allow(Rails.configuration).to receive(:api_data_workspace_exports_public_key).and_return(public_key)
    get '/api/v2/data_workspace_export', headers: { 'Authorization' => "Bearer #{jwt}" }
  end

  it_behaves_like 'a JWT protected API', '/api/v2/data_workspace_export'

  context 'with a valid JWT' do
    let(:jwt) { JWT.encode({ exp: 1.minute.from_now.to_i, fullpath: '/api/v2/data_workspace_export' }, private_key, 'RS512') }

    it 'returns appropriately structured data' do
      expect(response).to have_http_status(:ok)
      expect(parsed_json).to include(:results, :next)
      expect(parsed_json[:results].first).to include(people_finder_id: person.id)
    end
  end
end
