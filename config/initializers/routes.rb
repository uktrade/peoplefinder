# frozen_string_literal: true

# Enable routes to work outside controller flows
Rails.application.routes.default_url_options = {
  host: ENV.fetch('APP_HOST')
}
