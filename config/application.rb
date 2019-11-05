# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Peoplefinder
  class Application < Rails::Application
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    # Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from
    # config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales',
    # '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # TODO: Fix the suboptimal way in which associations are set up on various
    #       models so this "old Rails" default can be removed.
    # Require `belongs_to` associations by default. Previous versions had false.
    Rails.application.config.active_record.belongs_to_required_by_default = false

    ActionView::Base.default_form_builder = GovukElementsFormBuilder::FormBuilder

    # app title appears in the header bar
    config.app_title = 'People Finder'

    config.department_name = 'Department for International Trade'

    config.department_abbrev = 'DIT'

    # disabling the adding/editing/deletion of another person's profile
    config.disable_open_profiles = false

    config.admin_ip_ranges = ENV.fetch('ADMIN_IP_RANGES', '127.0.0.1')

    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

    config.support_email = ENV.fetch('SUPPORT_EMAIL')

    config.action_mailer.default_options = {
      from: config.support_email
    }

    config.active_job.queue_adapter = :delayed_job

    config.active_record.schema_format = :ruby

    config.aws_elastic_region = ENV['AWS_ELASTICSEARCH_REGION']
    config.aws_elastic_key = ENV['AWS_ELASTICSEARCH_KEY']
    config.aws_elastic_secret = ENV['AWS_ELASTICSEARCH_SECRET']
    config.elastic_search_url = ENV['ES_URL']

    config.rack_timeout = (ENV['RACK_TIMEOUT'] || 14)

    config.action_mailer.default_url_options = {
      host: ENV['ACTION_MAILER_DEFAULT_URL'],
      protocol: 'https'
    }

    config.action_mailer.asset_host = config.action_mailer.default_url_options[:protocol] +
                                      '://' +
                                      (config.action_mailer.default_url_options[:host] || 'localhost')

    # Note: ENV is set to 'dev','staging','production' on dev,staging, production respectively
    config.send_reminder_emails = (ENV['ENV'] == 'production')

    # make the geckoboard publisher available generally
    # NOTE: may need to eager load paths instead if lib code is commonly called
    config.autoload_paths << Rails.root.join('lib')
  end
end
