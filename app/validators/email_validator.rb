# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    email_address = EmailAddress.new(value)

    record.errors.add(attribute, :invalid_format, options) if value.present? && !email_address.valid_format?
  end
end
