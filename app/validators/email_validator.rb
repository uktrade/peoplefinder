class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    email_address = EmailAddress.new(value)

    if value.present? && !email_address.valid_format?
      record.errors.add(attribute, :invalid_format, options)
    end
  end
end
