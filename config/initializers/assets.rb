# frozen_string_literal: true

Rails.application.config.assets.precompile += %w[
  email.css
  Jcrop/css/jquery.Jcrop.min.css
  Jcrop/js/jquery.Jcrop.min.js
]

unless Rails.env.production?
  Rails.application.config.assets.precompile += %w[ teaspoon.css
                                                    teaspoon-teaspoon.js
                                                    mocha/1.17.1.js
                                                    teaspoon-mocha.js ]
end
