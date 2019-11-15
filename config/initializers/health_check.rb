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
end
