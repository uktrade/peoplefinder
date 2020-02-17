# frozen_string_literal: true

Rails.application.configure do
  # CloudFoundry Services
  vcap_services = VcapServices.new(ENV['VCAP_SERVICES'])
  config.elastic_search_url = vcap_services.service_url(:elasticsearch)
  config.redis_cache_url = vcap_services.named_service_url(:redis, 'redis-peoplefinder-cache')
  config.redis_sidekiq_url = vcap_services.named_service_url(:redis, 'redis-peoplefinder-sidekiq')

  # Production caching and sessions through Redis Cache
  config.cache_store = :redis_cache_store, { url: config.redis_cache_url }
  config.session_store :cache_store,
                       key: 'peoplefinder_session',
                       expire_after: 1.hour,
                       httponly: true

  # Logging
  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.log_level = :info
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = ->(event) { event.payload } # See ApplicationController#append_info_to_payload

  # Serve static assets even in production
  config.serve_static_assets = true
  config.public_file_server.enabled = true

  config.force_ssl = true
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0.4'
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_record.dump_schema_after_migration = false
  config.filter_parameters += %i[
    given_name surname email primary_phone_number
    secondary_phone_number location email
  ]
end
