# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module Peoplefinder
  class Application < Rails::Application
    config.load_defaults 6.0

    # TODO: Fix the suboptimal way in which associations are set up on various
    #       models so this "old Rails" default can be removed.
    # Require `belongs_to` associations by default. Previous versions had false.
    Rails.application.config.active_record.belongs_to_required_by_default = false

    ActionView::Base.default_form_builder = GovukElementsFormBuilder::FormBuilder

    config.active_job.queue_adapter = :delayed_job
    config.active_record.schema_format = :ruby
    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')
    config.autoload_paths << Rails.root.join('lib')

    # Custom application configuration (hardcoded)
    config.app_title = 'People Finder'

    # Custom application configuration (from environment)
    config.x.s3.access_key = ENV['S3_KEY']
    config.x.s3.secret = ENV['S3_SECRET']
    config.x.s3.region = ENV['S3_REGION']
    config.x.s3.bucket_name = ENV['S3_BUCKET_NAME']

    config.x.sso.use_developer_strategy = Rails.env.development? && ENV['DEVELOPER_AUTH_STRATEGY']
    config.x.sso.provider = ENV['DITSSO_INTERNAL_PROVIDER']
    config.x.sso.client_id = ENV['DITSSO_INTERNAL_CLIENT_ID']
    config.x.sso.client_secret = ENV['DITSSO_INTERNAL_CLIENT_SECRET']
    config.x.sso.callback_url = ENV['DITSSO_CALLBACK_URL']

    config.x.zendesk.url = ENV['ZD_URL']
    config.x.zendesk.user = ENV['ZD_USER']
    config.x.zendesk.password = ENV['ZD_PASS']
    config.x.zendesk.service_id = ENV['ZD_SERVICE_ID']
    config.x.zendesk.service_name = ENV['ZD_SERVICE_NAME']

    config.elastic_search_url = ENV['ES_URL'] # Overridden in production config
    config.google_analytics_tracking_id = ENV['GA_TRACKING_ID']
    config.govuk_notify_api_key = ENV['GOVUK_NOTIFY_API_KEY']
    config.home_page_url = ENV['HOME_PAGE_URL']
    config.profile_api_token = ENV['PROFILE_API_TOKEN']
    config.redis_cache_url = ENV['REDIS_CACHE_URL'] # Overridden in production config
    config.redis_sidekiq_url = ENV['REDIS_SIDEKIQ_URL'] # Overridden in production config
  end
end
