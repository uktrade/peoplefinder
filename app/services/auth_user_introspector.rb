class AuthUserIntrospector
  class << self
    def valid?(token, user)

      return false unless token
      return false unless user
      new(token, user.internal_auth_key).token_valid?
    end
  end

  def initialize(token, internal_auth_key)
    @token = token
    @internal_auth_key = internal_auth_key
  end

  def token_valid?
    check_token
  end

  private

  include HTTParty

  BASE_URL = ENV['DITSSO_INTERNAL_PROVIDER'] || 'http://test.local'
  AUTH_TOKEN = ENV['DIT_ABC_TOKEN'] || 'abc'

  def check_token
    response = HTTParty.get(
      "#{URI.join(BASE_URL, '/o/introspect')}?token=#{@token}",
      headers: {
        'Authorization' => "Bearer #{AUTH_TOKEN}"
      }
    )
    return false unless response.success?

    response_body = JSON.parse(response.body)
    response_body['username'] == @internal_auth_key && response_body['active']
  end
end
