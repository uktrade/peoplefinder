# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_jwt_examples'

describe 'Person profile API' do
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:public_key) { private_key.public_key }

  let(:fake_serializer) { double(as_json: { foo: 'bar' }) }

  before do
    allow(Rails.configuration).to receive(:api_people_profiles_public_key).and_return(public_key)

    get '/api/v2/people_profiles/00-00-0000', headers: { 'Authorization' => "Bearer #{jwt}" }
  end

  it_behaves_like 'a JWT protected API', '/api/v2/people_profiles/00-00-0000'

  context 'with a valid JWT' do
    let(:jwt) { JWT.encode({ exp: 1.minute.from_now.to_i, fullpath: '/api/v2/people_profiles/00-00-0000' }, private_key, 'RS512') }

    context 'when the person exists' do
      let(:parsed_json) { JSON.parse(response.body) }

      before do
        create(:person, ditsso_user_id: '00-00-0000')
        get '/api/v2/people_profiles/00-00-0000', headers: { 'Authorization' => "Bearer #{jwt}" }
      end

      it 'returns appropriately structured data' do
        expect(response).to have_http_status(:ok)
        expect(parsed_json).to include('first_name')
      end
    end

    context 'when the person does not exist' do
      it 'returns an appropriate response' do
        expect(response).to have_http_status(:not_found)
        expect(response.body).to be_empty
      end
    end
  end
end
