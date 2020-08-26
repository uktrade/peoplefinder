# frozen_string_literal: true

class EmailAddressValidator < ActiveModel::EachValidator
  # Nowhere near exhaustive list of "insecure" providers, but covers our particular problem cases
  DISALLOWED_EMAIL_DOMAINS = %w[
    aol.com btinternet.com fcowebmail.gov.uk gmail.com hotmail.com hotmail.co.uk outlook.com yahoo.com ymail.com
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    name = I18n.t("helpers.label.#{record.model_name.i18n_key}.#{attribute}")

    record.errors.add(attribute, "#{name} is not a valid email address") unless value.match?(URI::MailTo::EMAIL_REGEXP)

    domain = value.split('@').last&.downcase
    return unless DISALLOWED_EMAIL_DOMAINS.include?(domain)

    record.errors.add(attribute, "#{name} is not acceptable (#{domain} addresses are not allowed)")
  end
end
