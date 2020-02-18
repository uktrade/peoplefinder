# frozen_string_literal: true

Rails.application.config.assets.precompile += %w[
  Jcrop/css/jquery.Jcrop.min.css
  Jcrop/js/jquery.Jcrop.min.js
  application_legacy.css
  application_legacy.js
]
