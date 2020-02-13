# frozen_string_literal: true

require 'health_check/elasticsearch_health_check'

HealthCheck.setup do |config|
  config.uri = 'health_check'
  config.success = 'success'
  config.http_status_for_error_text = 500
  config.http_status_for_error_object = 500
  config.standard_checks = %w[database elasticsearch]

  config.add_custom_check('elasticsearch') do
    HealthCheck::ElasticsearchHealthCheck.check
  end

  config.add_custom_check('redis_cache') do
    res = ::Redis.new(url: Rails.configuration.redis_cache_url).ping
    res == 'PONG' ? '' : "Redis.ping returned #{res.inspect} instead of PONG"
  end

  config.add_custom_check('redis_sidekiq') do
    res = ::Redis.new(url: Rails.configuration.redis_sidekiq_url).ping
    res == 'PONG' ? '' : "Redis.ping returned #{res.inspect} instead of PONG"
  end
end
