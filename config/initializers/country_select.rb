# frozen_string_literal: true

CountrySelect::FORMATS[:with_dialling_code] = lambda do |country|
  "#{country.name} (+#{country.country_code})"
end
