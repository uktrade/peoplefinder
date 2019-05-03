# frozen_string_literal: true

module SpecSupport
  module AppConfig
    def app_title
      Rails.configuration.app_title
    end
  end
end
