Raven.configure do |config|
  # c.f. https://docs.sentry.io/clients/ruby/config/

  # Set environments in which Raven will send data to Sentry
  #  (this avoids data from `development` ending up in Sentry if someone sets SENTRY_DSN locally)
  config.environments = %w[production staging dev]

  # Set environment to `APPLICATION_ENV` (normally defaults to Rails.env)
  #   (this avoids errors from staging/dev showing up as production)
  config.current_environment = ENV['APPLICATION_ENV'] || Rails.env
end
