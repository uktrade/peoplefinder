# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.redis_sidekiq_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.redis_sidekiq_url }
end
