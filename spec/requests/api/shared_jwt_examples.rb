# frozen_string_literal: true

RSpec.shared_examples 'a JWT protected API' do |request_path|
  context 'without a JWT' do
    let(:jwt) { '' }

    it 'does not allow access' do
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to match(/HTTP Token: Access denied/)
    end
  end

  context 'with a JWT signed with the wrong private key' do
    let(:invalid_private_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:jwt) { JWT.encode({ exp: 1.minute.from_now.to_i, fullpath: request_path }, invalid_private_key, 'RS512') }

    it 'does not allow access' do
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to match(/HTTP Token: Access denied/)
    end
  end

  context 'with a valid but expired JWT' do
    let(:jwt) { JWT.encode({ exp: 1.minute.ago.to_i, fullpath: request_path }, private_key, 'RS512') }

    it 'does not allow access' do
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to match(/HTTP Token: Access denied/)
    end
  end

  context 'with a valid JWT but containing the wrong path' do
    let(:jwt) { JWT.encode({ exp: 1.minute.from_now.to_i, fullpath: '/wrong' }, private_key, 'RS512') }

    it 'does not allow access' do
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to match(/HTTP Token: Access denied/)
    end
  end

  context 'if no public key is specified in the environment' do
    let(:public_key) { nil }
    let(:jwt) { JWT.encode({ exp: 1.minute.from_now.to_i, fullpath: request_path }, private_key, 'RS512') }

    it 'does not allow access' do
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to match(/HTTP Token: Access denied/)
    end
  end
end
