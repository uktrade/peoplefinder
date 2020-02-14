# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.redis_sidekiq_url }
  config.log_formatter = Sidekiq::Logger::Formatters::JSON.new
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.redis_sidekiq_url }
end
