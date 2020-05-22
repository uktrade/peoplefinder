# frozen_string_literal: true

module Api::V2
  class ApplicationController < ActionController::Base
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_request

    private

    def client_public_key
      raise NoMethodError, '#client_public_key must be overriden in subclasses'
    end

    def authenticate_request
      authenticate_or_request_with_http_token do |token, _options|
        decoded_token = JWT.decode(token, client_public_key, true, algorithm: 'RS512')
        payload = decoded_token.first

        payload['fullpath'] == request.original_fullpath
      rescue StandardError => e
        logger.warn("Failed to authenticate API request: #{e.inspect}")

        false
      end
    end
  end
end
