# frozen_string_literal: true

require 'ditsso_internal'

OmniAuth.config.allowed_request_methods = [:post, :get]

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.configuration.x.sso.use_developer_strategy
    provider :developer, fields: %i[first_name last_name email user_id],
                         uid_field: :user_id,
                         name: 'ditsso_internal'
  else
    provider 'ditsso_internal',
             Rails.configuration.x.sso.client_id,
             Rails.configuration.x.sso.client_secret
  end
end
