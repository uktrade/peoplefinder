# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'rails/test_unit/railtie'
require 'countries'

Bundler.require(*Rails.groups)

module Peoplefinder
  class Application < Rails::Application
    config.load_defaults 6.0

    # Autoloading: Ignore Webpacker assets directory
    Rails.autoloaders.main.ignore(Rails.root.join('app/webpacker'))

    # TODO: Fix the suboptimal way in which associations are set up on various
    #       models so this "old Rails" default can be removed.
    # Require `belongs_to` associations by default. Previous versions had false.
    Rails.application.config.active_record.belongs_to_required_by_default = false

    config.active_record.schema_format = :ruby
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

    config.elastic_apm.service_name = 'peoplefinder'
    config.elastic_apm.enabled = false # Overridden in production config

    config.elastic_search_url = ENV['ES_URL'] # Overridden in production config
    # Overridden in test config
    config.enable_external_integrations = ActiveModel::Type::Boolean.new.cast(ENV['ENABLE_EXTERNAL_INTEGRATIONS'])
    config.google_analytics_tracking_id = ENV['GA_TRACKING_ID']
    config.govuk_notify_api_key = ENV['GOVUK_NOTIFY_API_KEY']
    config.home_page_url = ENV['HOME_PAGE_URL']
    config.mailchimp_list_id = ENV['MAILCHIMP_LIST_ID']
    config.profile_stale_after_days = ENV.fetch('PROFILE_STALE_AFTER_DAYS', 30).to_i
    config.redis_cache_url = ENV['REDIS_CACHE_URL'] # Overridden in production config
    config.redis_sidekiq_url = ENV['REDIS_SIDEKIQ_URL'] # Overridden in production config

    def self.rsa_key_from_base64_encoded_pem(value)
      return nil if value.blank?

      pem = Base64.decode64(value)
      OpenSSL::PKey::RSA.new(pem)
    end

    config.api_data_workspace_exports_public_key = rsa_key_from_base64_encoded_pem(
      ENV['API_DATA_WORKSPACE_EXPORTS_PUBLIC_KEY']
    )

    config.api_people_profiles_public_key = rsa_key_from_base64_encoded_pem(
      ENV['API_PEOPLE_PROFILES_PUBLIC_KEY']
    )

    # Override North Macedonia
    # https://github.com/hexorx/countries#loading-custom-data
    # Due to the way overriding works, we have to copy all the information
    # we want. This information was copied from the `countries` gem itself
    # and the translations have been changed.
    ISO3166::Data.register(
      continent: 'Europe',
      address_format: '{{recipient}}\n{{street}}\n{{city}} {{postalcode}}\n{{country}}',
      alpha2: 'MK',
      alpha3: 'MKD',
      country_code: '389',
      international_prefix: '00',
      ioc: 'MKD',
      gec: 'MK',
      name: 'North Macedonia',
      national_destination_code_lengths: [2],
      national_number_lengths: [7, 8],
      national_prefix: '0',
      number: '807',
      region: 'Europe',
      subregion: 'Southern Europe',
      world_region: 'EMEA',
      un_locode: 'MK',
      nationality: 'Macedonian',
      postal_code: true,
      unofficial_names: [
        'Macedonia',
        'Mazedonien',
        'Macédoine',
        'F.Y.R.O.M (Macedonia)',
        'マケドニア旧ユーゴスラビア共和国',
        'Macedonië [FYROM]',
        'Macedonia (The Former Yugoslav Republic of)',
        'North Macedonia'
      ],
      languages_official: ['mk'],
      languages_spoken: ['mk'],
      geo: {
        'latitude' => 41.608635,
        'latitude_dec' => '41.60045623779297',
        'longitude' => 21.745275,
        'longitude_dec' => '21.700895309448242',
        'max_latitude' => 42.373646,
        'max_longitude' => 23.034093,
        'min_latitude' => 40.8537826,
        'min_longitude' => 20.452423,
        'bounds' => {
          'northeast' => {
            'lat' => 42.373646,
            'lng' => 23.034093
          },
          'southwest' => {
            'lat' => 40.8537826,
            'lng' => 20.452423
          }
        }
      },
      currency_code: 'MKD',
      start_of_week: 'monday',
      translations: {
        'en' => 'North Macedonia'
      },
      translated_names: ['North Macedonia']
    )
  end
end
